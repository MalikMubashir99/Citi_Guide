// lib/admin/screens/hotel/hotels_screen.dart
import 'package:app/admin/models/hotel_model.dart';
import 'package:app/admin/services/hotel_service.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'add_hotel_screen.dart';
import '../../widgets/hotel_card.dart';

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  final HotelService _hotelService = HotelService();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Hotels'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search hotels...',
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, color: AppColors.grey),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),

          // Hotel List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : StreamBuilder<List<HotelModel>>(
                    // ✅ FIXED: Use getHotelsStream
                    stream: _hotelService.getHotelsStream(),
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
                                'Error loading hotels',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      var hotels = snapshot.data ?? [];

                      if (_searchQuery.isNotEmpty) {
                        hotels = hotels.where((hotel) {
                          return hotel.name.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ) ||
                              hotel.cityId.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              );
                        }).toList();
                      }

                      if (hotels.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.hotel_rounded,
                                size: 64,
                                color: AppColors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No hotels found matching "$_searchQuery"'
                                    : 'No hotels available',
                                style: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_searchQuery.isNotEmpty)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                  child: const Text('Clear Search'),
                                ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: hotels.length,
                        itemBuilder: (context, index) {
                          final hotel = hotels[index];
                          return HotelCard(
                            hotel: hotel,
                            onEdit: () => _showAddEditDialog(hotel: hotel),
                            onDelete: () => _confirmDelete(hotel),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddEditDialog({HotelModel? hotel}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddHotelScreen(
          hotel: hotel,
          onSave: () {
            setState(() {});
          },
        ),
      ),
    );
  }

  void _confirmDelete(HotelModel hotel) {
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
                await _hotelService.deleteHotel(hotel.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ ${hotel.name} deleted successfully'),
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
                    content: Text('❌ Error deleting hotel: $e'),
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
