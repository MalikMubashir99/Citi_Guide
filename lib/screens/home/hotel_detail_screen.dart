// lib/screens/home/hotel_detail_screen.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:app/model/hotel_model.dart';
import 'package:app/services/favorite_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HotelDetailScreen extends StatefulWidget {
  final HotelModel hotel;

  const HotelDetailScreen({
    super.key,
    required this.hotel,
  });

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  final FavoriteService favoriteService = FavoriteService();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadFavorite();
  }

  Future<void> loadFavorite() async {
    try {
      bool favorite = await favoriteService.isFavorite(widget.hotel.id);
      if (mounted) {
        setState(() {
          isFavorite = favorite;
        });
      }
    } catch (e) {
      debugPrint('Error loading favorite: $e');
    }
  }

  Future<void> toggleFavorite() async {
    try {
      if (isFavorite) {
        await favoriteService.removeFavoriteByAttraction(widget.hotel.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Removed from favorites", style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500)),
            backgroundColor: AppColors.error, // Burnt Sienna
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        await favoriteService.addFavorite(widget.hotel.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Added to favorites ❤️", style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500)),
            backgroundColor: AppColors.success, // Sage Green
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      await loadFavorite();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e", style: GoogleFonts.poppins(color: AppColors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> callHotel(BuildContext context) async {
    if (widget.hotel.phone.isEmpty) {
      _showErrorSnackBar("Phone number not available");
      return;
    }

    final Uri url = Uri.parse("tel:${widget.hotel.phone}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!context.mounted) return;
      _showErrorSnackBar("Unable to make call");
    }
  }

  Future<void> openWebsite(BuildContext context) async {
    if (widget.hotel.website.isEmpty) {
      _showErrorSnackBar("Website URL not available");
      return;
    }

    String urlString = widget.hotel.website;
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      urlString = 'https://$urlString';
    }

    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      _showErrorSnackBar("Unable to open website");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Warm Linen
      appBar: AppBar(
        title: Text(
          widget.hotel.name,
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
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? AppColors.error : AppColors.darkGrey, // Burnt sienna when active
              size: 28,
            ),
            onPressed: toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.dark),
            onPressed: () {},
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
                widget.hotel.image.isEmpty
                    ? Container(
                        height: 280,
                        width: double.infinity,
                        color: AppColors.lightGrey,
                        child: const Icon(Icons.hotel_rounded, size: 100, color: AppColors.grey),
                      )
                    : Image.network(
                        widget.hotel.image,
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
                
                // Rating badge (Flat)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary, // Rich Cognac
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          widget.hotel.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // City badge (Flat)
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          widget.hotel.cityId,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.dark,
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
                  // Hotel Name
                  Text(
                    widget.hotel.name,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                      height: 1.2,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Rating Stars
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Icon(
                          index < widget.hotel.rating.floor()
                              ? Icons.star_rounded
                              : index < widget.hotel.rating
                                  ? Icons.star_half_rounded
                                  : Icons.star_outline_rounded,
                          color: AppColors.secondary, // Warm Sand
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.hotel.rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.hotel.rating >= 4.5 ? '⭐ Premium' : '👍 Good',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: widget.hotel.rating >= 4.5 ? AppColors.success : AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // About Section Header
                  _buildSectionHeader("About"),
                  const SizedBox(height: 12),
                  
                  // Description Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.7), width: 1),
                    ),
                    child: Text(
                      widget.hotel.description,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: AppColors.darkGrey,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact Section Header
                  _buildSectionHeader("Contact Information"),
                  const SizedBox(height: 12),

                  // Phone Card
                  _buildContactTile(
                    icon: Icons.phone_rounded,
                    label: "Phone",
                    value: widget.hotel.phone.isEmpty ? "Not available" : widget.hotel.phone,
                    onTap: widget.hotel.phone.isNotEmpty ? () => callHotel(context) : null,
                  ),
                  const SizedBox(height: 12),

                  // Website Card
                  _buildContactTile(
                    icon: Icons.language_rounded,
                    label: "Website",
                    value: widget.hotel.website.isEmpty ? "Not available" : widget.hotel.website,
                    trailingIcon: widget.hotel.website.isNotEmpty ? Icons.open_in_new_rounded : Icons.copy_rounded,
                    onTap: widget.hotel.website.isNotEmpty ? () => openWebsite(context) : null,
                  ),
                  const SizedBox(height: 24),

                  // Actions Section Header
                  _buildSectionHeader("Actions"),
                  const SizedBox(height: 12),

                  // Call Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => callHotel(context),
                      icon: const Icon(Icons.call_rounded, color: AppColors.white, size: 22),
                      label: Text(
                        "Call Hotel",
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
                        elevation: 0, // Flat design
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Website Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => openWebsite(context),
                      icon: const Icon(Icons.open_in_browser_rounded, color: AppColors.primary, size: 22),
                      label: Text(
                        "Visit Website",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primaryLight, width: 1.5), // Softer border
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  // Helper for Section Headers
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

  // Helper for Contact Info Tiles
  Widget _buildContactTile({
    required IconData icon,
    required String label,
    required String value,
    IconData? trailingIcon,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.7), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.poppins(fontSize: 15, color: AppColors.dark, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(trailingIcon ?? Icons.copy_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}