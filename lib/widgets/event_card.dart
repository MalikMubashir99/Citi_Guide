import 'package:flutter/material.dart';
import '../model/event_model.dart';

class EventCard extends StatelessWidget {

  final EventModel event;

  const EventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {

    return Card(

      margin: const EdgeInsets.all(10),

      child: ListTile(

        leading: Image.network(
          event.image,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
        ),

        title: Text(event.title),

        subtitle: Text(
          "${event.date}\n${event.location}",
        ),

      ),

    );
  }
}