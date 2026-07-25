import 'package:flutter/material.dart';

import '../../../model/city_model.dart';
import '../../services/city_service.dart';
import 'add_city_screen.dart';
import 'edit_city_screen.dart';

class CityListScreen extends StatelessWidget {
  CityListScreen({super.key});

  final CityService cityService = CityService();

  @override
  Widget build(BuildContext context) {
    Future<void> showDeleteDialog(CityModel city) async {
      showDialog(
        context: context,

        builder: (_) {
          return AlertDialog(
            title: const Text("Delete City"),

            content: Text("Delete ${city.name} ?"),

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

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("City Deleted")));
                },

                child: const Text("Delete"),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Cities")),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCityScreen()),
          );
        },
      ),

      body: StreamBuilder<List<CityModel>>(
        stream: cityService.getCities(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Cities Found"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,

            itemBuilder: (context, index) {
              CityModel city = snapshot.data![index];

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(city.image),
                  ),

                  title: Text(city.name),

                  subtitle: Text(city.description),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),

                        onPressed: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) => EditCityScreen(city: city),
                            ),
                          );
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),

                        onPressed: () {
                          showDeleteDialog(city);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
