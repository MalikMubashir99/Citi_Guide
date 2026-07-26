// lib/screens/home/home_screen.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:app/model/attraction_model.dart';
import 'package:app/model/hotel_model.dart';
import 'package:app/model/restaurant_model.dart';
import 'package:app/model/city_model.dart';
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

  @override
  void initState() {
    super.initState();
    _getUserName();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                height: 285,
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

                    // ✅ Handle empty data
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

                    // ✅ Filter out null or empty items
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

              // Hotels Section
              const Text(
                "Top Hotels",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),

              SizedBox(
                height: 285,
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
                              'Error: ${snapshot.error}',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hotels found',
                          style: TextStyle(color: AppColors.grey, fontSize: 16),
                        ),
                      );
                    }

                    final hotels = snapshot.data!;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: hotels.length,
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
                height: 285,
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
                              'Error: ${snapshot.error}',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No restaurants found',
                          style: TextStyle(color: AppColors.grey, fontSize: 16),
                        ),
                      );
                    }

                    final restaurants = snapshot.data!;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: restaurants.length,
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
                              'Error: ${snapshot.error}',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No cities found',
                          style: TextStyle(color: AppColors.grey, fontSize: 16),
                        ),
                      );
                    }

                    final cities = snapshot.data!;

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
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
