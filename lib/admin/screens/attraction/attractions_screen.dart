// lib/admin/screens/attraction/attractions_screen.dart
import 'package:app/admin/models/attraction_model.dart';
import 'package:app/admin/models/city_model.dart';
import 'package:app/admin/services/attraction_service.dart';
import 'package:app/admin/services/city_service.dart';
import 'package:app/admin/widgets/attraction_card.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'add_attraction_screen.dart';
import 'edit_attraction_screen.dart';

class AttractionsScreen extends StatefulWidget {
  const AttractionsScreen({super.key});

  @override
  State<AttractionsScreen> createState() => _AttractionsScreenState();
}

class _AttractionsScreenState extends State<AttractionsScreen> {
  final AttractionService attractionService = AttractionService();
  final CityService cityService = CityService();

  final TextEditingController searchController = TextEditingController();
  String searchText = "";
  String? selectedCity;
  bool _isLoading = false; 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Attractions"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddAttractionScreen()),
          );
        },
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Attraction",
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
          ),
          // City filter dropdown
          StreamBuilder<List<CityModel>>(
            stream: cityService.getCities(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: DropdownButtonFormField<String>(
                  initialValue: selectedCity,
                  decoration: InputDecoration(
                    labelText: "Filter by City",
                    labelStyle: TextStyle(color: AppColors.darkGrey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text("All Cities"),
                    ),
                    ...snapshot.data!.map((city) {
                      return DropdownMenuItem<String>(
                        value: city.id,
                        child: Text(city.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                    });
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          // Attractions list
          Expanded(
            child: StreamBuilder<List<AttractionModel>>(
              stream: attractionService.getAttractions(),
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
                          'Error loading attractions',
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
                          Icons.landscape_rounded,
                          size: 64,
                          color: AppColors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No Attractions",
                          style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tap the + button to add an attraction",
                          style: TextStyle(color: AppColors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                // ✅ Combined filter: search + city
                final filteredAttractions = snapshot.data!.where((item) {
                  bool matchesSearch = item.name.toLowerCase().contains(
                    searchText,
                  );

                  bool matchesCity =
                      selectedCity == null || item.cityId == selectedCity;

                  return matchesSearch && matchesCity;
                }).toList();

                if (filteredAttractions.isEmpty) {
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
                          "No matching attractions",
                          style: TextStyle(color: AppColors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                // ✅ Sort by rating (highest first)
                final sortedAttractions = List.from(filteredAttractions);
                sortedAttractions.sort((a, b) => b.rating.compareTo(a.rating));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sortedAttractions.length,
                  itemBuilder: (context, index) {
                    final attraction = sortedAttractions[index];
                    return AttractionCard(
                      attraction: attraction,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditAttractionScreen(attraction: attraction),
                          ),
                        );
                      },
                      onDelete: () {
                        _confirmDelete(attraction);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(AttractionModel attraction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              'Delete Attraction',
              style: TextStyle(
                color: AppColors.dark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${attraction.name}"? This action cannot be undone.',
          style: TextStyle(color: AppColors.darkGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              // ✅ Close dialog immediately
              Navigator.pop(context);

              // ✅ Show loading state
              setState(() => _isLoading = true);

              try {
                await attractionService.deleteAttraction(attraction.id);

                if (!mounted) return;

                // ✅ Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ ${attraction.name} deleted successfully'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );

                // ✅ Refresh the list
                setState(() {});
              } catch (e) {
                if (!mounted) return;

                // ✅ Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error deleting attraction: $e'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
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
