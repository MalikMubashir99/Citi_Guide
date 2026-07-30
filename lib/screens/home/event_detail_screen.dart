// lib/screens/home/event_detail_screen.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:app/model/event_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  @override
  void initState() {
    super.initState();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: AppColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> openGoogleMaps(BuildContext context) async {
    if (widget.event.location.isEmpty) {
      _showErrorSnackBar("Location not available");
      return;
    }

    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.event.location)}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      _showErrorSnackBar("Unable to open Google Maps");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Warm Linen
      appBar: AppBar(
        title: Text(
          widget.event.title,
          style: GoogleFonts.poppins(
            color: AppColors.dark,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.dark),
            onPressed: () {
              // Share event
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
                        child: const Icon(Icons.event_rounded, size: 100, color: AppColors.grey),
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
                          child: const Icon(Icons.broken_image, size: 100, color: AppColors.grey),
                        ),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 280,
                            width: double.infinity,
                            color: AppColors.lightGrey,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            ),
                          );
                        },
                      ),
                
                // Espresso tinted gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.splashOverlayDark.withValues(alpha: 0.6),
                          AppColors.splashOverlayDark.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Event badge (Flat design)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary, // Warm Sand
                      borderRadius: BorderRadius.circular(20),
                      // Removed shadow for modern flat look
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_available_rounded, color: AppColors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Upcoming',
                          style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Date badge on image (Flat design)
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      // Removed shadow
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _getDay(widget.event.date),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          _getMonth(widget.event.date),
                          style: GoogleFonts.poppins(
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
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                      height: 1.2,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Event Meta Info Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.7), width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 18),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  widget.event.date.isNotEmpty ? widget.event.date : 'TBD',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppColors.dark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 20, color: AppColors.lightGrey),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 18),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  widget.event.time.isNotEmpty ? widget.event.time : 'TBD',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppColors.dark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // About Section
                  _buildSectionHeader("About this Event"),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.7), width: 1),
                    ),
                    child: Text(
                      widget.event.description.isNotEmpty 
                          ? widget.event.description 
                          : "No description available",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: AppColors.darkGrey,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Location Section
                  _buildSectionHeader("Location"),
                  const SizedBox(height: 12),

                  // Location Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.7), width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Venue",
                                style: GoogleFonts.poppins(
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
                                style: GoogleFonts.poppins(
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
                            icon: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 20),
                            onPressed: () {
                              // Copy location logic
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions Section
                  _buildSectionHeader("Actions"),
                  const SizedBox(height: 12),

                  // Google Maps Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => openGoogleMaps(context),
                      icon: const Icon(Icons.map_rounded, color: AppColors.white, size: 22),
                      label: Text(
                        "Open in Google Maps",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0, // Flat modern style
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

  // Reusable Section Header
  Widget _buildSectionHeader(String title) {
    return Row(
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
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
            letterSpacing: 0.3,
          ),
        ),
      ],
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