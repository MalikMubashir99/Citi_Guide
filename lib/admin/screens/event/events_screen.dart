// lib/admin/screens/event/events_screen.dart
import 'package:app/admin/models/city_model.dart';
import 'package:app/admin/models/event_model.dart';
import 'package:app/admin/screens/event/add_event_screen.dart';
import 'package:app/admin/screens/event/edit_event_screen.dart';
import 'package:app/admin/services/city_service.dart';
import 'package:app/admin/services/event_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

class EventsScreen extends StatefulWidget {

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventService eventService = EventService();
  final CityService cityService = CityService();
  final TextEditingController searchController = TextEditingController();
  

  String searchText = "";
  String? selectedCityId;
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
          "Events",
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
            MaterialPageRoute(builder: (_) => const AddEventScreen()),
          ).then((_) => setState(() {}));
        },
      ),
      body: Column(
        children: [
          // ── Search Bar ──
          _buildSearchBar(),

          // ── City Filter Dropdown (using StreamBuilder) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: StreamBuilder<List<CityModel>>(
              stream: cityService.getCities(), // ✅ Stream
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 50,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _AdminColors.primary,
                      ),
                    ),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }

                final cities = snapshot.data!;
                return DropdownButtonFormField<String>(
                  value: selectedCityId,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: "Filter by City",
                    labelStyle: GoogleFonts.poppins(
                      color: _AdminColors.grey,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: _AdminColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _AdminColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _AdminColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      selectedCityId = value;
                    });
                  },
                );
              },
            ),
          ),

          // ── Events List ──
          Expanded(
            child: StreamBuilder<List<EventModel>>(
              stream: eventService.getEvents(),
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
                  return _buildErrorState(snapshot.error.toString());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                // ── Apply filters ──
                final allEvents = snapshot.data!;
                final filteredEvents = allEvents.where((event) {
                  final matchesSearch = event.title
                      .toLowerCase()
                      .contains(searchText.toLowerCase());
                  final matchesCity =
                      selectedCityId == null || event.cityId == selectedCityId;
                  return matchesSearch && matchesCity;
                }).toList();

                if (filteredEvents.isEmpty) {
                  return _buildNoResultsState();
                }

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  color: _AdminColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return _buildEventCard(event);
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
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
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
            hintText: "Search events...",
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
          onChanged: (value) => setState(() => searchText = value),
        ),
      ),
    );
  }

  // ── Event Card ──
  Widget _buildEventCard(EventModel event) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _AdminColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _AdminColors.lightGrey.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 70,
              height: 70,
              color: _AdminColors.lightGrey.withOpacity(0.4),
              child: event.image.isNotEmpty
                  ? Image.network(
                      event.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.broken_image,
                        color: _AdminColors.grey,
                        size: 30,
                      ),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _AdminColors.primary,
                            ),
                          ),
                        );
                      },
                    )
                  : Icon(Icons.event_rounded, color: _AdminColors.grey, size: 36),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _AdminColors.dark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  event.date,
                  style: GoogleFonts.poppins(fontSize: 12, color: _AdminColors.grey),
                ),
                if (event.location.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 12, color: _AdminColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: GoogleFonts.poppins(fontSize: 11, color: _AdminColors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _AdminColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.edit_rounded, color: _AdminColors.primary, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditEventScreen(event: event),
                      ),
                    ).then((_) => setState(() {}));
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  tooltip: 'Edit',
                ),
              ),
              const SizedBox(width: 4),
              Container(
                decoration: BoxDecoration(
                  color: _AdminColors.error.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: _AdminColors.error, size: 20),
                  onPressed: () => _confirmDelete(event),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  tooltip: 'Delete',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helper States ──
  Widget _buildErrorState(String error) {
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
              'Error loading events',
              style: GoogleFonts.poppins(
                color: _AdminColors.dark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.poppins(color: _AdminColors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
              label: Text("Retry", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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

  Widget _buildEmptyState() {
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
                Icons.event_rounded,
                size: 56,
                color: _AdminColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "No Events Found",
              style: GoogleFonts.poppins(
                color: _AdminColors.dark,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the + button to add your first event",
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

  Widget _buildNoResultsState() {
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
              "No matching events",
              style: GoogleFonts.poppins(
                color: _AdminColors.dark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
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
                  selectedCityId = null;
                });
              },
              icon: Icon(Icons.clear_all_rounded, color: _AdminColors.primary, size: 18),
              label: Text(
                'Clear filters',
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

  // ── Delete Confirmation ──
  void _confirmDelete(EventModel event) {
    showDialog(
      context: context,
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
                      'Delete Event',
                      style: GoogleFonts.poppins(
                        color: _AdminColors.dark,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Are you sure you want to delete "${event.title}"?',
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
                                      await eventService.deleteEvent(event.id);
                                      if (!mounted) return;
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '✅ ${event.title} deleted',
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
                                          content: Text('❌ Error: $e', style: GoogleFonts.poppins()),
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