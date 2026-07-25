import 'package:app/model/event_model.dart';
import 'package:app/screens/home/event_detail_screen.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({
    super.key,
    required this.event,
  });

  String _formatDate(String date) {
    try {
      // Parse and format date (customize as needed)
      return date;
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(event: event),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            event.image.isEmpty
                ? Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.event,
                      size: 80,
                    ),
                  )
                : Image.network(
                    event.image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 5),
                      Text(_formatDate(event.date)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 18,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 5),
                      Text(event.time),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}