import 'package:app/model/attraction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:app/widgets/home_appbar.dart';
import 'package:app/widgets/search_bar_widget.dart';
import 'package:app/widgets/category_card.dart';
import 'package:app/widgets/attraction_card.dart';
import 'package:app/widgets/city_card.dart';
import 'package:app/widgets/bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  Future<List<AttractionModel>> getAttractions() async {
    // ✅ Fix: Use FirebaseFirestore.instance instead of firestore
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('attractions').get();

    return snapshot.docs.map((doc) {
      return AttractionModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeAppBar(),
              const SizedBox(height: 25),
              const SearchBarWidget(),
              const SizedBox(height: 30),

              const Text(
                "Categories",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  CategoryCard(
                    icon: Icons.place,
                    title: "Places",
                    color: Colors.blue,
                  ),
                  CategoryCard(
                    icon: Icons.hotel,
                    title: "Hotels",
                    color: Colors.orange,
                  ),
                  CategoryCard(
                    icon: Icons.restaurant,
                    title: "Food",
                    color: Colors.green,
                  ),
                  CategoryCard(
                    icon: Icons.event,
                    title: "Events",
                    color: Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 35),

              const Text(
                "Popular Attractions",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),

              // ✅ Use FutureBuilder to load attractions
              SizedBox(
                height: 285,
                child: FutureBuilder<List<AttractionModel>>(
                  future: getAttractions(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No attractions found'));
                    }

                    final attractions = snapshot.data!;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: attractions.length,
                      itemBuilder: (context, index) {
                        final attraction = attractions[index];
                        // ✅ Pass the attraction object to AttractionCard
                        return AttractionCard(attraction: attraction);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                "Top Cities",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),

              SizedBox(
                height: 190,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    CityCard(
                      image: "assets/images/karachi.jpg",
                      city: "Karachi",
                    ),
                    CityCard(
                      image: "assets/images/lahore.jpg",
                      city: "Lahore",
                    ),
                    CityCard(
                      image: "assets/images/islamabad.jpg",
                      city: "Islamabad",
                    ),
                    CityCard(
                      image: "assets/images/hunza.jpg",
                      city: "Hunza",
                    ),
                  ],
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