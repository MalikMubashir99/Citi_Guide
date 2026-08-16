

// lib/admin/screens/attraction/attractions_screen.dart
import 'package:app/admin/models/attraction_model.dart';
import 'package:app/admin/models/city_model.dart';
import 'package:app/admin/screens/attraction/add_attraction_screen.dart';
import 'package:app/admin/screens/attraction/edit_attraction_screen.dart';
import 'package:app/admin/services/attraction_service.dart';
import 'package:app/admin/services/city_service.dart';
import 'package:app/admin/widgets/attraction_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: _AdminColors.background,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: _AdminColors.primary, size: 24),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _AdminColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: _isLoading
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddAttractionScreen()),
                ).then((_) => setState(() {}));
              },
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // ── Search & Filter Section ──
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: BoxDecoration(
                  color: _AdminColors.white,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ── Search Field (pill shape, no outline) ──
                    Container(
                      decoration: BoxDecoration(
                        color: _AdminColors.background,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: searchController,
                        style: GoogleFonts.poppins(fontSize: 15, color: _AdminColors.dark),
                        decoration: InputDecoration(
                          hintText: "Search attractions...",
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
                        onChanged: (value) => setState(() => searchText = value.toLowerCase()),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── City Filter Chips ──
                    StreamBuilder<List<CityModel>>(
                      stream: cityService.getCities(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        final cities = snapshot.data!;
                        return SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildFilterChip(
                                label: "All",
                                isSelected: selectedCity == null,
                                onTap: () => setState(() => selectedCity = null),
                              ),
                              const SizedBox(width: 8),
                              ...cities.map((city) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildFilterChip(
                                    label: city.name,
                                    isSelected: selectedCity == city.id,
                                    onTap: () => setState(() {
                                      selectedCity = selectedCity == city.id ? null : city.id;
                                    }),
                                  ),
                                );
                              }),
                            ],
                          ),
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
                                child: Icon(Icons.error_outline_rounded, size: 48, color: _AdminColors.error),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading attractions',
                                style: GoogleFonts.poppins(color: _AdminColors.dark, fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please try again',
                                style: GoogleFonts.poppins(color: _AdminColors.grey, fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => setState(() {}),
                                icon: Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                                label: Text('Retry', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _AdminColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                  Icons.landscape_rounded,
                                  size: 56,
                                  color: _AdminColors.primary.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "No Attractions Yet",
                                style: GoogleFonts.poppins(color: _AdminColors.dark, fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Tap the + button to add your first attraction",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(color: _AdminColors.grey, fontSize: 14, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final filteredAttractions = snapshot.data!.where((item) {
                      final matchesSearch = item.name.toLowerCase().contains(searchText);
                      final matchesCity = selectedCity == null || item.cityId == selectedCity;
                      return matchesSearch && matchesCity;
                    }).toList();

                    if (filteredAttractions.isEmpty) {
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
                                child: Icon(Icons.search_off_rounded, size: 48, color: _AdminColors.grey),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No matching attractions",
                                style: GoogleFonts.poppins(color: _AdminColors.dark, fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Try adjusting your search or filters",
                                style: GoogleFonts.poppins(color: _AdminColors.grey, fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    searchController.clear();
                                    searchText = "";
                                    selectedCity = null;
                                  });
                                },
                                icon: Icon(Icons.clear_all_rounded, color: _AdminColors.primary, size: 18),
                                label: Text(
                                  'Clear all filters',
                                  style: GoogleFonts.poppins(color: _AdminColors.primary, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final sortedAttractions = List.from(filteredAttractions)
                      ..sort((a, b) => b.rating.compareTo(a.rating));

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: sortedAttractions.length,
                      itemBuilder: (context, index) {
                        final attraction = sortedAttractions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AttractionCard(
                            attraction: attraction,
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditAttractionScreen(attraction: attraction),
                                ),
                              ).then((_) => setState(() {}));
                            },
                            onDelete: () => _confirmDelete(attraction),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.35),
              child: const Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(strokeWidth: 3, color: _AdminColors.primary),
                        SizedBox(height: 16),
                        Text(
                          'Deleting...',
                          style: TextStyle(color: _AdminColors.dark, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _AdminColors.primary : _AdminColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _AdminColors.primary : _AdminColors.lightGrey.withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: _AdminColors.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(Icons.check_rounded, size: 14, color: Colors.white),
              ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : _AdminColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(AttractionModel attraction) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: _AdminColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                      child: Icon(Icons.delete_outline_rounded, size: 40, color: _AdminColors.error),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Delete Attraction',
                      style: GoogleFonts.poppins(color: _AdminColors.dark, fontWeight: FontWeight.w700, fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Are you sure you want to delete "${attraction.name}"?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: _AdminColors.darkGrey, fontSize: 14, height: 1.5),
                    ),
                    Text(
                      'This action cannot be undone.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: _AdminColors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isDeleting ? null : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(color: _AdminColors.grey, fontWeight: FontWeight.w600, fontSize: 15),
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
                                      await attractionService.deleteAttraction(attraction.id);
                                      if (!mounted) return;
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('✅ ${attraction.name} deleted'),
                                          backgroundColor: _AdminColors.success,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                      setState(() {});
                                    } catch (e) {
                                      setDialogState(() => isDeleting = false);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('❌ Error: $e'),
                                          backgroundColor: _AdminColors.error,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDeleting ? _AdminColors.grey : _AdminColors.error,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: isDeleting
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                : Text('Delete', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
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