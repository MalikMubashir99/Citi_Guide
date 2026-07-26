// lib/screens/home/city_detail_screen.dart
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.cityName,
          style: TextStyle(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // City header with image
            _buildCityHeader(),
            
            const SizedBox(height: 16),
            
            // Attractions
            attractionSection(),
            
            // Hotels
            hotelSection(),
            
            // Restaurants
            restaurantSection(),
            
            // Events
            eventSection(),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCityHeader() {
    return Container(
      height: 200,
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.2),
              Colors.black.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_city_rounded,
              color: Colors.white.withValues(alpha: 0.3),
              size: 60,
            ),
            const SizedBox(height: 8),
            Text(
              widget.cityName,
              style: TextStyle(
                fontSize: 36,
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
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
              'Explore the best of ${widget.cityName}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                    letterSpacing: 0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 40,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading attractions',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "No Attractions Found",
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: snapshot.data!.map((item) {
                return AttractionCard(attraction: item);
              }).toList(),
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
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                      color: AppColors.error,
                    ),
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "No Hotels Found",
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: snapshot.data!.map((hotel) {
                return HotelCard(hotel: hotel);
              }).toList(),
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
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                      color: AppColors.error,
                    ),
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "No Restaurants Found",
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: snapshot.data!.map((restaurant) {
                return RestaurantCard(restaurant: restaurant);
              }).toList(),
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
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                      color: AppColors.error,
                    ),
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "No Events Found",
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: snapshot.data!.map((event) {
                return EventCard(event: event);
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}