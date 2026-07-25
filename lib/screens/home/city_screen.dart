import 'package:app/model/city_model.dart';
import 'package:app/screens/home/city_detail_screen.dart';
import 'package:app/services/city_service.dart';
import 'package:flutter/material.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  final CityService service = CityService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select City")),
      body: FutureBuilder<List<CityModel>>(
        future: service.getCities(),
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
                  Text("No Cities Found"),
                ],
              ),
            );
          }

          final cities = snapshot.data!;

          return ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      city.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.broken_image,
                        size: 60,
                      ),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          width: 60,
                          height: 60,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  ),
                  title: Text(city.name),
                  subtitle: Text(city.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CityDetailScreen(
                          cityId: city.id,
                          cityName: city.name,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}