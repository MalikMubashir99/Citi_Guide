import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final TextEditingController searchController =
      TextEditingController();

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

                hintText: "Search...",

                prefixIcon: const Icon(Icons.search),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),

              ),

              onChanged: (value) {
                setState(() {});
              },

            ),

            const SizedBox(height: 20),

            Expanded(

              child: Center(

                child: Text(
                  "Search Results",
                ),

              ),

            )

          ],

        ),

      ),

    );

  }

}