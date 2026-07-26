// lib/admin/screens/city/city_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:app/admin/models/city_model.dart';
import 'package:app/admin/models/attraction_model.dart';
import 'package:app/admin/models/hotel_model.dart';
import 'package:app/admin/models/restaurant_model.dart'; // ✅ Use admin RestaurantModel
import 'package:app/admin/models/event_model.dart'; // ✅ Use admin EventModel
import 'package:app/admin/services/city_service.dart';
import 'package:app/admin/services/attraction_service.dart';
import 'package:app/admin/services/hotel_service.dart';
import 'package:app/admin/services/restaurant_service.dart';
import 'package:app/admin/services/event_service.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/admin/widgets/attraction_card.dart';
import 'package:app/admin/widgets/hotel_card.dart';
import 'package:app/admin/widgets/restaurant_card.dart';
import 'package:app/admin/widgets/event_card.dart';
import 'edit_city_screen.dart';

class CityDetailScreen extends StatefulWidget {
  final CityModel city;

  const CityDetailScreen({
    super.key,
    required this.city,
  });

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen> {
  final AttractionService _attractionService = AttractionService();
  final HotelService _hotelService = HotelService();
  final RestaurantService _restaurantService = RestaurantService();
  final EventService _eventService = EventService();
  final CityService _cityService = CityService();

  bool _isLoading = false;
  String _selectedTab = 'attractions';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.city.name,
          style: TextStyle(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditCityScreen(city: widget.city),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_rounded, color: AppColors.error),
            onPressed: () => _confirmDelete(),
          ),
        ],
      ),
      body: Column(
        children: [
          // City Header
          _buildCityHeader(),
          
          // Stats
          _buildStats(),
          
          // Tab Bar
          _buildTabBar(),
          
          // Tab Content
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCityHeader() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        image: widget.city.image.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(widget.city.image),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.1),
              Colors.black.withValues(alpha: 0.4),
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.city.name,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.city.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.white.withValues(alpha: 0.85),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey, width: 1),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.landscape_rounded,
            label: 'Attractions',
            count: 0,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.lightGrey,
          ),
          _buildStatItem(
            icon: Icons.hotel_rounded,
            label: 'Hotels',
            count: 0,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.lightGrey,
          ),
          _buildStatItem(
            icon: Icons.restaurant_rounded,
            label: 'Restaurants',
            count: 0,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.lightGrey,
          ),
          _buildStatItem(
            icon: Icons.event_rounded,
            label: 'Events',
            count: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          '0',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.dark,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey, width: 1),
      ),
      child: Row(
        children: [
          _buildTabItem('Attractions', 'attractions', Icons.landscape_rounded),
          _buildTabItem('Hotels', 'hotels', Icons.hotel_rounded),
          _buildTabItem('Restaurants', 'restaurants', Icons.restaurant_rounded),
          _buildTabItem('Events', 'events', Icons.event_rounded),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, String tab, IconData icon) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = tab;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.grey,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'attractions':
        return _buildAttractionsList();
      case 'hotels':
        return _buildHotelsList();
      case 'restaurants':
        return _buildRestaurantsList();
      case 'events':
        return _buildEventsList();
      default:
        return const SizedBox();
    }
  }

  // ✅ Attractions List - Using FutureBuilder
  Widget _buildAttractionsList() {
    return FutureBuilder<List<AttractionModel>>(
      future: _attractionService.getAttractionsByCity(widget.city.id),
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
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: AppColors.error),
            ),
          );
        }

        final attractions = snapshot.data ?? [];
        if (attractions.isEmpty) {
          return _buildEmptyState(
            icon: Icons.landscape_rounded,
            title: 'No Attractions',
            subtitle: 'Add attractions to this city',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: attractions.length,
          itemBuilder: (context, index) {
            final attraction = attractions[index];
            return AttractionCard(
              attraction: attraction,
              onEdit: () {
                // Navigate to edit attraction
              },
              onDelete: () {
                // Delete attraction
              },
            );
          },
        );
      },
    );
  }

  // ✅ Hotels List - Using FutureBuilder
  Widget _buildHotelsList() {
    return FutureBuilder<List<HotelModel>>(
      future: _hotelService.getHotelsByCity(widget.city.id),
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
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: AppColors.error),
            ),
          );
        }

        final hotels = snapshot.data ?? [];
        if (hotels.isEmpty) {
          return _buildEmptyState(
            icon: Icons.hotel_rounded,
            title: 'No Hotels',
            subtitle: 'Add hotels to this city',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: hotels.length,
          itemBuilder: (context, index) {
            final hotel = hotels[index];
            return HotelCard(
              hotel: hotel,
              onEdit: () {
                // Navigate to edit hotel
              },
              onDelete: () {
                // Delete hotel
              },
            );
          },
        );
      },
    );
  }

  // ✅ Restaurants List - Using FutureBuilder with admin RestaurantModel
  Widget _buildRestaurantsList() {
    return FutureBuilder<List<RestaurantModel>>(
      future: _restaurantService.getRestaurantsByCity(widget.city.id),
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
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: AppColors.error),
            ),
          );
        }

        final restaurants = snapshot.data ?? [];
        if (restaurants.isEmpty) {
          return _buildEmptyState(
            icon: Icons.restaurant_rounded,
            title: 'No Restaurants',
            subtitle: 'Add restaurants to this city',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            return RestaurantCard(
              restaurant: restaurant,
              onEdit: () {
                // Navigate to edit restaurant
              },
              onDelete: () {
                // Delete restaurant
              },
            );
          },
        );
      },
    );
  }

  // ✅ Events List - Using FutureBuilder with admin EventModel
  Widget _buildEventsList() {
    return FutureBuilder<List<EventModel>>(
      future: _eventService.getEventsByCity(widget.city.id),
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
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: AppColors.error),
            ),
          );
        }

        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return _buildEmptyState(
            icon: Icons.event_rounded,
            title: 'No Events',
            subtitle: 'Add events to this city',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCard(
              event: event,
              onEdit: () {
                // Navigate to edit event
              },
              onDelete: () {
                // Delete event
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
              icon,
              size: 48,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          'Are you sure you want to delete "${widget.city.name}"? This will also remove all associated data.',
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
              setState(() => _isLoading = true);
              try {
                await _cityService.deleteCity(widget.city.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ ${widget.city.name} deleted successfully'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                Navigator.pop(context);
              } catch (e) {
                if (!mounted) return;
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