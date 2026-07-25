// lib/services/osm_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OsmService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  /// Search places by name
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    final url = Uri.parse(
      '$_baseUrl/search?q=$query&format=json&limit=10&addressdetails=1',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to search places');
    }
  }

  /// Reverse geocoding (coordinates → address)
  static Future<Map<String, dynamic>?> reverseGeocode(LatLng position) async {
    final url = Uri.parse(
      '$_baseUrl/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  /// Get place details
  static Future<Map<String, dynamic>?> getPlaceDetails(String osmId) async {
    final url = Uri.parse(
      '$_baseUrl/lookup?osm_ids=$osmId&format=json',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        return data[0];
      }
    }
    return null;
  }
}