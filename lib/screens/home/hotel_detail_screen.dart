import 'package:flutter/material.dart';
import '../../model/hotel_model.dart';
import 'package:url_launcher/url_launcher.dart';

class HotelDetailScreen extends StatelessWidget {
  final HotelModel hotel;

  const HotelDetailScreen({
    super.key,
    required this.hotel,
  });

  Future<void> openWebsite() async {
    if (hotel.website.isEmpty) return;

    Uri url = Uri.parse(hotel.website);

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> callHotel() async {
    if (hotel.phone.isEmpty) return;

    Uri url = Uri.parse("tel:${hotel.phone}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hotel.name),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            hotel.image.isEmpty
                ? Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.hotel,
                      size: 100,
                    ),
                  )
                : Image.network(
                    hotel.image,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),

            Padding(
              padding:
                  const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [

                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        hotel.rating.toString(),
                      ),

                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    hotel.description,
                  ),

                  const SizedBox(height: 25),

                  ListTile(
                    leading:
                        const Icon(Icons.phone),
                    title:
                        const Text("Phone"),
                    subtitle:
                        Text(hotel.phone),
                  ),

                  ListTile(
                    leading: const Icon(
                        Icons.language),
                    title:
                        const Text("Website"),
                    subtitle:
                        Text(hotel.website),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(

                      onPressed: callHotel,

                      icon:
                          const Icon(Icons.call),

                      label:
                          const Text("Call Hotel"),

                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(

                      onPressed:
                          openWebsite,

                      icon: const Icon(
                          Icons.language),

                      label: const Text(
                          "Visit Website"),

                    ),
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