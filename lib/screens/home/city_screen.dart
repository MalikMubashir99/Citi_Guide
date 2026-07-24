import 'package:app/model/city_model.dart';
import 'package:app/screens/home/city_detail_screen.dart';
import 'package:app/services/city_service.dart';
import 'package:flutter/material.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  CityService service = CityService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select City")),

      body: FutureBuilder<List<CityModel>>(
        future: service.getCities(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No Cities Found"));
          }

          final cities = snapshot.data!;

          return ListView.builder(
            itemCount: cities.length,

            itemBuilder: (context, index) {
              final city = cities[index];

              return Card(
                margin: EdgeInsets.all(10),

                child: ListTile(
                  leading: Image.network(
                    city.image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),

                  title: Text(city.name),

                  subtitle: Text(city.description),

                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (context) => CityDetailScreen(
                          cityId: city.id,

                          cityName: city.name,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
