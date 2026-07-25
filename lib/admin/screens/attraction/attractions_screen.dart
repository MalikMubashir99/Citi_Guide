import 'package:app/admin/screens/attraction/add_attraction_screen.dart';
import 'package:app/admin/models/attraction_model.dart';
import 'package:app/admin/screens/attraction/edit_attraction_screen.dart';
import 'package:app/admin/services/city_service.dart';
import 'package:app/model/city_model.dart';
import 'package:flutter/material.dart';
import 'package:app/admin/services/attraction_service.dart';

class AttractionsScreen extends StatefulWidget {
  const AttractionsScreen({super.key});

  @override
  State<AttractionsScreen> createState() => _AttractionsScreenState();
}

class _AttractionsScreenState extends State<AttractionsScreen> {
  final AttractionService attractionService = AttractionService();
  final CityService cityService = CityService();

  final TextEditingController searchController = TextEditingController();

  String searchText = "";
  String? selectedCity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attractions")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddAttractionScreen()),
          );
        },
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Attraction",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(height: 15),
          // City filter dropdown
          StreamBuilder<List<CityModel>>(
            stream: cityService.getCities(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: DropdownButtonFormField<String>(
                  value: selectedCity,
                  decoration: const InputDecoration(
                    labelText: "Filter by City",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text("All Cities"),
                    ),
                    ...snapshot.data!.map((city) {
                      return DropdownMenuItem<String>(
                        value: city.id,
                        child: Text(city.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                    });
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          // Attractions list
          Expanded(
            child: StreamBuilder<List<AttractionModel>>(
              stream: attractionService.getAttractions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No Attractions"));
                }

                // ✅ Combined filter: search + city
                final filteredAttractions = snapshot.data!.where((item) {
                  bool matchesSearch = item.name
                      .toLowerCase()
                      .contains(searchText);
                  
                  bool matchesCity = selectedCity == null ||
                      item.cityId == selectedCity;
                  
                  return matchesSearch && matchesCity;
                }).toList();

                if (filteredAttractions.isEmpty) {
                  return const Center(
                    child: Text("No matching attractions"),
                  );
                }

                // ✅ Sort by rating (highest first)
                final sortedAttractions = List.from(filteredAttractions);
                sortedAttractions.sort(
                  (a, b) => b.rating.compareTo(a.rating),
                );

                return ListView.builder(
                  itemCount: sortedAttractions.length,
                  itemBuilder: (context, index) {
                    final attraction = sortedAttractions[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(attraction.image),
                          onBackgroundImageError: (_, __) =>
                              const Icon(Icons.broken_image),
                          child: const Icon(Icons.place),
                        ),
                        title: Text(attraction.name),
                        subtitle: Text(attraction.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditAttractionScreen(
                                      attraction: attraction,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              onPressed: () async {
                                // Show confirmation dialog
                                bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Delete Attraction"),
                                    content: Text("Delete ${attraction.name}?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await attractionService.deleteAttraction(
                                    attraction.id,
                                  );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Attraction Deleted"),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}