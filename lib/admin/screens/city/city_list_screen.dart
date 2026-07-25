// lib/admin/screens/city/city_list_screen.dart
import 'package:app/screens/home/city_detail_screen.dart';
import 'package:flutter/material.dart';
import '../../../model/city_model.dart';
import '../../services/city_service.dart';
import '../../widgets/city_tile.dart';
import 'add_city_screen.dart';
import 'edit_city_screen.dart';

class CityListScreen extends StatelessWidget {
  CityListScreen({super.key});

  final CityService cityService = CityService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cities"),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddCityScreen(),
            ),
          );
        },
      ),
      body: StreamBuilder<List<CityModel>>(
        stream: cityService.getCities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 10),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_city, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No Cities Found",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Tap the + button to add a city",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              CityModel city = snapshot.data![index];

              return CityTile(
                city: city,
                onTap: () {
                  // Navigate to city detail
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CityDetailScreen(
                        cityId: city.id,
                        cityName: city.name,
                      ),
                    ),
                  );
                },
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCityScreen(city: city),
                    ),
                  );
                },
                onDelete: () {
                  _showDeleteDialog(context, city);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, CityModel city) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Delete City"),
          content: Text("Delete ${city.name}?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await cityService.deleteCity(city.id);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("City Deleted"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}