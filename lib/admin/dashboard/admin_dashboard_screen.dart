// lib/admin/dashboard/admin_dashboard_screen.dart
import 'package:app/admin/screens/attraction/attractions_screen.dart';
import 'package:app/admin/screens/city/city_list_screen.dart';
import 'package:app/admin/screens/event/events_screen.dart';
import 'package:app/admin/screens/hotel/hotels_screen.dart';
import 'package:app/admin/screens/restaurant/restaurants_screen.dart';
import 'package:app/admin/services/admin_service.dart';
import 'package:app/admin/screens/user/users_screen.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final AdminService dashboardService = AdminService();

  int users = 0;
  int cities = 0;
  int attractions = 0;
  int hotels = 0;
  int restaurants = 0;
  int events = 0;
  
  bool isLoading = true;
  String selectedRoute = '/dashboard';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    loadCounts();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadCounts() async {
    setState(() => isLoading = true);
    
    try {
      final results = await Future.wait([
        dashboardService.getUsersCount(),
        dashboardService.getCitiesCount(),
        dashboardService.getAttractionsCount(),
        dashboardService.getHotelsCount(),
        dashboardService.getRestaurantsCount(),
        dashboardService.getEventsCount(),
      ]);

      setState(() {
        users = results[0];
        cities = results[1];
        attractions = results[2];
        hotels = results[3];
        restaurants = results[4];
        events = results[5];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.admin_panel_settings_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Admin Dashboard',
              style: GoogleFonts.playfairDisplay(
                color: AppColors.dark,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.dark,
                size: 24,
              ),
              onPressed: () {},
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 24,
              ),
              onPressed: () => _showLogoutDialog(),
            ),
          ),
        ],
      ),
      sideBar: SideBar(
        backgroundColor: AppColors.white,
        // ✅ Removed unsupported parameters
        items: [
          AdminMenuItem(
            title: 'Dashboard',
            icon: Icons.dashboard_rounded,
            route: '/dashboard',
          ),
          AdminMenuItem(
            title: 'Users',
            icon: Icons.people_rounded,
            route: '/users',
          ),
          AdminMenuItem(
            title: 'Cities',
            icon: Icons.location_city_rounded,
            route: '/cities',
          ),
          AdminMenuItem(
            title: 'Attractions',
            icon: Icons.place_rounded,
            route: '/attractions',
          ),
          AdminMenuItem(
            title: 'Hotels',
            icon: Icons.hotel_rounded,
            route: '/hotels',
          ),
          AdminMenuItem(
            title: 'Restaurants',
            icon: Icons.restaurant_rounded,
            route: '/restaurants',
          ),
          AdminMenuItem(
            title: 'Events',
            icon: Icons.event_rounded,
            route: '/events',
          ),
        ],
        selectedRoute: selectedRoute,
        onSelected: (item) {
          final route = item.route ?? '/dashboard';
          setState(() => selectedRoute = route);
          _navigateToRoute(route);
        },
      ),
      body: _buildBody(),
    );
  }

  void _navigateToRoute(String route) {
    Widget screen;
    switch (route) {
      case '/dashboard':
        return;
      case '/users':
        screen = const UsersScreen();
        break;
      case '/cities':
        screen =  CityListScreen();
        break;
      case '/attractions':
        screen = const AttractionsScreen();
        break;
      case '/hotels':
        screen = const HotelsScreen();
        break;
      case '/restaurants':
        screen = const RestaurantsScreen();
        break;
      case '/events':
        screen = const EventsScreen();
        break;
      default:
        return;
    }
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildShimmerLoading();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section with Gradient Animation
            _buildWelcomeSection(),
            
            const SizedBox(height: 28),
            
            // Stats Grid with Staggered Animation
            _buildStatsGrid(),
            
            const SizedBox(height: 28),
            
            // Quick Actions
            _buildQuickActions(),
            
            const SizedBox(height: 28),
            
            // Recent Activity / Chart
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.2,
          children: List.generate(
            6,
            (index) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, Admin! 👋',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Here\'s your daily overview',
                      style: GoogleFonts.lato(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Animated Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats Summary
          Row(
            children: [
              _buildStatChip(
                label: 'Total Items',
                value: (users + cities + attractions + hotels + restaurants + events).toString(),
                icon: Icons.dashboard_rounded,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                label: 'Active',
                value: '100%',
                icon: Icons.verified_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            '$value $label',
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final cards = [
      _DashboardCardData(
        title: 'Users',
        count: users,
        icon: Icons.people_rounded,
        color: Colors.blue,
        route: '/users',
        gradient: const [Color(0xff4facfe), Color(0xff00f2fe)],
      ),
      _DashboardCardData(
        title: 'Cities',
        count: cities,
        icon: Icons.location_city_rounded,
        color: Colors.green,
        route: '/cities',
        gradient: const [Color(0xff43e97b), Color(0xff38f9d7)],
      ),
      _DashboardCardData(
        title: 'Attractions',
        count: attractions,
        icon: Icons.place_rounded,
        color: Colors.orange,
        route: '/attractions',
        gradient: const [Color(0xfffa709a), Color(0xfffee140)],
      ),
      _DashboardCardData(
        title: 'Hotels',
        count: hotels,
        icon: Icons.hotel_rounded,
        color: Colors.purple,
        route: '/hotels',
        gradient: const [Color(0xffa18cd1), Color(0xfffbc2eb)],
      ),
      _DashboardCardData(
        title: 'Restaurants',
        count: restaurants,
        icon: Icons.restaurant_rounded,
        color: Colors.red,
        route: '/restaurants',
        gradient: const [Color(0xfff093fb), Color(0xfff5576c)],
      ),
      _DashboardCardData(
        title: 'Events',
        count: events,
        icon: Icons.event_rounded,
        color: Colors.teal,
        route: '/events',
        gradient: const [Color(0xff4facfe), Color(0xff00f2fe)],
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.1,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: _buildStatCard(card),
        );
      },
    );
  }

  Widget _buildStatCard(_DashboardCardData card) {
    return InkWell(
      onTap: () {
        if (card.route.isNotEmpty) {
          setState(() => selectedRoute = card.route);
          _navigateToRoute(card.route);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              card.gradient[0],
              card.gradient[1],
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: card.color.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              right: -20,
              top: -20,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  card.icon,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          card.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${card.count > 0 ? card.count : 0}',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.count.toString(),
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        card.title,
                        style: GoogleFonts.lato(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.dark,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildQuickActionButton(
              icon: Icons.add_location_rounded,
              label: 'Add City',
              color: AppColors.primary,
              onTap: () {
                // Navigate to add city
              },
            ),
            const SizedBox(width: 12),
            _buildQuickActionButton(
              icon: Icons.add_business_rounded,
              label: 'Add Hotel',
              color: Colors.purple,
              onTap: () {
                // Navigate to add hotel
              },
            ),
            const SizedBox(width: 12),
            _buildQuickActionButton(
              icon: Icons.add_photo_alternate_rounded,
              label: 'Add Attraction',
              color: Colors.orange,
              onTap: () {
                // Navigate to add attraction
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.lightGrey,
              width: 1,
            ),
            boxShadow: AppColors.subtleShadow,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.lato(
                  color: AppColors.dark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.dark,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.lightGrey,
              width: 1,
            ),
            boxShadow: AppColors.subtleShadow,
          ),
          child: Column(
            children: [
              _buildActivityItem(
                icon: Icons.person_add_rounded,
                color: Colors.blue,
                title: 'New user registered',
                time: '2 minutes ago',
              ),
              _buildDivider(),
              _buildActivityItem(
                icon: Icons.location_city_rounded,
                color: Colors.green,
                title: 'New city added: Lahore',
                time: '15 minutes ago',
              ),
              _buildDivider(),
              _buildActivityItem(
                icon: Icons.hotel_rounded,
                color: Colors.purple,
                title: 'New hotel added: Pearl Continental',
                time: '1 hour ago',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lato(
                  color: AppColors.dark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                time,
                style: GoogleFonts.lato(
                  color: AppColors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColors.grey,
          size: 16,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        color: AppColors.lightGrey,
        thickness: 1,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: GoogleFonts.playfairDisplay(
                color: AppColors.dark,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.lato(
            color: AppColors.darkGrey,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.lato(
                color: AppColors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// Helper class for dashboard cards
class _DashboardCardData {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final String route;
  final List<Color> gradient;

  _DashboardCardData({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.route,
    required this.gradient,
  });
}