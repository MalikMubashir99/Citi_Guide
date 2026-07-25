// lib/screens/map/map_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? placeName;

  const MapScreen({
    super.key,
    this.latitude,
    this.longitude,
    this.placeName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng? currentPosition;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Show dialog to enable location
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.placeName ?? "Map"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentPosition ?? const LatLng(24.8607, 67.0011),
                zoom: 14,
              ),
              onMapCreated: (controller) {
                mapController = controller;
              },
              markers: widget.latitude != null && widget.longitude != null
                  ? {
                      Marker(
                        markerId: const MarkerId('location'),
                        position: LatLng(widget.latitude!, widget.longitude!),
                        infoWindow: InfoWindow(
                          title: widget.placeName,
                        ),
                      ),
                    }
                  : {},
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
            ),
    );
  }
}