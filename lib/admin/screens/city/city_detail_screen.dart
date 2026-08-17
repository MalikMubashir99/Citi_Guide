// lib/admin/screens/city/city_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/admin/models/city_model.dart';
import 'package:app/admin/models/attraction_model.dart';
import 'package:app/admin/models/hotel_model.dart';
import 'package:app/admin/models/restaurant_model.dart';
import 'package:app/admin/models/event_model.dart';
import 'package:app/admin/services/city_service.dart';
import 'package:app/admin/services/attraction_service.dart';
import 'package:app/admin/services/hotel_service.dart';
import 'package:app/admin/services/restaurant_service.dart';
import 'package:app/admin/services/event_service.dart';
import 'package:app/admin/widgets/attraction_card.dart';
import 'package:app/admin/widgets/hotel_card.dart';
import 'package:app/admin/widgets/restaurant_card.dart';
import 'package:app/admin/widgets/event_card.dart';
import 'edit_city_screen.dart';

// ── Direct colors ──
class _AdminColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color dark = Color(0xFF0F172A);
  static const Color darkGrey = Color(0xFF334155);
  static const Color grey = Color(0xFF64748B);
  static const Color lightGrey = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF10B981);
}

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
  int _attractionCount = 0;
  int _hotelCount = 0;
  int _restaurantCount = 0;
  int _eventCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final results = await Future.wait([
      _attractionService.getAttractionsByCity(widget.city.id),
      _hotelService.getHotelsByCity(widget.city.id),
      _restaurantService.getRestaurantsByCity(widget.city.id),
      _eventService.getEventsByCity(widget.city.id),
    ]);

    setState(() {
      _attractionCount = (results[0] as List).length;
      _hotelCount = (results[1] as List).length;
      _restaurantCount = (results[2] as List).length;
      _eventCount = (results[3] as List).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AdminColors.background,
      appBar: AppBar(
        title: Text(
          widget.city.name,
          style: GoogleFonts.poppins(
            color: _AdminColors.dark,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: _AdminColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _AdminColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: _AdminColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditCityScreen(city: widget.city),
                ),
              ).then((_) => setState(() {}));
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_rounded, color: _AdminColors.error),
            onPressed: () => _confirmDelete(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── City Header ──
          _buildCityHeader(),
          // ── Stats ──
          _buildStats(),
          // ── Tab Bar ──
          _buildTabBar(),
          // ── Tab Content ──
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
        color: _AdminColors.primary,
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
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.4),
              Colors.black.withOpacity(0.7),
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
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _AdminColors.white,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.city.description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: _AdminColors.white.withOpacity(0.85),
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
        color: _AdminColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AdminColors.lightGrey.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.landscape_rounded,
            label: 'Attractions',
            count: _attractionCount,
          ),
          Container(
            width: 1,
            height: 40,
            color: _AdminColors.lightGrey,
          ),
          _buildStatItem(
            icon: Icons.hotel_rounded,
            label: 'Hotels',
            count: _hotelCount,
          ),
          Container(
            width: 1,
            height: 40,
            color: _AdminColors.lightGrey,
          ),
          _buildStatItem(
            icon: Icons.restaurant_rounded,
            label: 'Restaurants',
            count: _restaurantCount,
          ),
          Container(
            width: 1,
            height: 40,
            color: _AdminColors.lightGrey,
          ),
          _buildStatItem(
            icon: Icons.event_rounded,
            label: 'Events',
            count: _eventCount,
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
        Icon(icon, color: _AdminColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _AdminColors.dark,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: _AdminColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      {'key': 'attractions', 'icon': Icons.landscape_rounded, 'label': 'Attractions'},
      {'key': 'hotels', 'icon': Icons.hotel_rounded, 'label': 'Hotels'},
      {'key': 'restaurants', 'icon': Icons.restaurant_rounded, 'label': 'Restaurants'},
      {'key': 'events', 'icon': Icons.event_rounded, 'label': 'Events'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _AdminColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _AdminColors.lightGrey.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTab == tab['key'];
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = tab['key'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? _AdminColors.primaryLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      color: isSelected ? _AdminColors.primary : _AdminColors.grey,
                      size: 20,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tab['label'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? _AdminColors.primary : _AdminColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
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

  Widget _buildAttractionsList() {
    return FutureBuilder<List<AttractionModel>>(
      future: _attractionService.getAttractionsByCity(widget.city.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _AdminColors.primary,
            ),
          );
        }
        if (snapshot.hasError) {
          return _buildErrorState('Error loading attractions');
        }
        final attractions = snapshot.data ?? [];
        if (attractions.isEmpty) {
          return _buildEmptyState(Icons.landscape_rounded, 'No Attractions', 'Add attractions to this city');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: attractions.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AttractionCard(
                attraction: attractions[index],
                onEdit: () {},
                onDelete: () {},
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHotelsList() {
    return FutureBuilder<List<HotelModel>>(
      future: _hotelService.getHotelsByCity(widget.city.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _AdminColors.primary,
            ),
          );
        }
        if (snapshot.hasError) {
          return _buildErrorState('Error loading hotels');
        }
        final hotels = snapshot.data ?? [];
        if (hotels.isEmpty) {
          return _buildEmptyState(Icons.hotel_rounded, 'No Hotels', 'Add hotels to this city');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: hotels.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HotelCard(
                hotel: hotels[index],
                onEdit: () {},
                onDelete: () {},
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRestaurantsList() {
    return FutureBuilder<List<RestaurantModel>>(
      future: _restaurantService.getRestaurantsByCity(widget.city.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _AdminColors.primary,
            ),
          );
        }
        if (snapshot.hasError) {
          return _buildErrorState('Error loading restaurants');
        }
        final restaurants = snapshot.data ?? [];
        if (restaurants.isEmpty) {
          return _buildEmptyState(Icons.restaurant_rounded, 'No Restaurants', 'Add restaurants to this city');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RestaurantCard(
                restaurant: restaurants[index],
                onEdit: () {},
                onDelete: () {},
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventsList() {
    return FutureBuilder<List<EventModel>>(
      future: _eventService.getEventsByCity(widget.city.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _AdminColors.primary,
            ),
          );
        }
        if (snapshot.hasError) {
          return _buildErrorState('Error loading events');
        }
        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return _buildEmptyState(Icons.event_rounded, 'No Events', 'Add events to this city');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EventCard(
                event: events[index],
                onEdit: () {},
                onDelete: () {},
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _AdminColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: _AdminColors.primary.withOpacity(0.5)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: _AdminColors.dark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                color: _AdminColors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _AdminColors.error.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: 48, color: _AdminColors.error),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.poppins(
                color: _AdminColors.dark,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _AdminColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _AdminColors.error.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline_rounded, size: 40, color: _AdminColors.error),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete City',
                style: GoogleFonts.poppins(
                  color: _AdminColors.dark,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete "${widget.city.name}"?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: _AdminColors.darkGrey,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              Text(
                'This will also remove all associated data.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: _AdminColors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          color: _AdminColors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        setState(() => _isLoading = true);
                        try {
                          await _cityService.deleteCity(widget.city.id);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✅ ${widget.city.name} deleted successfully',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: _AdminColors.success,
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
                              content: Text('❌ Error: $e', style: GoogleFonts.poppins()),
                              backgroundColor: _AdminColors.error,
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
                        backgroundColor: _AdminColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}