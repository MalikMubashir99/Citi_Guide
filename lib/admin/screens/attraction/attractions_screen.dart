// lib/admin/screens/attraction/attractions_screen.dart
import 'package:app/admin/models/attraction_model.dart';
import 'package:app/admin/models/city_model.dart';
import 'package:app/admin/services/attraction_service.dart';
import 'package:app/admin/services/city_service.dart';
import 'package:app/admin/widgets/attraction_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_attraction_screen.dart';
import 'edit_attraction_screen.dart';

// ── Direct colors (no AppColors) ──
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
  static const Color warning = Color(0xFFF59E0B);
}

class AttractionsScreen extends StatefulWidget {
  const AttractionsScreen({super.key});

  @override
  State<AttractionsScreen> createState() => _AttractionsScreenState();
}

class _AttractionsScreenState extends State<AttractionsScreen> {
  final AttractionService attractionService = AttractionService();
  final CityService cityService = CityService();

  final TextEditingController searchController = TextEditingController();
  String searchText = "";
  String? selectedCity;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AdminColors.background,
      appBar: AppBar(
        title: Text(
          "Attractions",
          style: GoogleFonts.poppins(
            color: _AdminColors.dark,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: _AdminColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: _AdminColors.primary),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _AdminColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _isLoading
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>  AddAttractionScreen()),
                ).then((_) => setState(() {}));
              },
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // ── Search & Filter Section ──
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: _AdminColors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Search field
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search Attractions...",
                        hintStyle: GoogleFonts.poppins(
                          color: _AdminColors.grey,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: _AdminColors.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _AdminColors.lightGrey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _AdminColors.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: _AdminColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText = value.toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    // City filter dropdown
                    StreamBuilder<List<CityModel>>(
                      stream: cityService.getCities(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }

                        final cities = snapshot.data!;
                        return Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedCity,
                                isDense: true,
                                decoration: InputDecoration(
                                  labelText: "Filter by City",
                                  labelStyle: GoogleFonts.poppins(
                                    color: _AdminColors.grey,
                                    fontSize: 13,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: _AdminColors.lightGrey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: _AdminColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: _AdminColors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text("All Cities"),
                                  ),
                                  ...cities.map((city) {
                                    return DropdownMenuItem<String>(
                                      value: city.id,
                                      child: Text(city.name),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedCity = value;
                                  });
                                },
                              ),
                            ),
                            if (selectedCity != null) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectedCity = null;
                                  });
                                },
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: _AdminColors.grey,
                                  size: 20,
                                ),
                                tooltip: "Clear filter",
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Attractions List ──
              Expanded(
                child: StreamBuilder<List<AttractionModel>>(
                  stream: attractionService.getAttractions(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _AdminColors.primary,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: _AdminColors.error,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Error loading attractions',
                              style: GoogleFonts.poppins(
                                color: _AdminColors.error,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => setState(() {}),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _AdminColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Retry',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.landscape_rounded,
                              size: 64,
                              color: _AdminColors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No Attractions",
                              style: GoogleFonts.poppins(
                                color: _AdminColors.grey,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Tap the + button to add an attraction",
                              style: GoogleFonts.poppins(
                                color: _AdminColors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // ── Apply filters ──
                    final filteredAttractions = snapshot.data!.where((item) {
                      final matchesSearch =
                          item.name.toLowerCase().contains(searchText);
                      final matchesCity =
                          selectedCity == null || item.cityId == selectedCity;
                      return matchesSearch && matchesCity;
                    }).toList();

                    if (filteredAttractions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: _AdminColors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "No matching attractions",
                              style: GoogleFonts.poppins(
                                color: _AdminColors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  searchController.clear();
                                  searchText = "";
                                  selectedCity = null;
                                });
                              },
                              icon: Icon(
                                Icons.clear_all_rounded,
                                color: _AdminColors.primary,
                              ),
                              label: Text(
                                'Clear filters',
                                style: GoogleFonts.poppins(
                                  color: _AdminColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // ── Sort by rating (highest first) ──
                    final sortedAttractions =
                        List.from(filteredAttractions)
                          ..sort((a, b) => b.rating.compareTo(a.rating));

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sortedAttractions.length,
                      itemBuilder: (context, index) {
                        final attraction = sortedAttractions[index];
                        return AttractionCard(
                          attraction: attraction,
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditAttractionScreen(attraction: attraction),
                              ),
                            ).then((_) => setState(() {}));
                          },
                          onDelete: () => _confirmDelete(attraction),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // ── Loading overlay ──
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: _AdminColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Delete Confirmation Dialog with local loading ──
  void _confirmDelete(AttractionModel attraction) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _AdminColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.warning_rounded, color: _AdminColors.error),
                  const SizedBox(width: 8),
                  Text(
                    'Delete Attraction',
                    style: GoogleFonts.poppins(
                      color: _AdminColors.dark,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Are you sure you want to delete "${attraction.name}"? This action cannot be undone.',
                style: GoogleFonts.poppins(
                  color: _AdminColors.darkGrey,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color: _AdminColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setDialogState(() => isDeleting = true);
                          try {
                            await attractionService.deleteAttraction(
                              attraction.id,
                            );
                            if (!mounted) return;
                            Navigator.pop(context); // close dialog

                            // Show success
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '✅ ${attraction.name} deleted successfully',
                                ),
                                backgroundColor: _AdminColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            // Force refresh list
                            setState(() {});
                          } catch (e) {
                            setDialogState(() => isDeleting = false);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('❌ Error: $e'),
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
                    backgroundColor: _AdminColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Delete',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}