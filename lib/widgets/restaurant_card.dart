import 'package:app/model/restaurant_model.dart';
import 'package:flutter/material.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),

      child: ListTile(
        leading: Image.network(
          restaurant.image,

          width: 70,

          height: 70,

          fit: BoxFit.cover,
        ),

        title: Text(restaurant.name),

        subtitle: Text("⭐ ${restaurant.rating}"),
      ),
    );
  }
}
