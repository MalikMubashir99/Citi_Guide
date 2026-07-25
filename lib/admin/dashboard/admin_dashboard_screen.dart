import 'package:app/admin/screens/attraction/attractions_screen.dart';
import 'package:app/admin/screens/city/city_list_screen.dart';
import 'package:app/admin/screens/event/events_screen.dart';
import 'package:app/admin/screens/hotel/hotels_screen.dart';
import 'package:app/admin/screens/restaurant/restaurants_screen.dart';
import 'package:app/admin/services/admin_service.dart';
import 'package:app/admin/screens/user/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';

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
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Handle logout
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      sideBar: SideBar(
        items: [
          AdminMenuItem(
            title: 'Dashboard',
            icon: Icons.dashboard,
            route: '/dashboard',
          ),
          AdminMenuItem(
            title: 'Users',
            icon: Icons.people,
            route: '/users',
          ),
          AdminMenuItem(
            title: 'Cities',
            icon: Icons.location_city,
            route: '/cities',
          ),
          AdminMenuItem(
            title: 'Attractions',
            icon: Icons.place,
            route: '/attractions',
          ),
          AdminMenuItem(
            title: 'Hotels',
            icon: Icons.hotel,
            route: '/hotels',
          ),
          AdminMenuItem(
            title: 'Restaurants',
            icon: Icons.restaurant,
            route: '/restaurants',
          ),
          AdminMenuItem(
            title: 'Events',
            icon: Icons.event,
            route: '/events',
          ),
        ],
        selectedRoute: selectedRoute,
        onSelected: (item) {
          // ✅ Fix: Handle nullable route with fallback
          setState(() {
            selectedRoute = item.route ?? '/dashboard';
          });
          
          // Navigate to selected screen
          switch (item.route) {
            case '/dashboard':
              // Already on dashboard
              break;
            case '/users':
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UsersScreen(),
                ),
              );
              break;
            case '/cities':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CityListScreen(),
                ),
              );
              break;
            case '/attractions':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AttractionsScreen(),
                ),
              );
              break;
            case '/hotels':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HotelsScreen(),
                ),
              );
              break;
            case '/restaurants':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RestaurantsScreen(),
                ),
              );
              break;
            case '/events':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EventsScreen(),
                ),
              );
              break;
          }
        },
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff0984E3),
                  Color(0xff00CEC9),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Admin! 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Here\'s what\'s happening with your app today',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.2,
              children: [
                dashboardCard(
                  title: "Users",
                  count: users,
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                dashboardCard(
                  title: "Cities",
                  count: cities,
                  icon: Icons.location_city,
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CityListScreen(),
                      ),
                    );
                  },
                ),
                dashboardCard(
                  title: "Attractions",
                  count: attractions,
                  icon: Icons.place,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AttractionsScreen(),
                      ),
                    );
                  },
                ),
                dashboardCard(
                  title: "Hotels",
                  count: hotels,
                  icon: Icons.hotel,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HotelsScreen(),
                      ),
                    );
                  },
                ),
                dashboardCard(
                  title: "Restaurants",
                  count: restaurants,
                  icon: Icons.restaurant,
                  color: Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RestaurantsScreen(),
                      ),
                    );
                  },
                ),
                dashboardCard(
                  title: "Events",
                  count: events,
                  icon: Icons.event,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EventsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboardCard({
    required String title,
    required IconData icon,
    required Color color,
    required int count,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}