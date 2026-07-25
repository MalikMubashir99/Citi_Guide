import 'package:flutter/material.dart';
import 'package:app/model/hotel_model.dart';
import 'package:app/services/hotel_service.dart';
import 'add_hotel_screen.dart';
import 'edit_hotel_screen.dart';

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  final HotelService hotelService = HotelService();

  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hotels")),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHotelScreen()),
          );
        },
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),

            child: TextField(
              controller: searchController,

              decoration: InputDecoration(
                hintText: "Search Hotel",

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

          Expanded(
            child: StreamBuilder<List<HotelModel>>(
              stream: hotelService.getHotels(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text("No Hotels"));
                }

                final hotels = snapshot.data!.where((hotel) {
                  return hotel.name.toLowerCase().contains(searchText);
                }).toList();

                if (hotels.isEmpty) {
                  return const Center(child: Text("No Matching Hotel"));
                }

                return ListView.builder(
                  itemCount: hotels.length,

                  itemBuilder: (context, index) {
                    HotelModel hotel = hotels[index];

                    return Card(
                      margin: const EdgeInsets.all(10),

                      child: ListTile(
                        leading: hotel.image.isEmpty
                            ? const CircleAvatar(child: Icon(Icons.hotel))
                            : CircleAvatar(
                                backgroundImage: NetworkImage(hotel.image),
                              ),

                        title: Text(hotel.name),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(hotel.description),

                            Text("⭐ ${hotel.rating}"),
                          ],
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),

                              onPressed: () {
                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditHotelScreen(hotel: hotel),
                                  ),
                                );
                              },
                            ),

                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),

                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) {
                                    return AlertDialog(
                                      title: const Text("Delete Hotel"),

                                      content: const Text("Are you sure?"),

                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(dialogContext);
                                          },

                                          child: const Text("Cancel"),
                                        ),

                                        ElevatedButton(
                                          onPressed: () async {
                                            final navigator = Navigator.of(
                                              dialogContext,
                                            );

                                            await hotelService.deleteHotel(
                                              hotel.id,
                                            );

                                            if (!mounted) return;

                                            navigator.pop();
                                          },

                                          child: const Text("Delete"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
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
