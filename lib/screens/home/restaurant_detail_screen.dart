import 'package:app/model/restaurant_model.dart';
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

class RestaurantDetailScreen extends StatefulWidget {
  final RestaurantModel restaurant;
  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
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
      bool favorite = await favoriteService.isFavorite(widget.restaurant.id);
      if (mounted) setState(() => isFavorite = favorite);
    } catch (e) {
      debugPrint('Error loading favorite: $e');
    }
  }

  Future<void> toggleFavorite() async {
    try {
      if (isFavorite) {
        await favoriteService.removeFavoriteByAttraction(widget.restaurant.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Removed from favorites",
                style: GoogleFonts.poppins(
                    color: _AppColors.white, fontWeight: FontWeight.w500)),
            backgroundColor: _AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        await favoriteService.addFavorite(widget.restaurant.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Added to favorites ❤️",
                style: GoogleFonts.poppins(
                    color: _AppColors.white, fontWeight: FontWeight.w500)),
            backgroundColor: _AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
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
        content: Text(message,
            style: GoogleFonts.poppins(
                color: _AppColors.white, fontWeight: FontWeight.w500)),
        backgroundColor: _AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> openGoogleMaps() async {
    if (widget.restaurant.latitude == 0 && widget.restaurant.longitude == 0) {
      _showErrorSnackBar("Location not available");
      return;
    }
    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${widget.restaurant.latitude},${widget.restaurant.longitude}",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      _showErrorSnackBar("Unable to open Google Maps");
    }
  }

  Future<void> callRestaurant() async {
    if (widget.restaurant.phone.isEmpty) {
      _showErrorSnackBar("Phone number not available");
      return;
    }
    final Uri url = Uri.parse("tel:${widget.restaurant.phone}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else if (mounted) {
      _showErrorSnackBar("Unable to make call");
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
            child: widget.restaurant.image.isEmpty
                ? Container(
                    height: 380,
                    width: double.infinity,
                    color: _AppColors.lightGrey,
                    child: const Icon(
                      Icons.restaurant_rounded,
                      size: 100,
                      color: _AppColors.grey,
                    ),
                  )
                : Image.network(
                    widget.restaurant.image,
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
                    // ─── Title & City ──────────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.restaurant.name,
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: _AppColors.dark,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ─── Category & City ────────────────────────────────────
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
                            "Restaurant",
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
                          widget.restaurant.cityId,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: _AppColors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ─── Rating Summary ──────────────────────────────────────
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < widget.restaurant.rating.floor()
                                ? Icons.star_rounded
                                : i < widget.restaurant.rating
                                    ? Icons.star_half_rounded
                                    : Icons.star_border_rounded,
                            color: _AppColors.star,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.restaurant.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _AppColors.dark,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.restaurant.rating >= 4.5
                              ? '(Popular)'
                              : '(Good)',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: _AppColors.grey,
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
                      widget.restaurant.description,
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
                            icon: Icons.phone_outlined,
                            label: "Phone",
                            value: widget.restaurant.phone.isEmpty
                                ? "Not available"
                                : widget.restaurant.phone,
                            isClickable: widget.restaurant.phone.isNotEmpty,
                            onTap:
                                widget.restaurant.phone.isNotEmpty
                                    ? callRestaurant
                                    : null,
                          ),
                          if (widget.restaurant.phone.isNotEmpty)
                            const Divider(
                              height: 1,
                              color: _AppColors.lightGrey,
                              indent: 64,
                            ),
                          _buildInfoTile(
                            icon: Icons.location_on_outlined,
                            label: "Location",
                            value: widget.restaurant.latitude != 0 &&
                                    widget.restaurant.longitude != 0
                                ? "${widget.restaurant.latitude.toStringAsFixed(4)}, ${widget.restaurant.longitude.toStringAsFixed(4)}"
                                : "Location not available",
                            isClickable: widget.restaurant.latitude != 0 &&
                                widget.restaurant.longitude != 0,
                            onTap:
                                widget.restaurant.latitude != 0 &&
                                        widget.restaurant.longitude != 0
                                    ? openGoogleMaps
                                    : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ─── (Optional) Write Review / Actions ──────────────────
                    // Since we don't have a review service for restaurants,
                    // we'll add a simple "Call" and "Maps" action buttons
                    // to replace the old action buttons, but in the new style.
                    _buildSectionHeader("Actions"),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed:
                                  widget.restaurant.phone.isNotEmpty
                                      ? callRestaurant
                                      : null,
                              icon: const Icon(
                                Icons.call_rounded,
                                color: _AppColors.primary,
                                size: 20,
                              ),
                              label: Text(
                                "Call",
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
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed:
                                  (widget.restaurant.latitude != 0 &&
                                          widget.restaurant.longitude != 0)
                                      ? openGoogleMaps
                                      : null,
                              icon: const Icon(
                                Icons.map_rounded,
                                color: _AppColors.primary,
                                size: 20,
                              ),
                              label: Text(
                                "Maps",
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
                        ),
                      ],
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