// lib/screens/maps/open_street_map_screen.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
  bool _permissionDenied = false;

  static const LatLng _defaultPosition = LatLng(24.8607, 67.0011);

  @override
  void initState() {
    super.initState();
    _initializePosition();
  }

  void _initializePosition() {
    if (widget.latitude != null && widget.longitude != null) {
      setState(() {
        _targetPosition = LatLng(widget.latitude!, widget.longitude!);
        _isLoading = false;
      });
    } else {
      setState(() {
        _targetPosition = _defaultPosition;
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _targetPosition = _defaultPosition;
          _permissionDenied = true;
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
            _permissionDenied = true;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _targetPosition = _defaultPosition;
          _permissionDenied = true;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _targetPosition = _currentPosition;
        _hasLocationPermission = true;
        _permissionDenied = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _targetPosition = _defaultPosition;
        _permissionDenied = true;
      });
    }
  }

  Future<void> _centerOnLocation() async {
    if (_currentPosition != null && _hasLocationPermission) {
      _mapController.move(_currentPosition!, 15);
    } else {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Location Permission',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
        content: Text(
          'Location permission is required to show your current position on the map.',
          style: GoogleFonts.poppins(
            color: AppColors.darkGrey,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _getCurrentLocation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Allow',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Warm Linen
      appBar: AppBar(
        title: Text(
          widget.placeName ?? "Map",
          style: GoogleFonts.poppins(
            color: AppColors.dark,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.dark),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppColors.dark),
            onPressed: _centerOnLocation,
            tooltip: 'My Location',
          ),
        ],
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
          
          // Loading State
          if (_isLoading)
            Container(
              color: AppColors.background,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading Map...',
                      style: GoogleFonts.poppins(
                        color: AppColors.darkGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Permission Denied Banner
          if (_permissionDenied && !_isLoading)
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface, // Pure white
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.lightGrey.withValues(alpha: 0.7),
                    width: 1,
                  ),
                  // Removed drop shadow for flat design
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off, color: AppColors.error), // Burnt Sienna
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Location permission denied. Please enable in settings.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _getCurrentLocation,
                      child: Text(
                        'Retry',
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Map Controls (Zoom & Location)
          Positioned(
            right: 16,
            bottom: 100,
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
            color: AppColors.primary, // Rich Cognac Pin
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
              color: AppColors.info.withValues(alpha: 0.3), // Dusty Blue glow
              shape: BoxShape.circle,
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.info, // Dusty Blue center
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
        color: AppColors.surface, // Pure white
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightGrey.withValues(alpha: 0.7),
          width: 1,
        ),
        // Removed drop shadow for flat design
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
              color: AppColors.dark, // Dark espresso icon instead of blue
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}