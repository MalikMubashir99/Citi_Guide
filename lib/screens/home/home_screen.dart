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
import 'package:app/widgets/city_card.dart';
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

// ─── Local Blue Theme ──────────────────────────────────────────────────────────
class _AppColors {
  static const Color background = Color(0xFFF8FAFC);
  static const Color white = Colors.white;
  static const Color dark = Color(0xFF0F172A);
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color error = Color(0xFFDC2626);
  static const Color lightGrey = Color(0xFFE2E8F0);
  static const Color grey = Color(0xFF64748B);
  static const Color star = Color(0xFFF59E0B);
}

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

  bool isSearching = false;
  String searchQuery = "";

  List<AttractionModel> searchAttractions = [];
  List<HotelModel> searchHotels = [];
  List<RestaurantModel> searchRestaurants = [];
  List<EventModel> searchEvents = [];

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
    _getUserName();
  }

  // ─── Search Logic ──────────────────────────────────────────────────────────

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

  // ─── Build ──────────────────────────────────────────────────────────────────

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
      backgroundColor: _AppColors.background,
      body: isSearching
          ? _buildSearchResults()
          : IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  // ─── Search Results Screen (unchanged) ─────────────────────────────────────

  Widget _buildSearchResults() {
    final totalResults = searchAttractions.length +
        searchHotels.length +
        searchRestaurants.length +
        searchEvents.length;

    return Scaffold(
      backgroundColor: _AppColors.background,
      appBar: AppBar(
        title: Text(
          'Search Results',
          style: GoogleFonts.poppins(
            color: _AppColors.dark,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: _AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _AppColors.dark),
          onPressed: _clearSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: _AppColors.grey),
            onPressed: _clearSearch,
          ),
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
                  const Icon(
                    Icons.search_off_rounded,
                    size: 80,
                    color: _AppColors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No results found for "$searchQuery"',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: _AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try searching with different keywords',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _AppColors.grey,
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
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: _AppColors.grey,
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
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _AppColors.dark,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: _AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: GoogleFonts.poppins(
                color: _AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── NEW HOME CONTENT (all sections) ─────────────────────────────────────

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting ──────────────────────────────────────────────────────
            Row(
              children: [
                Text(
                  'Good morning',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: _AppColors.grey,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  userName.isNotEmpty ? userName : 'User',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _AppColors.dark,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('🌟', style: TextStyle(fontSize: 22)),
              ],
            ),
            const SizedBox(height: 8),

            // ── Location ────────────────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    color: _AppColors.primary, size: 18),
                const SizedBox(width: 4),
                Text(
                  'Paris, France', // You can make this dynamic later
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _AppColors.dark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Search Bar ──────────────────────────────────────────────────
            SearchBarWidget(
              controller: searchController,
              onSearch: () => _performSearch(searchController.text),
              onChanged: (value) => _performSearch(value),
            ),
            const SizedBox(height: 30),

            // ── Popular Destinations ────────────────────────────────────────
            _buildSectionHeader('Popular Destinations', seeAll: true),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: FutureBuilder<List<CityModel>>(
                future: cityService.getCities(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(
                        strokeWidth: 2, color: _AppColors.primary));
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final cities = snapshot.data!;
                  if (cities.isEmpty) return const SizedBox.shrink();
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: cities.length > 4 ? 4 : cities.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final city = cities[index];
                      return _DestinationCard(city: city);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // ── Categories ──────────────────────────────────────────────────
            _buildSectionHeader('Categories', seeAll: false),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _CategoryItem(icon: Icons.place_rounded, label: 'Attractions'),
                _CategoryItem(icon: Icons.restaurant_rounded, label: 'Restaurants'),
                _CategoryItem(icon: Icons.hotel_rounded, label: 'Hotels'),
                _CategoryItem(icon: Icons.event_rounded, label: 'Events'),
              ],
            ),
            const SizedBox(height: 30),

            // ── Popular Nearby (Attractions) ──────────────────────────────
            _buildSectionHeader('Popular Nearby', seeAll: true),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: FutureBuilder<List<AttractionModel>>(
                future: attractionService.getAllAttractions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(
                        strokeWidth: 2, color: _AppColors.primary));
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final attractions = snapshot.data!;
                  if (attractions.isEmpty) return const SizedBox.shrink();
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: attractions.length > 4 ? 4 : attractions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final attraction = attractions[index];
                      return _NearbyCard(attraction: attraction);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // ── Top Hotels ──────────────────────────────────────────────────
            _buildSectionHeader('Top Hotels', seeAll: true),
            const SizedBox(height: 16),
            SizedBox(
              height: 245,
              child: FutureBuilder<List<HotelModel>>(
                future: hotelService.getAllHotels(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(
                        strokeWidth: 2, color: _AppColors.primary));
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final hotels = snapshot.data!;
                  if (hotels.isEmpty) return const SizedBox.shrink();
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: hotels.length > 4 ? 4 : hotels.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return HotelCard(hotel: hotels[index]);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // ── Popular Restaurants ─────────────────────────────────────────
            _buildSectionHeader('Popular Restaurants', seeAll: true),
            const SizedBox(height: 16),
            SizedBox(
              height: 245,
              child: FutureBuilder<List<RestaurantModel>>(
                future: restaurantService.getAllRestaurants(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(
                        strokeWidth: 2, color: _AppColors.primary));
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final restaurants = snapshot.data!;
                  if (restaurants.isEmpty) return const SizedBox.shrink();
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: restaurants.length > 4 ? 4 : restaurants.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return RestaurantCard(restaurant: restaurants[index]);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // ── Upcoming Events ─────────────────────────────────────────────
            _buildSectionHeader('Upcoming Events', seeAll: true),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: FutureBuilder<List<EventModel>>(
                future: eventService.getAllEvents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(
                        strokeWidth: 2, color: _AppColors.primary));
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final events = snapshot.data!;
                  if (events.isEmpty) return const SizedBox.shrink();
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: events.length > 4 ? 4 : events.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return EventCard(event: events[index]);
                    },
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

  // ─── Helper: Section Header with optional "See all" ──────────────────────

  Widget _buildSectionHeader(String title, {bool seeAll = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _AppColors.dark,
          ),
        ),
        if (seeAll)
          Text(
            'See all',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _AppColors.primary,
            ),
          ),
      ],
    );
  }
}

// ─── Destination Card (for Popular Destinations) ────────────────────────────

class _DestinationCard extends StatelessWidget {
  final CityModel city;
  const _DestinationCard({required this.city});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: city.image != null && city.image!.isNotEmpty
              ? NetworkImage(city.image!)
              : const AssetImage('assets/default_city.jpg') as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: _AppColors.star, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '4.9', // static rating – can be dynamic if you have it
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Item ────────────────────────────────────────────────────────────

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CategoryItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: _AppColors.primary, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _AppColors.dark,
          ),
        ),
      ],
    );
  }
}

// ─── Nearby Card (for Popular Nearby) ────────────────────────────────────────

class _NearbyCard extends StatelessWidget {
  final AttractionModel attraction;
  const _NearbyCard({required this.attraction});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      decoration: BoxDecoration(
        color: _AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: attraction.image.isNotEmpty
                ? Image.network(
                    attraction.image,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: _AppColors.lightGrey,
                      child: const Icon(Icons.broken_image,
                          color: _AppColors.grey),
                    ),
                  )
                : Container(
                    height: 140,
                    color: _AppColors.lightGrey,
                    child: const Icon(Icons.landscape_rounded,
                        color: _AppColors.grey),
                  ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attraction.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _AppColors.dark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  attraction.cityId.isNotEmpty ? attraction.cityId : 'Landmark',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _AppColors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(5, (i) => Icon(
                      i < attraction.rating.floor()
                          ? Icons.star_rounded
                          : i < attraction.rating
                              ? Icons.star_half_rounded
                              : Icons.star_border_rounded,
                      color: _AppColors.star,
                      size: 16,
                    )),
                    const SizedBox(width: 4),
                    Text(
                      '(${_formatReviewCount(attraction.rating * 10000 ~/ 5)})', // dummy count
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _AppColors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '€${(attraction.rating * 6).ceil()}', // dummy price
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}