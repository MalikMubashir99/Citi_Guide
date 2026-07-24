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
        margin: EdgeInsets.all(10),

        child: ListTile(
          leading: Image.network(
            attraction.image,

            width: 70,

            height: 70,

            fit: BoxFit.cover,
          ),

          title: Text(attraction.name),

          subtitle: Text("⭐ ${attraction.rating}"),
        ),
      ),
    );
  }
}
