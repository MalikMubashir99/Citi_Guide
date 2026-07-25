import 'package:app/admin/screens/city/city_list_screen.dart';
import 'package:app/admin/services/admin_service.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  final AdminService dashboardService = AdminService();

  AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int users = 0;
  int cities = 0;
  int attractions = 0;
  int hotels = 0;
  int restaurants = 0;
  int events = 0;

  @override
  void initState() {
    super.initState();
    loadCounts();
  }

  Future<void> loadCounts() async {
    users = await widget.dashboardService.getUsersCount();
    cities = await widget.dashboardService.getCitiesCount();
    attractions = await widget.dashboardService.getAttractionsCount();
    hotels = await widget.dashboardService.getHotelsCount();
    restaurants = await widget.dashboardService.getRestaurantsCount();
    events = await widget.dashboardService.getEventsCount();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
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
                  MaterialPageRoute(builder: (_) => CityListScreen()),
                );
              },
            ),
            dashboardCard(
              title: "Attractions",
              count: attractions,
              icon: Icons.place,
              color: Colors.orange,
            ),
            dashboardCard(
              title: "Hotels",
              count: hotels,
              icon: Icons.hotel,
              color: Colors.purple,
            ),
            dashboardCard(
              title: "Restaurants",
              count: restaurants,
              icon: Icons.restaurant,
              color: Colors.red,
            ),
            dashboardCard(
              title: "Events",
              count: events,
              icon: Icons.event,
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardCard({
    required String title,
    required IconData icon,
    required Color color,
    required int count,
    VoidCallback? onTap,      // ✅ added
  }) {
    return Card(
      elevation: 5,
      child: InkWell(
        onTap: onTap ?? () {},   // ✅ used here
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 55, color: color),
            const SizedBox(height: 15),
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}