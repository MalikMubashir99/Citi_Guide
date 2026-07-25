import 'package:app/model/attraction_model.dart';
import 'package:app/screens/home/attraction_details.dart';
import 'package:flutter/material.dart';

class AttractionCard extends StatelessWidget {
  final AttractionModel attraction;

  const AttractionCard({super.key, required this.attraction});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AttractionDetailScreen(attraction: attraction),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(10),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              attraction.image,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.broken_image,
                size: 50,
                color: Colors.grey,
              ),
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return const SizedBox(
                  width: 70,
                  height: 70,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
          title: Text(attraction.name),
          subtitle: Text("⭐ ${attraction.rating}"),
        ),
      ),
    );
  }
}