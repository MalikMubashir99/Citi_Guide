// lib/admin/dashboard/admin_dashboard_screen.dart
import 'package:app/admin/screens/attraction/attractions_screen.dart';
import 'package:app/admin/screens/city/city_list_screen.dart';
import 'package:app/admin/screens/event/events_screen.dart';
import 'package:app/admin/screens/hotel/hotels_screen.dart';
import 'package:app/admin/screens/restaurant/restaurants_screen.dart';
import 'package:app/admin/services/admin_service.dart';
import 'package:app/admin/screens/user/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Direct colors (no AppColors) ──
class _AdminColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color dark = Color(0xFF0F172A);
  static const Color darkGrey = Color(0xFF334155);
  static const Color grey = Color(0xFF64748B);
  static const Color lightGrey = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF10B981);
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService dashboardService = AdminService();

  int users = 0;
  int cities = 0;
  int attractions = 0;
  int hotels = 0;
  int restaurants = 0;
  int events = 0;

  bool isLoading = true;
  String selectedRoute = '/dashboard';

  @override
  void initState() {
    super.initState();
    loadCounts();
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
          backgroundColor: _AdminColors.error,
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
                color: _AdminColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.admin_panel_settings_rounded,
                color: _AdminColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Admin Panel',
              style: GoogleFonts.poppins(
                color: _AdminColors.dark,
                fontWeight: FontWeight.w600,
                fontSize: 20,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        backgroundColor: _AdminColors.background,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _AdminColors.error.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.logout_rounded,
                color: _AdminColors.error,
                size: 24,
              ),
              onPressed: () => _showLogoutDialog(),
            ),
          ),
        ],
      ),
      sideBar: SideBar(
        backgroundColor: _AdminColors.white,
        iconColor: _AdminColors.primary,
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _AdminColors.primary),
            )
          : _buildBody(),
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
        screen = CityListScreen();
        break;
      case '/attractions':
        screen = AttractionsScreen();
        break;
      case '/hotels':
        screen = const HotelsScreen();
        break;
      case '/restaurants':
        screen = const RestaurantsScreen();
        break;
      case '/events':
        screen = EventsScreen();
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
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(),
          const SizedBox(height: 28),

          // Stats Grid
          _buildStatsGrid(),
          const SizedBox(height: 28),

          // Quick Actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final total = users + cities + attractions + hotels + restaurants + events;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Admin! 👋',
                  style: GoogleFonts.poppins(
                    color: _AdminColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Items: $total',
                  style: GoogleFonts.poppins(
                    color: _AdminColors.white.withOpacity(0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _AdminColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'All systems operational ✅',
                    style: GoogleFonts.poppins(
                      color: _AdminColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _AdminColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: _AdminColors.white,
              size: 32,
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
        gradient: const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
        route: '/users',
      ),
      _DashboardCardData(
        title: 'Cities',
        count: cities,
        icon: Icons.location_city_rounded,
        gradient: const [Color(0xFF43E97B), Color(0xFF38F9D7)],
        route: '/cities',
      ),
      _DashboardCardData(
        title: 'Attractions',
        count: attractions,
        icon: Icons.place_rounded,
        gradient: const [Color(0xFFFA709A), Color(0xFFFEE140)],
        route: '/attractions',
      ),
      _DashboardCardData(
        title: 'Hotels',
        count: hotels,
        icon: Icons.hotel_rounded,
        gradient: const [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
        route: '/hotels',
      ),
      _DashboardCardData(
        title: 'Restaurants',
        count: restaurants,
        icon: Icons.restaurant_rounded,
        gradient: const [Color(0xFFF093FB), Color(0xFFF5576C)],
        route: '/restaurants',
      ),
      _DashboardCardData(
        title: 'Events',
        count: events,
        icon: Icons.event_rounded,
        gradient: const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
        route: '/events',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 columns for a cleaner look
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 80)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: _buildStatCard(cards[index]),
        );
      },
    );
  }

  Widget _buildStatCard(_DashboardCardData card) {
    return InkWell(
      onTap: () {
        setState(() => selectedRoute = card.route);
        _navigateToRoute(card.route);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: card.gradient,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: card.gradient.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern (subtle)
            Positioned(
              right: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.08,
                child: Icon(card.icon, size: 80, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon and badge row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(card.icon, color: Colors.white, size: 22),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${card.count > 0 ? card.count : 0}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Count and Title
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.count.toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        card.title,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.85),
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
          style: GoogleFonts.poppins(
            color: _AdminColors.dark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildQuickActionButton(
              icon: Icons.add_location_rounded,
              label: 'Add City',
              color: const Color(0xFF43E97B),
              onTap: () {
                setState(() => selectedRoute = '/cities');
                _navigateToRoute('/cities');
              },
            ),
            const SizedBox(width: 12),
            _buildQuickActionButton(
              icon: Icons.add_business_rounded,
              label: 'Add Hotel',
              color: const Color(0xFFA18CD1),
              onTap: () {
                setState(() => selectedRoute = '/hotels');
                _navigateToRoute('/hotels');
              },
            ),
            const SizedBox(width: 12),
            _buildQuickActionButton(
              icon: Icons.add_photo_alternate_rounded,
              label: 'Add Attraction',
              color: const Color(0xFFFA709A),
              onTap: () {
                setState(() => selectedRoute = '/attractions');
                _navigateToRoute('/attractions');
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
            color: _AdminColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _AdminColors.lightGrey.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: _AdminColors.dark,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _AdminColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: _AdminColors.error),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: _AdminColors.dark,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(
            color: _AdminColors.darkGrey,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: _AdminColors.grey,
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
              backgroundColor: _AdminColors.error,
              foregroundColor: _AdminColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCardData {
  final String title;
  final int count;
  final IconData icon;
  final List<Color> gradient;
  final String route;

  _DashboardCardData({
    required this.title,
    required this.count,
    required this.icon,
    required this.gradient,
    required this.route,
  });
}