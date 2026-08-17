// lib/admin/screens/city/city_list_screen.dart
import 'package:app/admin/models/city_model.dart';
import 'package:app/admin/screens/city/city_detail_screen.dart';
import 'package:app/admin/services/city_service.dart';
import 'package:app/admin/widgets/city_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_city_screen.dart';
import 'edit_city_screen.dart';

// ── Direct colors ──
class _AdminColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color dark = Color(0xFF0F172A);
  static const Color darkGrey = Color(0xFF334155);
  static const Color grey = Color(0xFF64748B);
  static const Color lightGrey = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF10B981);
}

class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key});

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  final CityService cityService = CityService();
  final TextEditingController searchController = TextEditingController();
  String searchText = "";
  bool _isLoading = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AdminColors.background,
      appBar: AppBar(
        title: Text(
          "Cities",
          style: GoogleFonts.poppins(
            color: _AdminColors.dark,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: _AdminColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _AdminColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: _AdminColors.primary),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _AdminColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCityScreen()),
          ).then((_) => setState(() {}));
        },
      ),
      body: Column(
        children: [
          // ── Search Bar ──
          _buildSearchBar(),
          // ── City List ──
          Expanded(
            child: StreamBuilder<List<CityModel>>(
              stream: cityService.getCities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _AdminColors.primary,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _AdminColors.error.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: _AdminColors.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading cities',
                            style: GoogleFonts.poppins(
                              color: _AdminColors.dark,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: GoogleFonts.poppins(
                              color: _AdminColors.grey,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => setState(() {}),
                            icon: Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                            label: Text(
                              "Retry",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _AdminColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _AdminColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_city_rounded,
                              size: 56,
                              color: _AdminColors.primary.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "No Cities Found",
                            style: GoogleFonts.poppins(
                              color: _AdminColors.dark,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Tap the + button to add your first city",
                            style: GoogleFonts.poppins(
                              color: _AdminColors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // ── Filter cities by search text ──
                final allCities = snapshot.data!;
                final filteredCities = searchText.isEmpty
                    ? allCities
                    : allCities.where((city) =>
                        city.name.toLowerCase().contains(searchText.toLowerCase())
                    ).toList();

                if (filteredCities.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _AdminColors.grey.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: _AdminColors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No matching cities",
                            style: GoogleFonts.poppins(
                              color: _AdminColors.dark,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Try adjusting your search",
                            style: GoogleFonts.poppins(
                              color: _AdminColors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                searchController.clear();
                                searchText = "";
                              });
                            },
                            icon: Icon(
                              Icons.clear_all_rounded,
                              color: _AdminColors.primary,
                              size: 18,
                            ),
                            label: Text(
                              'Clear search',
                              style: GoogleFonts.poppins(
                                color: _AdminColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  color: _AdminColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = filteredCities[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CityTile(
                          city: city,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CityDetailScreen(city: city),
                              ),
                            );
                          },
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditCityScreen(city: city),
                              ),
                            ).then((_) => setState(() {}));
                          },
                          onDelete: () => _showDeleteDialog(city),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ──
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: _AdminColors.white,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _AdminColors.background,
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          controller: searchController,
          style: GoogleFonts.poppins(fontSize: 15, color: _AdminColors.dark),
          decoration: InputDecoration(
            hintText: "Search cities...",
            hintStyle: GoogleFonts.poppins(color: _AdminColors.grey, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: _AdminColors.primary, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            suffixIcon: searchText.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        searchController.clear();
                        searchText = "";
                      });
                    },
                    icon: Icon(Icons.clear_rounded, color: _AdminColors.grey, size: 20),
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(CityModel city) {
    showDialog(
      context: context,
      builder: (context) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: _AdminColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _AdminColors.error.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 40,
                        color: _AdminColors.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Delete City',
                      style: GoogleFonts.poppins(
                        color: _AdminColors.dark,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Are you sure you want to delete "${city.name}"?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: _AdminColors.darkGrey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      'This action cannot be undone.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: _AdminColors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isDeleting ? null : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                color: _AdminColors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isDeleting
                                ? null
                                : () async {
                                    setDialogState(() => isDeleting = true);
                                    try {
                                      await cityService.deleteCity(city.id);
                                      if (!mounted) return;
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '✅ ${city.name} deleted successfully',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          backgroundColor: _AdminColors.success,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                      setState(() {});
                                    } catch (e) {
                                      setDialogState(() => isDeleting = false);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '❌ Error: $e',
                                            style: GoogleFonts.poppins(),
                                          ),
                                          backgroundColor: _AdminColors.error,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDeleting ? _AdminColors.grey : _AdminColors.error,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isDeleting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Delete',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}