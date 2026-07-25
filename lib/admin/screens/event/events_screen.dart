import 'package:flutter/material.dart';

import '../../../model/event_model.dart';
import '../../../services/event_service.dart';

import 'add_event_screen.dart';
import 'edit_event_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() =>
      _EventsScreenState();
}
class _EventsScreenState
    extends State<EventsScreen> {

  final EventService eventService =
      EventService();

  String searchText = "";

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Events"),
      ),

      floatingActionButton:
          FloatingActionButton(

        child: const Icon(Icons.add),

        onPressed: () {

          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  const AddEventScreen(),

            ),

          );

        },

      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(

              decoration:
                  const InputDecoration(

                hintText: "Search Event",

                prefixIcon:
                    Icon(Icons.search),

              ),

              onChanged: (value) {

                setState(() {

                  searchText =
                      value.toLowerCase();

                });

              },

            ),

            const SizedBox(height: 20),

            Expanded(

              child:

                  StreamBuilder<List<EventModel>>(

                stream:
                    eventService.getEvents(),

                builder:
                    (context, snapshot) {

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {

                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );

                  }

                  if (!snapshot.hasData) {

                    return const SizedBox();

                  }

                  final events =
                      snapshot.data!
                          .where((item) {

                    return item.title
                        .toLowerCase()
                        .contains(searchText);

                  }).toList();

                  if (events.isEmpty) {

                    return const Center(
                      child: Text(
                        "No Events Found",
                      ),
                    );

                  }

                  return ListView.builder(

                    itemCount:
                        events.length,

                    itemBuilder:
                        (context, index) {

                      final event =
                          events[index];

                      return Card(

                        child: ListTile(

                          leading:

                              event.image.isEmpty

                                  ? const CircleAvatar(
                                      child: Icon(
                                        Icons.event,
                                      ),
                                    )

                                  : CircleAvatar(

                                      backgroundImage:
                                          NetworkImage(
                                        event.image,
                                      ),

                                    ),

                          title:
                              Text(event.title),

                          subtitle:
                              Text(event.date),

                          trailing: Row(

                            mainAxisSize:
                                MainAxisSize.min,

                            children: [

                              IconButton(

                                icon:
                                    const Icon(
                                  Icons.edit,
                                ),

                                onPressed: () {

                                  Navigator.push(

                                    context,

                                    MaterialPageRoute(

                                      builder: (_) =>
                                          EditEventScreen(
                                        event: event,
                                      ),

                                    ),

                                  );

                                },

                              ),

                              IconButton(

                                icon:
                                    const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),

                                onPressed: () async {

                                  await eventService
                                      .deleteEvent(
                                    event.id,
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

      ),

    );

  }

}