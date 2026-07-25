// lib/screens/search/search_screen.dart
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
          content: Text('Error searching: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Search attractions, hotels, restaurants...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
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
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                performSearch(value);
              },
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            Text(
              "Search for attractions, hotels,\nrestaurants and events",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final totalResults = attractions.length + hotels.length +
        restaurants.length + events.length;

    if (totalResults == 0) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            Text(
              "No results found",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Try searching with different keywords",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Found $totalResults results",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),

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
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}