// lib/admin/screens/restaurant/restaurants_screen.dart
// Use RestaurantCard from admin widgets instead of the user one

import 'package:app/admin/models/restaurant_model.dart';
import 'package:app/admin/services/restaurant_service.dart';
import 'package:app/admin/widgets/restaurant_card.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'add_restaurant_screen.dart';
import 'edit_restaurant_screen.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  final RestaurantService restaurantService = RestaurantService();
  String searchText = "";
  bool _isLoading = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Restaurants"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRestaurantScreen()),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search Restaurant",
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: AppColors.white,
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 20),
            // Restaurants List
            Expanded(
              child: StreamBuilder<List<RestaurantModel>>(
                stream: restaurantService.getRestaurants(),
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
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading restaurants',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 16,
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
                          Icon(
                            Icons.restaurant_rounded,
                            size: 64,
                            color: AppColors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No Restaurants Found",
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Tap the + button to add a restaurant",
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final restaurants = snapshot.data!.where((item) {
                    return item.name.toLowerCase().contains(searchText);
                  }).toList();

                  if (restaurants.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: AppColors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "No matching restaurants",
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      return RestaurantCard(
                        restaurant: restaurant,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditRestaurantScreen(
                                restaurant: restaurant,
                              ),
                            ),
                          );
                        },
                        onDelete: () {
                          _confirmDelete(restaurant);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
void _confirmDelete(RestaurantModel restaurant) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      // ... dialog content
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: AppColors.grey)),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            setState(() => _isLoading = true);
            try {
              await restaurantService.deleteRestaurant(restaurant.id);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ ${restaurant.name} deleted successfully'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              setState(() {});
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Error deleting restaurant: $e'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            } finally {
              if (mounted) setState(() => _isLoading = false);
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
    ),
  );
}
}