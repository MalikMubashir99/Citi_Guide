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
import 'package:app/widgets/city_card.dart'; // ✅ This imports the correct CityCard
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/widgets/home_appbar.dart';
import 'package:app/widgets/search_bar_widget.dart';
import 'package:app/widgets/category_card.dart';
import 'package:app/widgets/attraction_card.dart';
import 'package:app/widgets/hotel_card.dart';
import 'package:app/widgets/restaurant_card.dart';
import 'package:app/widgets/event_card.dart';
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
  String userName = "";
  String userImage = "";

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
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            final data = userDoc.data();
            String name = data?['name'] ?? '';
            String image = data?['image'] ?? '';

            if (name.trim().isEmpty) {
              name = user.displayName ?? user.email?.split('@').first ?? "User";
            }

            setState(() {
              userName = name;
              userImage = image;
            });
            return;
          }
        } catch (e) {
          print('Firestore error: $e');
        }

        setState(() {
          userName = user.displayName ?? user.email?.split('@').first ?? "User";
        });
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
  }

  void _onNavTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void refreshUserName() {
    print('🔄 Refreshing user name...');
    _getUserName();
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
    final screens = [
      _buildHomeContent(),
      const SearchScreen(),
      const OpenStreetMapScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isSearching
          ? _buildSearchResults()
          : IndexedStack(index: currentIndex, children: screens),
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
        title: Text('Search Results', style: GoogleFonts.poppins(color: AppColors.dark, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.dark),
          onPressed: _clearSearch,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.close_rounded, color: AppColors.darkGrey), onPressed: _clearSearch),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              controller: searchController,
              onSearch: () => _performSearch(searchController.text),
              onChanged: (value) => _performSearch(value),
            ),
          ),
        ),
      ),
      body: totalResults == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off_rounded, size: 80, color: AppColors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No results found for "$searchQuery"',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try searching with different keywords',
                    style: GoogleFonts.poppins(fontSize: 14, color: AppColors.grey),
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
                    style: GoogleFonts.poppins(fontSize: 16, color: AppColors.darkGrey),
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
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.dark),
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
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Section Header for Home Content
  Widget _buildHomeSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
        letterSpacing: 0.3,
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
            HomeAppBar(userName: userName, profileImage: userImage),
            const SizedBox(height: 25),

            SearchBarWidget(
              controller: searchController,
              onSearch: () => _performSearch(searchController.text),
              onChanged: (value) => _performSearch(value),
            ),

            const SizedBox(height: 30),

            // Categories Section
            _buildHomeSectionHeader("Categories"),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CategoryCard(
                  icon: Icons.place_rounded,
                  title: "Places",
                  color: AppColors.info,
                  onTap: () {},
                ),
                CategoryCard(
                  icon: Icons.hotel_rounded,
                  title: "Hotels",
                  color: AppColors.secondary,
                  onTap: () {},
                ),
                CategoryCard(
                  icon: Icons.restaurant_rounded,
                  title: "Food",
                  color: AppColors.accent,
                  onTap: () {},
                ),
                CategoryCard(
                  icon: Icons.event_rounded,
                  title: "Events",
                  color: AppColors.success,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 35),

            // Popular Attractions Section
            _buildHomeSectionHeader("Popular Attractions"),
            const SizedBox(height: 18),

            SizedBox(
              height: 245,
              child: FutureBuilder<List<AttractionModel>>(
                future: attractionService.getAllAttractions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading attractions', style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w500)));
                  }
                  final attractions = snapshot.data ?? [];
                  if (attractions.isEmpty) {
                    return Center(child: Text('No attractions available', style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 16)));
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: attractions.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      return AttractionCard(attraction: attractions[index]);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 35),

            // Top Hotels Section
            _buildHomeSectionHeader("Top Hotels"),
            const SizedBox(height: 18),

            SizedBox(
              height: 245,
              child: FutureBuilder<List<HotelModel>>(
                future: hotelService.getAllHotels(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading hotels', style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w500)));
                  }
                  final hotels = snapshot.data ?? [];
                  if (hotels.isEmpty) {
                    return Center(child: Text('No hotels available', style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 16)));
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: hotels.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      print('🟢 Building HotelCard for: ${hotels[index].name}');
                      return HotelCard(hotel: hotels[index]);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 35),

            // Restaurants Section
            _buildHomeSectionHeader("Popular Restaurants"),
            const SizedBox(height: 18),

            SizedBox(
              height: 245,
              child: FutureBuilder<List<RestaurantModel>>(
                future: restaurantService.getAllRestaurants(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading restaurants', style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w500)));
                  }
                  final restaurants = snapshot.data ?? [];
                  if (restaurants.isEmpty) {
                    return Center(child: Text('No restaurants found', style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 16)));
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: restaurants.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      return RestaurantCard(restaurant: restaurants[index]);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 35),

            // Events Section
            _buildHomeSectionHeader("Upcoming Events"),
            const SizedBox(height: 18),

            SizedBox(
              height: 260,
              child: FutureBuilder<List<EventModel>>(
                future: eventService.getAllEvents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading events', style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w500)));
                  }
                  final events = snapshot.data ?? [];
                  if (events.isEmpty) {
                    return Center(child: Text('No upcoming events', style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 16)));
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: events.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      return EventCard(event: events[index]);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 35),

            // ✅ FIXED: Top Cities Section
            _buildHomeSectionHeader("Top Cities"),
            const SizedBox(height: 18),

            SizedBox(
              height: 190,
              child: FutureBuilder<List<CityModel>>(
                future: cityService.getCities(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading cities', style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w500)));
                  }
                  final cities = snapshot.data ?? [];
                  if (cities.isEmpty) {
                    return Center(child: Text('No cities found', style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 16)));
                  }
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: cities.map((city) {
                      return CityCard(
                        image: city.image ?? '',
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