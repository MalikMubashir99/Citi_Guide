// lib/screens/search/search_screen.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:app/model/attraction_model.dart';
import 'package:app/model/hotel_model.dart';
import 'package:app/model/restaurant_model.dart';
import 'package:app/model/event_model.dart';
import 'package:app/services/attraction_service.dart';
import 'package:app/services/hotel_service.dart';
import 'package:app/services/restaurant_service.dart';
import 'package:app/services/event_service.dart';
import 'package:app/widgets/attraction_card.dart';
import 'package:app/widgets/hotel_card.dart';
import 'package:app/widgets/restaurant_card.dart';
import 'package:app/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool isLoading = false;
  bool isSearching = false;

  // Search results
  List<AttractionModel> attractions = [];
  List<HotelModel> hotels = [];
  List<RestaurantModel> restaurants = [];
  List<EventModel> events = [];

  final AttractionService attractionService = AttractionService();
  final HotelService hotelService = HotelService();
  final RestaurantService restaurantService = RestaurantService();
  final EventService eventService = EventService();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchQuery = "";
        attractions.clear();
        hotels.clear();
        restaurants.clear();
        events.clear();
        isSearching = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      isSearching = true;
      searchQuery = query.toLowerCase().trim();
    });

    try {
      // Fetch all data
      final allAttractions = await attractionService.getAllAttractions();
      final allHotels = await hotelService.getAllHotels();
      final allRestaurants = await restaurantService.getAllRestaurants();
      final allEvents = await eventService.getAllEvents();

      setState(() {
        // Filter attractions
        attractions = allAttractions.where((item) {
          return item.name.toLowerCase().contains(searchQuery) ||
              item.description.toLowerCase().contains(searchQuery);
        }).toList();

        // Filter hotels
        hotels = allHotels.where((item) {
          return item.name.toLowerCase().contains(searchQuery) ||
              item.description.toLowerCase().contains(searchQuery);
        }).toList();

        // Filter restaurants
        restaurants = allRestaurants.where((item) {
          return item.name.toLowerCase().contains(searchQuery) ||
              item.description.toLowerCase().contains(searchQuery);
        }).toList();

        // Filter events
        events = allEvents.where((item) {
          return item.title.toLowerCase().contains(searchQuery) ||
              item.description.toLowerCase().contains(searchQuery);
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error searching: $e',
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Warm Linen
      appBar: AppBar(
        title: Text(
          "Search",
          style: GoogleFonts.poppins(
            color: AppColors.dark,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface, // Pure white
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.lightGrey.withValues(alpha: 0.7), // Flat border
                  width: 1,
                ),
                // Removed shadow for flat design
              ),
              child: TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search attractions, hotels, restaurants...",
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.grey,
                          ),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              searchQuery = "";
                              attractions.clear();
                              hotels.clear();
                              restaurants.clear();
                              events.clear();
                              isSearching = false;
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  performSearch(value);
                },
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Idle State
    if (!isSearching) {
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
              child: const Icon(
                Icons.search_rounded,
                size: 80,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Search for attractions, hotels,\nrestaurants and events",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.darkGrey,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Find the best places in your city",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    // Loading State
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              "Searching...",
              style: GoogleFonts.poppins(
                color: AppColors.darkGrey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final totalResults = attractions.length + hotels.length +
        restaurants.length + events.length;

    // No Results State
    if (totalResults == 0) {
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
              child: const Icon(
                Icons.search_off_rounded,
                size: 80,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "No results found",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try searching with different keywords",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Try: "restaurant", "hotel", "museum"',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Results State
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.trending_up_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  "Found $totalResults results",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Attractions
          if (attractions.isNotEmpty) ...[
            _buildSectionTitle("Attractions", attractions.length),
            ...attractions.map((item) => AttractionCard(attraction: item)),
            const SizedBox(height: 16),
          ],

          // Hotels
          if (hotels.isNotEmpty) ...[
            _buildSectionTitle("Hotels", hotels.length),
            ...hotels.map((item) => HotelCard(hotel: item)),
            const SizedBox(height: 16),
          ],

          // Restaurants
          if (restaurants.isNotEmpty) ...[
            _buildSectionTitle("Restaurants", restaurants.length),
            ...restaurants.map((item) => RestaurantCard(restaurant: item)),
            const SizedBox(height: 16),
          ],

          // Events
          if (events.isNotEmpty) ...[
            _buildSectionTitle("Events", events.length),
            ...events.map((item) => EventCard(event: item)),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              count.toString(),
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}