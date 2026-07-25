import 'package:flutter/material.dart';

class CityCard extends StatelessWidget {
  final String image;
  final String city;

  const CityCard({
    super.key,
    required this.image,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              image,
              height: 140,
              width: 160,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            city,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}