// lib/admin/screens/city/city_list_screen.dart
import 'package:app/admin/models/city_model.dart';
import 'package:app/admin/screens/city/city_detail_screen.dart';
import 'package:app/admin/services/city_service.dart';
import 'package:app/admin/widgets/city_tile.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'add_city_screen.dart';
import 'edit_city_screen.dart';

class CityListScreen extends StatelessWidget {
  CityListScreen({super.key});

  final CityService cityService = CityService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Cities",
          style: TextStyle(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
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
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 60,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading cities',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Retry logic
                    },
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: AppColors.white,
                      size: 18,
                    ),
                    label: const Text("Retry"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_city_rounded,
                      size: 80,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No Cities Found",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap the + button to add a city",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
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
                  // ✅ Fix: Pass the city object directly
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CityDetailScreen(
                        city: city, // ✅ Use 'city' parameter
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
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_rounded, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                'Delete City',
                style: TextStyle(
                  color: AppColors.dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${city.name}"? This action cannot be undone.',
            style: TextStyle(color: AppColors.darkGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await cityService.deleteCity(city.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ ${city.name} deleted successfully'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error deleting city: $e'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}