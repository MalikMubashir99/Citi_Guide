import 'package:app/core/constants/app_colors.dart';
import 'package:app/model/attraction_model.dart';
import 'package:app/model/event_model.dart';
import 'package:app/model/hotel_model.dart';
import 'package:app/model/restaurant_model.dart';
import 'package:app/services/attraction_service.dart';
import 'package:app/services/event_service.dart';
import 'package:app/services/hotel_service.dart';
import 'package:app/services/restaurant_service.dart';
import 'package:app/widgets/attraction_card.dart';
import 'package:app/widgets/event_card.dart';
import 'package:app/widgets/hotel_card.dart';
import 'package:app/widgets/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CityDetailScreen extends StatefulWidget {
  final String cityId;
  final String cityName;
  final String? cityImage;

  const CityDetailScreen({
    super.key,
    required this.cityId,
    required this.cityName,
    this.cityImage,
  });

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen> {
  final AttractionService attractionService = AttractionService();
  final RestaurantService restaurantService = RestaurantService();
  final EventService eventService = EventService();
  final HotelService hotelService = HotelService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Warm Linen
      appBar: AppBar(
        title: Text(
          widget.cityName,
          style: GoogleFonts.poppins(
            color: AppColors.dark,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.dark),
            onPressed: () {
              // Share city
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCityHeader(),
            const SizedBox(height: 8),
            _buildQuickStats(),
            const SizedBox(height: 8),
            attractionSection(),
            hotelSection(),
            restaurantSection(),
            eventSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCityHeader() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        image: widget.cityImage != null && widget.cityImage!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(widget.cityImage!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          // Cinematic Espresso Gradient Overlay
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.2),
              AppColors.splashOverlayDark.withValues(alpha: 0.7),
              AppColors.splashOverlayDark.withValues(alpha: 0.95),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_city_rounded,
              color: Colors.white.withValues(alpha: 0.2),
              size: 60,
            ),
            const SizedBox(height: 8),
            Text(
              widget.cityName,
              style: GoogleFonts.poppins(
                fontSize: 38,
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 15,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Explore the best of ${widget.cityName}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface, // Pure white
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.lightGrey.withValues(alpha: 0.7), // Subtle warm border
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.place_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    widget.cityName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'City',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.lightGrey.withValues(alpha: 0.7),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.secondary, size: 24), // Warm Sand
                  const SizedBox(height: 4),
                  Text(
                    '4.5',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),
                  Text(
                    'Average Rating',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary, // Cognac accent bar
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                    letterSpacing: 0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to all items
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              'View All',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for consistent empty/error states
  Widget _buildStatePlaceholder({required IconData icon, required String title, String? subtitle, bool isError = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              icon,
              size: isError ? 40 : 48,
              color: isError ? AppColors.error : AppColors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: isError ? AppColors.error : AppColors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: AppColors.lightGrey,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget attractionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          "Popular Attractions",
          subtitle: "Must-visit places in ${widget.cityName}",
        ),
        FutureBuilder<List<AttractionModel>>(
          future: attractionService.getAttractions(widget.cityId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              );
            }
            if (snapshot.hasError) {
              return _buildStatePlaceholder(
                icon: Icons.error_outline_rounded,
                title: 'Error loading attractions',
                isError: true,
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildStatePlaceholder(
                icon: Icons.landscape_rounded,
                title: "No Attractions Found",
                subtitle: "Check back later for new places",
              );
            }
            return Column(
              children: snapshot.data!.map((item) => AttractionCard(attraction: item)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget hotelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          "Hotels",
          subtitle: "Best places to stay in ${widget.cityName}",
        ),
        StreamBuilder<List<HotelModel>>(
          stream: hotelService.getHotelsByCity(widget.cityId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              );
            }
            if (snapshot.hasError) {
              return _buildStatePlaceholder(
                icon: Icons.error_outline_rounded,
                title: 'Error loading hotels',
                isError: true,
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildStatePlaceholder(
                icon: Icons.hotel_rounded,
                title: "No Hotels Found",
              );
            }
            return Column(
              children: snapshot.data!.map((hotel) => HotelCard(hotel: hotel)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget restaurantSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          "Restaurants",
          subtitle: "Dining experiences in ${widget.cityName}",
        ),
        StreamBuilder<List<RestaurantModel>>(
          stream: restaurantService.getRestaurantsByCity(widget.cityId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              );
            }
            if (snapshot.hasError) {
              return _buildStatePlaceholder(
                icon: Icons.error_outline_rounded,
                title: 'Error loading restaurants',
                isError: true,
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildStatePlaceholder(
                icon: Icons.restaurant_rounded,
                title: "No Restaurants Found",
              );
            }
            return Column(
              children: snapshot.data!.map((restaurant) => RestaurantCard(restaurant: restaurant)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget eventSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          "Upcoming Events",
          subtitle: "Events happening in ${widget.cityName}",
        ),
        StreamBuilder<List<EventModel>>(
          stream: eventService.getEventsByCity(widget.cityId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              );
            }
            if (snapshot.hasError) {
              return _buildStatePlaceholder(
                icon: Icons.error_outline_rounded,
                title: 'Error loading events',
                isError: true,
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildStatePlaceholder(
                icon: Icons.event_rounded,
                title: "No Events Found",
              );
            }
            return Column(
              children: snapshot.data!.map((event) => EventCard(event: event)).toList(),
            );
          },
        ),
      ],
    );
  }
}
