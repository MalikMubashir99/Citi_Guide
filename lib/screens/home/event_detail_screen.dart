// lib/screens/home/event_detail_screen.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:app/model/event_model.dart';
import 'package:app/services/favorite_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final FavoriteService favoriteService = FavoriteService();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadFavorite();
  }
// lib/screens/home/event_detail_screen.dart

Future<void> loadFavorite() async {
  try {
    print('🔍 Event ID: ${widget.event.id}');
    print('🔍 Event Name: ${widget.event.title}');
    print('🔍 Event ID length: ${widget.event.id.length}');
    
    if (widget.event.id.isEmpty) {
      print('❌ Event ID is EMPTY!');
      return;
    }
    
    bool favorite = await favoriteService.isFavorite(widget.event.id);
    print('📊 Favorite status: $favorite');
    if (mounted) {
      setState(() {
        isFavorite = favorite;
      });
    }
  } catch (e) {
    print('❌ Error loading favorite: $e');
  }
}

Future<void> toggleFavorite() async {
  try {
    print('🔄 Toggling favorite for: ${widget.event.id}');
    print('🔄 Event ID length: ${widget.event.id.length}');
    
    if (widget.event.id.isEmpty) {
      print('❌ Cannot toggle favorite - Event ID is empty!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Event ID not found"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (isFavorite) {
      print('🗑️ Removing favorite...');
      await favoriteService.removeFavoriteByAttraction(widget.event.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Removed from favorites"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      print('❤️ Adding favorite...');
      await favoriteService.addFavorite(widget.event.id);
      print('✅ Favorite added successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Added to favorites ❤️"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    await loadFavorite();
  } catch (e) {
    print('❌ Error toggling favorite: $e');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

  Future<void> openGoogleMaps(BuildContext context) async {
    if (widget.event.location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Location not available"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.event.location)}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Unable to open Google Maps"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.event.title,
          style: TextStyle(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.dark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // ✅ Favorite Button
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? Colors.red : AppColors.error,
              size: 28,
            ),
            onPressed: toggleFavorite,
          ),
          IconButton(
            icon: Icon(
              Icons.share_rounded,
              color: AppColors.dark,
            ),
            onPressed: () {
              // TODO: Share event
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                widget.event.image.isEmpty
                    ? Container(
                        height: 280,
                        width: double.infinity,
                        color: AppColors.lightGrey,
                        child: Icon(
                          Icons.event_rounded,
                          size: 100,
                          color: AppColors.grey,
                        ),
                      )
                    : Image.network(
                        widget.event.image,
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 280,
                          width: double.infinity,
                          color: AppColors.lightGrey,
                          child: Icon(
                            Icons.broken_image,
                            size: 100,
                            color: AppColors.grey,
                          ),
                        ),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 280,
                            width: double.infinity,
                            color: AppColors.lightGrey,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                      ),
                // Gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                // Event badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event_available_rounded,
                          color: AppColors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Upcoming',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Date badge on image
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _getDay(widget.event.date),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          _getMonth(widget.event.date),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.darkGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    widget.event.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Event Meta Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.lightGrey,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.event.date.isNotEmpty ? widget.event.date : 'TBD',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.dark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: AppColors.lightGrey,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.event.time.isNotEmpty ? widget.event.time : 'TBD',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.dark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description Section
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "About this Event",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.lightGrey,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.event.description.isNotEmpty 
                          ? widget.event.description 
                          : "No description available",
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.darkGrey,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Location Information
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Location",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Location Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.lightGrey,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Venue",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.event.location.isNotEmpty 
                                    ? widget.event.location 
                                    : "Location not available",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.dark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.event.location.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              Icons.copy_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            onPressed: () {
                              // Copy location
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Text(
                    "Actions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Google Maps Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => openGoogleMaps(context),
                      icon: Icon(
                        Icons.map_rounded,
                        color: AppColors.white,
                        size: 22,
                      ),
                      label: Text(
                        "Open in Google Maps",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for date formatting
  String _getDay(String date) {
    try {
      if (date.isEmpty) return '--';
      final parts = date.split(' ');
      if (parts.length >= 2) {
        return parts[0];
      }
      return date.substring(0, 2);
    } catch (_) {
      return '--';
    }
  }

  String _getMonth(String date) {
    try {
      if (date.isEmpty) return '---';
      final parts = date.split(' ');
      if (parts.length >= 2) {
        return parts[1].substring(0, 3);
      }
      return date.substring(3, 6);
    } catch (_) {
      return '---';
    }
  }
}