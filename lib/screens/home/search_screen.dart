import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search attractions, hotels...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = "";
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase().trim();
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: searchQuery.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 80, color: Colors.grey),
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
                    )
                  : const Center(
                      child: Text(
                        "Search Results will appear here",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}