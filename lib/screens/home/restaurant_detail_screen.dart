// // lib/screens/home/restaurant_detail_screen.dart
// import 'package:app/model/restaurant_model.dart';
// import 'package:app/services/favorite_service.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:url_launcher/url_launcher.dart';

// class RestaurantDetailScreen extends StatefulWidget {
//   final RestaurantModel restaurant;

//   const RestaurantDetailScreen({
//     super.key,
//     required this.restaurant,
//   });

//   @override
//   State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
// }

// class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
//   final FavoriteService favoriteService = FavoriteService();
//   bool isFavorite = false;

//   @override
//   void initState() {
//     super.initState();
//     loadFavorite();
//   }

//   Future<void> loadFavorite() async {
//     try {
//       bool favorite = await favoriteService.isFavorite(widget.restaurant.id);
//       if (mounted) {
//         setState(() {
//           isFavorite = favorite;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading favorite: $e');
//     }
//   }

//   Future<void> toggleFavorite() async {
//     try {
//       if (isFavorite) {
//         await favoriteService.removeFavoriteByAttraction(widget.restaurant.id);
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Removed from favorites", style: GoogleFonts.poppins(color: const Color(0xFFFFFFFF), fontWeight: FontWeight.w500)),
//             backgroundColor: const Color(0xFFBC4749),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//         );
//       } else {
//         await favoriteService.addFavorite(widget.restaurant.id);
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Added to favorites ❤️", style: GoogleFonts.poppins(color: const Color(0xFFFFFFFF), fontWeight: FontWeight.w500)),
//             backgroundColor: const Color(0xFF6A994E),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//         );
//       }
//       await loadFavorite();
//     } catch (e) {
//       debugPrint('Error toggling favorite: $e');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error: $e", style: GoogleFonts.poppins(color: const Color(0xFFFFFFFF))),
//           backgroundColor: const Color(0xFFBC4749),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       );
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: GoogleFonts.poppins(color: const Color(0xFFFFFFFF), fontWeight: FontWeight.w500)),
//         backgroundColor: const Color(0xFFBC4749),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   Future<void> openGoogleMaps(BuildContext context) async {
//     if (widget.restaurant.latitude == 0 && widget.restaurant.longitude == 0) {
//       _showErrorSnackBar("Location not available");
//       return;
//     }

//     final Uri url = Uri.parse(
//       "https://www.google.com/maps/search/?api=1&query=${widget.restaurant.latitude},${widget.restaurant.longitude}",
//     );

//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     } else {
//       if (!context.mounted) return;
//       _showErrorSnackBar("Unable to open Google Maps");
//     }
//   }

//   Future<void> callRestaurant(BuildContext context) async {
//     if (widget.restaurant.phone.isEmpty) {
//       _showErrorSnackBar("Phone number not available");
//       return;
//     }

//     final Uri url = Uri.parse("tel:${widget.restaurant.phone}");
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     } else {
//       if (!context.mounted) return;
//       _showErrorSnackBar("Unable to make call");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFDFBF7),
//       appBar: AppBar(
//         title: Text(
//           widget.restaurant.name,
//           style: GoogleFonts.poppins(
//             color: const Color(0xFF2C221E),
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.3,
//           ),
//         ),
//         backgroundColor: const Color(0xFFFDFBF7),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2C221E)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(
//               isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
//               color: isFavorite ? const Color(0xFFBC4749) : const Color(0xFF5C524E),
//               size: 28,
//             ),
//             onPressed: toggleFavorite,
//           ),
//           IconButton(
//             icon: const Icon(Icons.share_rounded, color: Color(0xFF2C221E)),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image Section
//             Stack(
//               children: [
//                 widget.restaurant.image.isEmpty
//                     ? Container(
//                         height: 280,
//                         width: double.infinity,
//                         color: const Color(0xFFE6E1DC),
//                         child: const Icon(Icons.restaurant_rounded, size: 100, color: Color(0xFF8C827E)),
//                       )
//                     : Image.network(
//                         widget.restaurant.image,
//                         width: double.infinity,
//                         height: 280,
//                         fit: BoxFit.cover,
//                         errorBuilder: (_, __, ___) => Container(
//                           height: 280,
//                           width: double.infinity,
//                           color: const Color(0xFFE6E1DC),
//                           child: const Icon(Icons.broken_image, size: 100, color: Color(0xFF8C827E)),
//                         ),
//                         loadingBuilder: (_, child, progress) {
//                           if (progress == null) return child;
//                           return Container(
//                             height: 280,
//                             width: double.infinity,
//                             color: const Color(0xFFE6E1DC),
//                             child: const Center(
//                               child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFA0522D)),
//                             ),
//                           );
//                         },
//                       ),
                
//                 // Espresso tinted gradient overlay
//                 Positioned(
//                   bottom: 0,
//                   left: 0,
//                   right: 0,
//                   child: Container(
//                     height: 100,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.transparent,
//                           const Color(0xFF1A120B).withValues(alpha: 0.6),
//                           const Color(0xFF1A120B).withValues(alpha: 0.9),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
                
//                 // Rating badge (Flat)
//                 Positioned(
//                   bottom: 16,
//                   right: 16,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFA0522D),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.star_rounded, color: Color(0xFFFFFFFF), size: 18),
//                         const SizedBox(width: 6),
//                         Text(
//                           widget.restaurant.rating.toStringAsFixed(1),
//                           style: GoogleFonts.poppins(
//                             color: const Color(0xFFFFFFFF),
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
                
//                 // City badge (Flat)
//                 Positioned(
//                   bottom: 16,
//                   left: 16,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFFFFFF).withValues(alpha: 0.95),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFA0522D)),
//                         const SizedBox(width: 4),
//                         Text(
//                           widget.restaurant.cityId,
//                           style: GoogleFonts.poppins(
//                             fontSize: 12,
//                             color: const Color(0xFF2C221E),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             // Content
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Restaurant Name
//                   Text(
//                     widget.restaurant.name,
//                     style: GoogleFonts.poppins(
//                       fontSize: 28,
//                       fontWeight: FontWeight.w600,
//                       color: const Color(0xFF2C221E),
//                       height: 1.2,
//                       letterSpacing: 0.3,
//                     ),
//                   ),
//                   const SizedBox(height: 12),

//                   // Rating Stars
//                   Row(
//                     children: [
//                       ...List.generate(
//                         5,
//                         (index) => Icon(
//                           index < widget.restaurant.rating.floor()
//                               ? Icons.star_rounded
//                               : index < widget.restaurant.rating
//                                   ? Icons.star_half_rounded
//                                   : Icons.star_outline_rounded,
//                           color: const Color(0xFFD4A373),
//                           size: 20,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         widget.restaurant.rating.toStringAsFixed(1),
//                         style: GoogleFonts.poppins(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: const Color(0xFF2C221E),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         widget.restaurant.rating >= 4.5 ? '(Popular)' : '(Good)',
//                         style: GoogleFonts.poppins(
//                           fontSize: 13,
//                           color: const Color(0xFF8C827E),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),

//                   // About Section
//                   _buildSectionHeader("About"),
//                   const SizedBox(height: 12),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFFFFFF),
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(color: const Color(0xFFE6E1DC).withValues(alpha: 0.7), width: 1),
//                     ),
//                     child: Text(
//                       widget.restaurant.description,
//                       style: GoogleFonts.poppins(
//                         fontSize: 15,
//                         color: const Color(0xFF5C524E),
//                         height: 1.6,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // Contact Section
//                   _buildSectionHeader("Contact Information"),
//                   const SizedBox(height: 12),

//                   // Phone Card
//                   _buildContactTile(
//                     icon: Icons.phone_rounded,
//                     label: "Phone",
//                     value: widget.restaurant.phone.isEmpty ? "Not available" : widget.restaurant.phone,
//                     onTap: widget.restaurant.phone.isNotEmpty ? () => callRestaurant(context) : null,
//                   ),
//                   const SizedBox(height: 12),

//                   // Location Card
//                   _buildContactTile(
//                     icon: Icons.location_on_rounded,
//                     label: "Location",
//                     value: widget.restaurant.latitude != 0 && widget.restaurant.longitude != 0
//                         ? "${widget.restaurant.latitude.toStringAsFixed(4)}, ${widget.restaurant.longitude.toStringAsFixed(4)}"
//                         : "Location not available",
//                     trailingIcon: Icons.open_in_new_rounded,
//                     onTap: widget.restaurant.latitude != 0 && widget.restaurant.longitude != 0
//                         ? () => openGoogleMaps(context)
//                         : null,
//                   ),
//                   const SizedBox(height: 24),

//                   // Actions Section
//                   _buildSectionHeader("Actions"),
//                   const SizedBox(height: 12),

//                   // Call Button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 56,
//                     child: ElevatedButton.icon(
//                       onPressed: () => callRestaurant(context),
//                       icon: const Icon(Icons.call_rounded, color: Color(0xFFFFFFFF), size: 22),
//                       label: Text(
//                         "Call Restaurant",
//                         style: GoogleFonts.poppins(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: const Color(0xFFFFFFFF),
//                           letterSpacing: 0.3,
//                         ),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFA0522D),
//                         foregroundColor: const Color(0xFFFFFFFF),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                         elevation: 0,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),

//                   // Maps Button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 56,
//                     child: OutlinedButton.icon(
//                       onPressed: () => openGoogleMaps(context),
//                       icon: const Icon(Icons.location_on_rounded, color: Color(0xFFA0522D), size: 22),
//                       label: Text(
//                         "Open in Google Maps",
//                         style: GoogleFonts.poppins(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: const Color(0xFFA0522D),
//                           letterSpacing: 0.3,
//                         ),
//                       ),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: const Color(0xFFA0522D),
//                         side: const BorderSide(color: Color(0xFFD2B48C), width: 1.5),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper for Section Headers
//   Widget _buildSectionHeader(String title) {
//     return Row(
//       children: [
//         Container(
//           width: 4,
//           height: 24,
//           decoration: BoxDecoration(
//             color: const Color(0xFFA0522D),
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Text(
//           title,
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: const Color(0xFF2C221E),
//             letterSpacing: 0.3,
//           ),
//         ),
//       ],
//     );
//   }

//   // Helper for Contact Info Tiles
//   Widget _buildContactTile({
//     required IconData icon,
//     required String label,
//     required String value,
//     IconData? trailingIcon,
//     VoidCallback? onTap,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFFFFF),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFFE6E1DC).withValues(alpha: 0.7), width: 1),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFA0522D).withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, color: const Color(0xFFA0522D), size: 22),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF8C827E), fontWeight: FontWeight.w500)),
//                   const SizedBox(height: 2),
//                   Text(
//                     value,
//                     style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF2C221E), fontWeight: FontWeight.w500),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//             if (onTap != null)
//               Icon(trailingIcon ?? Icons.arrow_forward_ios_rounded, size: 16, color: const Color(0xFF8C827E)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/screens/home/restaurant_detail_screen.dart
import 'package:app/model/restaurant_model.dart';
import 'package:app/services/favorite_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final FavoriteService favoriteService = FavoriteService();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadFavorite();
  }

  Future<void> loadFavorite() async {
    try {
      bool favorite = await favoriteService.isFavorite(widget.restaurant.id);
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
        await favoriteService.removeFavoriteByAttraction(widget.restaurant.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Removed from favorites", style: GoogleFonts.poppins(color: const Color(0xFFFFFFFF), fontWeight: FontWeight.w500)),
            backgroundColor: const Color(0xFFBC4749),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        await favoriteService.addFavorite(widget.restaurant.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Added to favorites ❤️", style: GoogleFonts.poppins(color: const Color(0xFFFFFFFF), fontWeight: FontWeight.w500)),
            backgroundColor: const Color(0xFF6A994E),
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
          content: Text("Error: $e", style: GoogleFonts.poppins(color: const Color(0xFFFFFFFF))),
          backgroundColor: const Color(0xFFBC4749),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: const Color(0xFFFFFFFF), fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFFBC4749),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> openGoogleMaps(BuildContext context) async {
    if (widget.restaurant.latitude == 0 && widget.restaurant.longitude == 0) {
      _showErrorSnackBar("Location not available");
      return;
    }

    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${widget.restaurant.latitude},${widget.restaurant.longitude}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      _showErrorSnackBar("Unable to open Google Maps");
    }
  }

  Future<void> callRestaurant(BuildContext context) async {
    if (widget.restaurant.phone.isEmpty) {
      _showErrorSnackBar("Phone number not available");
      return;
    }

    final Uri url = Uri.parse("tel:${widget.restaurant.phone}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!context.mounted) return;
      _showErrorSnackBar("Unable to make call");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: Text(
          widget.restaurant.name,
          style: GoogleFonts.poppins(
            color: const Color(0xFF2C221E),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2C221E)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? const Color(0xFFBC4749) : const Color(0xFF5C524E),
              size: 28,
            ),
            onPressed: toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Color(0xFF2C221E)),
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
                widget.restaurant.image.isEmpty
                    ? Container(
                        height: 280,
                        width: double.infinity,
                        color: const Color(0xFFE6E1DC),
                        child: const Icon(Icons.restaurant_rounded, size: 100, color: Color(0xFF8C827E)),
                      )
                    : Image.network(
                        widget.restaurant.image,
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 280,
                          width: double.infinity,
                          color: const Color(0xFFE6E1DC),
                          child: const Icon(Icons.broken_image, size: 100, color: Color(0xFF8C827E)),
                        ),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 280,
                            width: double.infinity,
                            color: const Color(0xFFE6E1DC),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFA0522D)),
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
                          const Color(0xFF1A120B).withValues(alpha: 0.6),
                          const Color(0xFF1A120B).withValues(alpha: 0.9),
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
                      color: const Color(0xFFA0522D),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFFFFF), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          widget.restaurant.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFFFFFF),
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
                      color: const Color(0xFFFFFFFF).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFA0522D)),
                        const SizedBox(width: 4),
                        Text(
                          widget.restaurant.cityId,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF2C221E),
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
                  // Restaurant Name
                  Text(
                    widget.restaurant.name,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C221E),
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
                          index < widget.restaurant.rating.floor()
                              ? Icons.star_rounded
                              : index < widget.restaurant.rating
                                  ? Icons.star_half_rounded
                                  : Icons.star_outline_rounded,
                          color: const Color(0xFFD4A373),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.restaurant.rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C221E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.restaurant.rating >= 4.5 ? '(Popular)' : '(Good)',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF8C827E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // About Section
                  _buildSectionHeader("About"),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE6E1DC).withValues(alpha: 0.7), width: 1),
                    ),
                    child: Text(
                      widget.restaurant.description,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: const Color(0xFF5C524E),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact Section
                  _buildSectionHeader("Contact Information"),
                  const SizedBox(height: 12),

                  // Phone Card
                  _buildContactTile(
                    icon: Icons.phone_rounded,
                    label: "Phone",
                    value: widget.restaurant.phone.isEmpty ? "Not available" : widget.restaurant.phone,
                    onTap: widget.restaurant.phone.isNotEmpty ? () => callRestaurant(context) : null,
                  ),
                  const SizedBox(height: 12),

                  // Location Card
                  _buildContactTile(
                    icon: Icons.location_on_rounded,
                    label: "Location",
                    value: widget.restaurant.latitude != 0 && widget.restaurant.longitude != 0
                        ? "${widget.restaurant.latitude.toStringAsFixed(4)}, ${widget.restaurant.longitude.toStringAsFixed(4)}"
                        : "Location not available",
                    trailingIcon: Icons.open_in_new_rounded,
                    onTap: widget.restaurant.latitude != 0 && widget.restaurant.longitude != 0
                        ? () => openGoogleMaps(context)
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Actions Section
                  _buildSectionHeader("Actions"),
                  const SizedBox(height: 12),

                  // Call Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => callRestaurant(context),
                      icon: const Icon(Icons.call_rounded, color: Color(0xFFFFFFFF), size: 22),
                      label: Text(
                        "Call Restaurant",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFFFFF),
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA0522D),
                        foregroundColor: const Color(0xFFFFFFFF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Maps Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => openGoogleMaps(context),
                      icon: const Icon(Icons.location_on_rounded, color: Color(0xFFA0522D), size: 22),
                      label: Text(
                        "Open in Google Maps",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA0522D),
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFA0522D),
                        side: const BorderSide(color: Color(0xFFD2B48C), width: 1.5),
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
            color: const Color(0xFFA0522D),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C221E),
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
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E1DC).withValues(alpha: 0.7), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFA0522D).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFA0522D), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF8C827E), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF2C221E), fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(trailingIcon ?? Icons.arrow_forward_ios_rounded, size: 16, color: const Color(0xFF8C827E)),
          ],
        ),
      ),
    );
  }
}