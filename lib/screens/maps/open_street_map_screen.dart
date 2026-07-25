// lib/screens/map/open_street_map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

class OpenStreetMapScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? placeName;
  final List<Marker>? markers;

  const OpenStreetMapScreen({
    super.key,
    this.latitude,
    this.longitude,
    this.placeName,
    this.markers,
  });

  @override
  State<OpenStreetMapScreen> createState() => _OpenStreetMapScreenState();
}

class _OpenStreetMapScreenState extends State<OpenStreetMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  LatLng? _targetPosition;
  bool _isLoading = true;
  bool _hasLocationPermission = false;

  static const LatLng _defaultPosition = LatLng(24.8607, 67.0011);

  @override
  void initState() {
    super.initState();
    _initializePosition();
  }

  Future<void> _initializePosition() async {
    if (widget.latitude != null && widget.longitude != null) {
      setState(() {
        _targetPosition = LatLng(widget.latitude!, widget.longitude!);
        _isLoading = false;
      });
    } else {
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _targetPosition = _defaultPosition;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _targetPosition = _defaultPosition;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _targetPosition = _defaultPosition;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _targetPosition = _currentPosition;
        _hasLocationPermission = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _targetPosition = _defaultPosition;
      });
    }
  }

  Future<void> _centerOnLocation() async {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 15);
    } else {
      await _getCurrentLocation();
      if (_currentPosition != null) {
        _mapController.move(_currentPosition!, 15);
      }
    }
  }

  // ✅ Fixed: Search with proper Location handling
  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      
      setState(() {
        _isLoading = false;
      });

      if (locations.isNotEmpty) {
        Location location = locations.first;
        
        setState(() {
          _targetPosition = LatLng(location.latitude, location.longitude);
        });
        
        _mapController.move(_targetPosition!, 14);
        
        // ✅ Get place name from reverse geocoding
        String placeName = query;
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );
          if (placemarks.isNotEmpty) {
            placeName = placemarks.first.name ?? 
                        placemarks.first.locality ?? 
                        placemarks.first.administrativeArea ?? 
                        query;
          }
        } catch (_) {
          placeName = query;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📍 Found: $placeName'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No location found for "$query"'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.placeName ?? "Map"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnLocation,
            tooltip: 'My Location',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search places...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onSubmitted: _searchPlace,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_targetPosition != null)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _targetPosition!,
                initialZoom: 14,
                minZoom: 3,
                maxZoom: 19,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                  additionalOptions: const {
                    'attribution': '© OpenStreetMap contributors',
                  },
                ),
                MarkerLayer(
                  markers: _buildMarkers(),
                ),
              ],
            ),
          
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading Map...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          Positioned(
            right: 16,
            bottom: 30,
            child: Column(
              children: [
                _buildMapControlButton(
                  icon: Icons.add,
                  onTap: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  ),
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  icon: Icons.remove,
                  onTap: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  ),
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  icon: Icons.my_location,
                  onTap: _centerOnLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    if (_targetPosition != null) {
      markers.add(
        Marker(
          point: _targetPosition!,
          width: 40,
          height: 40,
          child: const Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 40,
          ),
        ),
      );
    }

    if (widget.markers != null) {
      markers.addAll(widget.markers!);
    }

    if (_currentPosition != null && _hasLocationPermission) {
      markers.add(
        Marker(
          point: _currentPosition!,
          width: 30,
          height: 30,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: Colors.blue.shade700,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}