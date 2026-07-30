// lib/screens/maps/open_street_map_screen.dart
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
  
  // Custom theme colors replacing AppColors
  static const Color _backgroundColor = Color(0xFFF8F5F0); // Warm Linen
  static const Color _surfaceColor = Colors.white;
  static const Color _darkColor = Color(0xFF2C2C2C); // Dark Espresso
  static const Color _primaryColor = Color(0xFF2563EB); // Vibrant Blue / Primary
  static const Color _errorColor = Color(0xFFDC2626); // Red

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
        backgroundColor: _surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Location Permission',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: _darkColor,
          ),
        ),
        content: Text(
          'Location permission is required to show your current position on the map.',
          style: GoogleFonts.poppins(
            color: Colors.grey.shade700,
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
                color: Colors.grey.shade700,
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
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
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
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.placeName ?? "Map",
          style: GoogleFonts.poppins(
            color: _darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: _backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: _darkColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: _darkColor),
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
              color: _backgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading Map...',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade700,
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
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300.withValues(alpha: 0.7),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off, color: _errorColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Location permission denied. Please enable in settings.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _getCurrentLocation,
                      child: Text(
                        'Retry',
                        style: GoogleFonts.poppins(
                          color: _primaryColor,
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
            color: _primaryColor,
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
              color: _primaryColor.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: _primaryColor,
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
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300.withValues(alpha: 0.7),
          width: 1,
        ),
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
              color: _darkColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}