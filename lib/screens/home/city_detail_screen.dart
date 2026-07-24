import 'package:app/model/attraction_model.dart';
import 'package:app/model/event_model.dart';
import 'package:app/model/restaurant_model.dart';
import 'package:app/services/attraction_service.dart';
import 'package:app/services/event_service.dart';
import 'package:app/services/restaurant_service.dart';
import 'package:app/widgets/attraction_card.dart';
import 'package:app/widgets/event_card.dart';
import 'package:app/widgets/restaurant_card.dart';
import 'package:flutter/material.dart';

class CityDetailScreen extends StatefulWidget {
  final String cityId;
  final String cityName;

  const CityDetailScreen({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen> {
  AttractionService attractionService = AttractionService();
  RestaurantService restaurantService = RestaurantService();
  EventService eventService = EventService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cityName)),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,

              width: double.infinity,

              color: Colors.blue,

              child: Center(
                child: Text(
                  widget.cityName,
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
            ),

            // YAHAN CALL KARNA HAI
            attractionSection(),

            // buildSection("Hotels"),

            restaurantSection(),

            eventSection(),
          ],
        ),
      ),
    );
  }

  Widget attractionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Padding(
          padding: EdgeInsets.all(16),

          child: Text(
            "Popular Attractions",

            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),

        FutureBuilder<List<AttractionModel>>(
          future: attractionService.getAttractions(widget.cityId),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No Attractions Found"));
            }

            return Column(
              children: snapshot.data!.map((item) {
                return AttractionCard(attraction: item);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget restaurantSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Padding(
          padding: EdgeInsets.all(16),

          child: Text(
            "Restaurants",

            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),

        FutureBuilder<List<RestaurantModel>>(
          future: restaurantService.getRestaurants(widget.cityId),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No Restaurants Found"));
            }

            return Column(
              children: snapshot.data!.map((item) {
                return RestaurantCard(restaurant: item);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget eventSection() {

  return Column(

    crossAxisAlignment: CrossAxisAlignment.start,

    children: [

      const Padding(

        padding: EdgeInsets.all(16),

        child: Text(
          "Events",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

      ),

      FutureBuilder<List<EventModel>>(

        future: eventService.getEvents(widget.cityId),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );

          }

          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {

            return const Center(
              child: Text("No Events Found"),
            );

          }

          return Column(

            children: snapshot.data!.map((event) {

              return EventCard(event: event);

            }).toList(),

          );

        },

      ),

    ],
    

  );

}
}
