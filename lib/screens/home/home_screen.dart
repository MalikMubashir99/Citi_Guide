// lib/screens/home/home_screen.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:app/model/attraction_model.dart';
import 'package:app/model/hotel_model.dart';
import 'package:app/model/restaurant_model.dart';
import 'package:app/model/city_model.dart';
import 'package:app/screens/maps/open_street_map_screen.dart';
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
import 'package:app/widgets/city_card.dart';
import 'package:app/widgets/bottom_navbar.dart';
import 'package:app/screens/profile/favorites_screen.dart';
import 'package:app/screens/home/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final TextEditingController searchController = TextEditingController();
  String userName = "User";

  // Services
  final AttractionService attractionService = AttractionService();
  final HotelService hotelService = HotelService();
  final RestaurantService restaurantService = RestaurantService();
  final EventService eventService = EventService();
  final CityService cityService = CityService();

  // ✅ Page Controller for navigation
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  @override
  void dispose() {
    searchController.dispose();
    _pageController.dispose();
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

  // ✅ Handle navigation
  void _onNavTap(int index) {
    setState(() {
      currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: [
          // ✅ Page 0: Home
          _buildHomeContent(),
          
          // ✅ Page 1: Favorites
          const FavoritesScreen(),
          
          // ✅ Page 2: Search (or Map)
          const SearchScreen(),

          // ✅ Page 3: Map
          const OpenStreetMapScreen(),
          
          // ✅ Page 4: Profile (Placeholder)
          Container(
            color: AppColors.background,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_rounded,
                    size: 80,
                    color: AppColors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Profile Screen',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'User profile will appear here',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: _onNavTap, // ✅ Use the navigation method
      ),
    );
  }

  // ✅ Extract home content to a separate method
  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeAppBar(userName: userName),
            const SizedBox(height: 25),

            SearchBarWidget(controller: searchController),

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
                  onTap: () {
                    // Navigate to places
                  },
                ),
                CategoryCard(
                  icon: Icons.hotel,
                  title: "Hotels",
                  color: Colors.orange,
                  onTap: () {
                    // Navigate to hotels
                  },
                ),
                CategoryCard(
                  icon: Icons.restaurant,
                  title: "Food",
                  color: Colors.green,
                  onTap: () {
                    // Navigate to restaurants
                  },
                ),
                CategoryCard(
                  icon: Icons.event,
                  title: "Events",
                  color: Colors.purple,
                  onTap: () {
                    // Navigate to events
                  },
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                    );
                  }

                  final attractions = snapshot.data ?? [];
                  if (attractions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.landscape_rounded,
                            size: 48,
                            color: AppColors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No attractions available',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Check back later for new places',
                            style: TextStyle(
                              color: AppColors.lightGrey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final validAttractions = attractions.where((item) {
                    return item != null && item.name.isNotEmpty;
                  }).toList();

                  if (validAttractions.isEmpty) {
                    return const Center(
                      child: Text(
                        'No valid attractions found',
                        style: TextStyle(color: AppColors.grey, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: validAttractions.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final attraction = validAttractions[index];
                      return AttractionCard(attraction: attraction);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 35),

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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 40,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading hotels',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${snapshot.error}',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final hotels = snapshot.data ?? [];
                  if (hotels.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.hotel_rounded,
                            size: 48,
                            color: AppColors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No hotels available',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add hotels to Firestore to see them here',
                            style: TextStyle(
                              color: AppColors.lightGrey,
                              fontSize: 13,
                            ),
                          ),
                        ],
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 40,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading restaurants',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                          ),
                        ],
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 40,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading cities',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                          ),
                        ],
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