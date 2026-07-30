// lib/screens/home/city_detail_screen.dart
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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Modern Blue & Clean Theme matching AttractionDetailScreen
class _AppColors {
  static const Color background = Color(0xFFF8FAFC);
  static const Color white = Colors.white;
  static const Color dark = Color(0xFF0F172A);
  static const Color primary = Color(0xFF2563EB); // Vibrant Modern Blue
  static const Color primaryLight = Color(0xFFEFF6FF); // Light Blue tint
  static const Color error = Color(0xFFDC2626);
  static const Color lightGrey = Color(0xFFE2E8F0);
  static const Color grey = Color(0xFF64748B);
  static const Color star = Color(0xFFF59E0B); // Amber Star
}

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
      backgroundColor: _AppColors.background,
      body: Stack(
        children: [
          // Background Image Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: widget.cityImage == null || widget.cityImage!.isEmpty
                ? Container(
                    height: 340,
                    width: double.infinity,
                    color: _AppColors.lightGrey,
                    child: const Icon(Icons.location_city_rounded,
                        size: 100, color: _AppColors.grey),
                  )
                : CachedNetworkImage(
                    imageUrl: widget.cityImage!,
                    width: double.infinity,
                    height: 340,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 340,
                      color: _AppColors.lightGrey,
                      child: const Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _AppColors.primary),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 340,
                      width: double.infinity,
                      color: _AppColors.lightGrey,
                      child: const Icon(Icons.broken_image,
                          size: 100, color: _AppColors.grey),
                    ),
                  ),
          ),

          // Gradient overlay for header readability
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 340,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),

          // Floating Top Actions (Back and Share)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      print('Back button pressed');
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                    onPressed: () {
                      // Share city logic
                    },
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content Sheet overlapping the header image
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 290),
              child: Container(
                decoration: const BoxDecoration(
                  color: _AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // City Title & Subtitle inside the sheet
                    Text(
                      widget.cityName,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: _AppColors.dark,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Explore the best of ${widget.cityName}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _AppColors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Stats Cards
                    _buildQuickStats(),
                    const SizedBox(height: 24),

                    // Sections
                    attractionSection(),
                    const SizedBox(height: 16),
                    hotelSection(),
                    const SizedBox(height: 16),
                    restaurantSection(),
                    const SizedBox(height: 16),
                    eventSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _AppColors.primary.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.place_rounded,
                      color: _AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cityName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _AppColors.dark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Destination',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7), // Light Amber tint
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _AppColors.star.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.star_rounded,
                      color: _AppColors.star, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '4.9',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Average Rating',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: _AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _AppColors.dark,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _AppColors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              // Navigate to all items
            },
            style: TextButton.styleFrom(
              foregroundColor: _AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'View All',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatePlaceholder(
      {required IconData icon,
      required String title,
      String? subtitle,
      bool isError = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isError ? const Color(0xFFFEE2E2) : _AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isError ? _AppColors.error : _AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: isError ? _AppColors.error : _AppColors.dark,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: _AppColors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
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
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _AppColors.primary),
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
              children: snapshot.data!
                  .map((item) => AttractionCard(attraction: item))
                  .toList(),
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
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _AppColors.primary),
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
              children: snapshot.data!
                  .map((hotel) => HotelCard(hotel: hotel))
                  .toList(),
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
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _AppColors.primary),
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
              children: snapshot.data!
                  .map((restaurant) => RestaurantCard(restaurant: restaurant))
                  .toList(),
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
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _AppColors.primary),
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
              children: snapshot.data!
                  .map((event) => EventCard(event: event))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
