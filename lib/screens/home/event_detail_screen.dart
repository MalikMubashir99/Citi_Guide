// lib/screens/home/event_detail_screen.dart
import 'package:app/model/event_model.dart';
import 'package:app/services/favorite_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Local Blue Theme ──────────────────────────────────────────────────────────
class _AppColors {
  static const Color background = Color(0xFFF8FAFC);
  static const Color white = Colors.white;
  static const Color dark = Color(0xFF0F172A);
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color error = Color(0xFFDC2626);
  static const Color lightGrey = Color(0xFFE2E8F0);
  static const Color grey = Color(0xFF64748B);
  static const Color star = Color(0xFFF59E0B);
}

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

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

  // ─── Core Logic ──────────────────────────────────────────────────────────────

  Future<void> loadFavorite() async {
    try {
      bool favorite = await favoriteService.isFavorite(widget.event.id);
      if (mounted) setState(() => isFavorite = favorite);
    } catch (e) {
      debugPrint('Error loading favorite: $e');
    }
  }

  Future<void> toggleFavorite() async {
    try {
      if (isFavorite) {
        await favoriteService.removeFavoriteByAttraction(widget.event.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Removed from favorites",
              style: GoogleFonts.poppins(
                color: _AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: _AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        await favoriteService.addFavorite(widget.event.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Added to favorites ❤️",
              style: GoogleFonts.poppins(
                color: _AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: _AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      await loadFavorite();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      if (!mounted) return;
      _showErrorSnackBar("Error: $e");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: _AppColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: _AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> openGoogleMaps() async {
    if (widget.event.location.isEmpty) {
      _showErrorSnackBar("Location not available");
      return;
    }
    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.event.location)}",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      _showErrorSnackBar("Unable to open Google Maps");
    }
  }
  // ─── UI Helpers ──────────────────────────────────────────────────────────────

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isClickable ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _AppColors.dark,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isClickable)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: _AppColors.grey,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: _AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _AppColors.dark,
          ),
        ),
      ],
    );
  }

  Widget _circleIconButton(
    IconData icon,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color ?? Colors.white, size: 24),
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      body: Stack(
        children: [
          // ─── Image Header ──────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: widget.event.image.isEmpty
                ? Container(
                    height: 380,
                    width: double.infinity,
                    color: _AppColors.lightGrey,
                    child: const Icon(
                      Icons.event_rounded,
                      size: 100,
                      color: _AppColors.grey,
                    ),
                  )
                : Image.network(
                    widget.event.image,
                    width: double.infinity,
                    height: 380,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 380,
                      color: _AppColors.lightGrey,
                      child: const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: _AppColors.grey,
                      ),
                    ),
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            height: 380,
                            color: _AppColors.lightGrey,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _AppColors.primary,
                              ),
                            ),
                          ),
                  ),
          ),

          // ─── Scrollable Content Sheet ──────────────────────────────────────
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 330),
              child: Container(
                decoration: const BoxDecoration(
                  color: _AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Title ──────────────────────────────────────────────
                    Text(
                      widget.event.title,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: _AppColors.dark,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ─── Category & Location ────────────────────────────────
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Event",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: _AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: _AppColors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.event.location.isNotEmpty
                              ? widget.event.location
                              : "Location TBD",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: _AppColors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ─── Date & Time Row ─────────────────────────────────────
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: _AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.event.date.isNotEmpty
                              ? widget.event.date
                              : "Date TBA",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: _AppColors.dark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: _AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.event.time.isNotEmpty
                              ? widget.event.time
                              : "Time TBA",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: _AppColors.dark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: _AppColors.lightGrey, thickness: 1),
                    ),

                    // ─── Description ──────────────────────────────────────────
                    Text(
                      widget.event.description.isNotEmpty
                          ? widget.event.description
                          : "No description available.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _AppColors.dark.withOpacity(0.8),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── Info Tiles ────────────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: _AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _AppColors.lightGrey,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildInfoTile(
                            icon: Icons.location_on_outlined,
                            label: "Location",
                            value: widget.event.location.isNotEmpty
                                ? widget.event.location
                                : "Not specified",
                            isClickable: widget.event.location.isNotEmpty,
                            onTap: widget.event.location.isNotEmpty
                                ? openGoogleMaps
                                : null,
                          ),
                          if (widget.event.location.isNotEmpty)
                            const Divider(
                              height: 1,
                              color: _AppColors.lightGrey,
                              indent: 64,
                            ),
                          _buildInfoTile(
                            icon: Icons.calendar_month_rounded,
                            label: "Date",
                            value: widget.event.date.isNotEmpty
                                ? widget.event.date
                                : "TBA",
                          ),
                          const Divider(
                            height: 1,
                            color: _AppColors.lightGrey,
                            indent: 64,
                          ),
                          _buildInfoTile(
                            icon: Icons.access_time_rounded,
                            label: "Time",
                            value: widget.event.time.isNotEmpty
                                ? widget.event.time
                                : "TBA",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ─── Actions ──────────────────────────────────────────────
                    _buildSectionHeader("Actions"),
                    const SizedBox(height: 12),

                    if (widget.event.location.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: openGoogleMaps,
                          icon: const Icon(
                            Icons.map_rounded,
                            color: _AppColors.primary,
                            size: 20,
                          ),
                          label: Text(
                            "Open in Maps",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _AppColors.primary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: _AppColors.primary,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // ─── Floating Actions ──────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                Row(
                  children: [
                    _circleIconButton(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      toggleFavorite,
                      color: isFavorite ? _AppColors.error : Colors.white,
                    ),
                    const SizedBox(width: 10),
                    _circleIconButton(
                      Icons.share_rounded,
                      () {
                        // Add share logic if needed
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}