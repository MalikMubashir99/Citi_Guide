// lib/screens/home/home_screen.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:app/model/attraction_model.dart';
import 'package:app/model/hotel_model.dart';
import 'package:app/model/restaurant_model.dart';
import 'package:app/model/event_model.dart';
import 'package:app/model/city_model.dart';
import 'package:app/screens/home/search_screen.dart';
import 'package:app/screens/maps/open_street_map_screen.dart';
import 'package:app/screens/profile/profile_screen.dart';
import 'package:app/services/attraction_service.dart';
import 'package:app/services/hotel_service.dart';
import 'package:app/services/restaurant_service.dart';
import 'package:app/services/event_service.dart';
import 'package:app/services/city_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/home_appbar.dart';
import 'package:app/widgets/search_bar_widget.dart';
import 'package:app/widgets/category_card.dart';
import 'package:app/widgets/attraction_card.dart';
import 'package:app/widgets/hotel_card.dart';
import 'package:app/widgets/restaurant_card.dart';
import 'package:app/widgets/event_card.dart';
import 'package:app/widgets/city_card.dart';
import 'package:app/widgets/bottom_navbar.dart';
import 'package:app/screens/profile/favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final TextEditingController searchController = TextEditingController();
  String userName = "User";

  // ✅ Search state
  bool isSearching = false;
  String searchQuery = "";
  
  // ✅ Search results
  List<AttractionModel> searchAttractions = [];
  List<HotelModel> searchHotels = [];
  List<RestaurantModel> searchRestaurants = [];
  List<EventModel> searchEvents = [];

  // Services
  final AttractionService attractionService = AttractionService();
  final HotelService hotelService = HotelService();
  final RestaurantService restaurantService = RestaurantService();
  final EventService eventService = EventService();
  final CityService cityService = CityService();

  // ✅ Screens list
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _getUserName();
    
    // ✅ Initialize screens
    _screens = [
      _buildHomeContent(),
      const FavoritesScreen(),
      const SearchScreen(),
      const OpenStreetMapScreen(),  // Map screen
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? user.email?.split('@').first ?? "User";
      });
    }
  }

  void _onNavTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  // ✅ Search Logic
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        isSearching = false;
        searchQuery = "";
        searchAttractions.clear();
        searchHotels.clear();
        searchRestaurants.clear();
        searchEvents.clear();
      });
      return;
    }

    setState(() {
      isSearching = true;
      searchQuery = query.trim().toLowerCase();
    });

    try {
      final results = await Future.wait([
        attractionService.getAllAttractions(),
        hotelService.getAllHotels(),
        restaurantService.getAllRestaurants(),
        eventService.getAllEvents(),
      ]);

      final allAttractions = results[0] as List<AttractionModel>;
      final allHotels = results[1] as List<HotelModel>;
      final allRestaurants = results[2] as List<RestaurantModel>;
      final allEvents = results[3] as List<EventModel>;

      setState(() {
        searchAttractions = allAttractions.where((item) {
          return item.name.toLowerCase().contains(searchQuery) ||
              item.description.toLowerCase().contains(searchQuery);
        }).toList();

        searchHotels = allHotels.where((item) {
          return item.name.toLowerCase().contains(searchQuery) ||
              item.description.toLowerCase().contains(searchQuery);
        }).toList();

        searchRestaurants = allRestaurants.where((item) {
          return item.name.toLowerCase().contains(searchQuery) ||
              item.description.toLowerCase().contains(searchQuery);
        }).toList();

        searchEvents = allEvents.where((item) {
          return item.title.toLowerCase().contains(searchQuery) ||
              item.description.toLowerCase().contains(searchQuery);
        }).toList();
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        isSearching = false;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      isSearching = false;
      searchQuery = "";
      searchAttractions.clear();
      searchHotels.clear();
      searchRestaurants.clear();
      searchEvents.clear();
    });
    searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isSearching 
          ? _buildSearchResults()
          : IndexedStack(  // ✅ Use IndexedStack instead of PageView
              index: currentIndex,
              children: _screens,
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  // ✅ Build Search Results
  Widget _buildSearchResults() {
    final totalResults = searchAttractions.length + 
                         searchHotels.length + 
                         searchRestaurants.length + 
                         searchEvents.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Results'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _clearSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _clearSearch,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              controller: searchController,
              onSearch: () {
                _performSearch(searchController.text);
              },
              onChanged: (value) {
                _performSearch(value);
              },
            ),
          ),
        ),
      ),
      body: totalResults == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 80,
                    color: AppColors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No results found for "$searchQuery"',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try searching with different keywords',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Found $totalResults results for "$searchQuery"',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (searchAttractions.isNotEmpty) ...[
                    _buildResultSection('Attractions', searchAttractions.length),
                    ...searchAttractions.map((item) => AttractionCard(attraction: item)),
                    const SizedBox(height: 16),
                  ],

                  if (searchHotels.isNotEmpty) ...[
                    _buildResultSection('Hotels', searchHotels.length),
                    ...searchHotels.map((item) => HotelCard(hotel: item)),
                    const SizedBox(height: 16),
                  ],

                  if (searchRestaurants.isNotEmpty) ...[
                    _buildResultSection('Restaurants', searchRestaurants.length),
                    ...searchRestaurants.map((item) => RestaurantCard(restaurant: item)),
                    const SizedBox(height: 16),
                  ],

                  if (searchEvents.isNotEmpty) ...[
                    _buildResultSection('Events', searchEvents.length),
                    ...searchEvents.map((item) => EventCard(event: item)),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildResultSection(String title, int count) {
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
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Home Content
  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeAppBar(userName: userName),
            const SizedBox(height: 25),

            SearchBarWidget(
              controller: searchController,
              onSearch: () {
                _performSearch(searchController.text);
              },
              onChanged: (value) {
                _performSearch(value);
              },
            ),

            const SizedBox(height: 30),

            // Categories Section
            const Text(
              "Categories",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CategoryCard(
                  icon: Icons.place,
                  title: "Places",
                  color: Colors.blue,
                  onTap: () {},
                ),
                CategoryCard(
                  icon: Icons.hotel,
                  title: "Hotels",
                  color: Colors.orange,
                  onTap: () {},
                ),
                CategoryCard(
                  icon: Icons.restaurant,
                  title: "Food",
                  color: Colors.green,
                  onTap: () {},
                ),
                CategoryCard(
                  icon: Icons.event,
                  title: "Events",
                  color: Colors.purple,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 35),

            // Popular Attractions Section
            const Text(
              "Popular Attractions",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),

            SizedBox(
              height: 245,
              child: FutureBuilder<List<AttractionModel>>(
                future: attractionService.getAllAttractions(),
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
                        'Error loading attractions',
                        style: TextStyle(color: AppColors.error),
                      ),
                    );
                  }

                  final attractions = snapshot.data ?? [];
                  if (attractions.isEmpty) {
                    return const Center(
                      child: Text(
                        'No attractions available',
                        style: TextStyle(color: AppColors.grey, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: attractions.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final attraction = attractions[index];
                      return AttractionCard(attraction: attraction);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 35),

            // Top Hotels Section
            const Text(
              "Top Hotels",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),

            SizedBox(
              height: 245,
              child: FutureBuilder<List<HotelModel>>(
                future: hotelService.getAllHotels(),
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
                        'Error loading hotels',
                        style: TextStyle(color: AppColors.error),
                      ),
                    );
                  }

                  final hotels = snapshot.data ?? [];
                  if (hotels.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hotels available',
                        style: TextStyle(color: AppColors.grey, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: hotels.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final hotel = hotels[index];
                      return HotelCard(hotel: hotel);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 35),

            // Restaurants Section
            const Text(
              "Popular Restaurants",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),

            SizedBox(
              height: 245,
              child: FutureBuilder<List<RestaurantModel>>(
                future: restaurantService.getAllRestaurants(),
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
                        'Error loading restaurants',
                        style: TextStyle(color: AppColors.error),
                      ),
                    );
                  }

                  final restaurants = snapshot.data ?? [];
                  if (restaurants.isEmpty) {
                    return const Center(
                      child: Text(
                        'No restaurants found',
                        style: TextStyle(color: AppColors.grey, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: restaurants.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      return RestaurantCard(restaurant: restaurant);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 35),

            // Events Section
            const Text(
              "Upcoming Events",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),

            SizedBox(
              height: 200,
              child: FutureBuilder<List<EventModel>>(
                future: eventService.getAllEvents(),
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
                        'Error loading events',
                        style: TextStyle(color: AppColors.error),
                      ),
                    );
                  }

                  final events = snapshot.data ?? [];
                  if (events.isEmpty) {
                    return const Center(
                      child: Text(
                        'No upcoming events',
                        style: TextStyle(color: AppColors.grey, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: events.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return EventCard(event: event);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 35),

            // Top Cities Section
            const Text(
              "Top Cities",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),

            SizedBox(
              height: 190,
              child: FutureBuilder<List<CityModel>>(
                future: cityService.getCities(),
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
                        'Error loading cities',
                        style: TextStyle(color: AppColors.error),
                      ),
                    );
                  }

                  final cities = snapshot.data ?? [];
                  if (cities.isEmpty) {
                    return const Center(
                      child: Text(
                        'No cities found',
                        style: TextStyle(color: AppColors.grey, fontSize: 16),
                      ),
                    );
                  }

                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: cities.map((city) {
                      return CityCard(
                        image: city.image,
                        city: city.name,
                        cityId: city.id,
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}