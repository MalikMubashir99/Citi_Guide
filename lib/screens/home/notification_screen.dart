// lib/screens/profile/notification_screen.dart
import 'package:app/model/in_app_notification.dart';
import 'package:app/services/in_app_notification_service.dart';
import 'package:app/screens/home/city_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final InAppNotificationService _service = InAppNotificationService();
  List<InAppNotification> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _service.getRecentNotifications();
    setState(() {
      _notifications = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () async {
                await _service.markAllAsRead();
                _load();
              },
              child: Text('Mark all read', style: GoogleFonts.poppins(color: Color(0xFF2563EB))),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_rounded, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No recent updates', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (_, i) => _buildTile(_notifications[i]),
                  ),
      ),
    );
  }

  Widget _buildTile(InAppNotification n) {
    return InkWell(
      onTap: () {
        _navigate(n);
        if (!n.isRead) {
          _service.markAsRead(n.id);
          setState(() => n.isRead = true);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          color: n.isRead ? Colors.white : const Color(0xFFEFF6FF),
        ),
        child: Row(
          children: [
            _buildIcon(n.type),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                  Text(n.body, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text(_timeAgo(n.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ),
            if (!n.isRead)
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String type) {
    IconData icon;
    Color color;
    switch (type) {
      case 'city': icon = Icons.location_city; color = const Color(0xFF2563EB); break;
      case 'attraction': icon = Icons.place; color = const Color(0xFF10B981); break;
      case 'event': icon = Icons.event; color = const Color(0xFFF59E0B); break;
      case 'hotel': icon = Icons.hotel; color = const Color(0xFF8B5CF6); break;
      default: icon = Icons.notifications; color = Colors.grey;
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 20),
    );
  }

  void _navigate(InAppNotification n) {
    final id = n.id;
    final data = n.data ?? {};
    switch (n.type) {
      case 'city':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CityDetailScreen(
              cityId: id,
              cityName: data['name'] ?? 'City',
              cityImage: data['image'] ?? '',
            ),
          ),
        );
        break;
      case 'attraction':
        // Navigator.push( context, MaterialPageRoute(builder: (_) => AttractionDetailScreen(attractionId: id)) );
        break;
      case 'event':
        // Navigator.push( context, MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: id)) );
        break;
      case 'hotel':
        // Navigator.push( context, MaterialPageRoute(builder: (_) => HotelDetailScreen(hotelId: id)) );
        break;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}