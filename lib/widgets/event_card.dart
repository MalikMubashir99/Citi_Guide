// lib/widgets/event_card.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:app/model/event_model.dart';
import 'package:app/screens/home/event_detail_screen.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({
    super.key,
    required this.event,
  });

  // ✅ Unified Placeholder Widget
  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      height: 120,
      width: double.infinity,
      color: AppColors.primarySurface, // Warm ultra-light tint
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
              ),
            )
          : Icon(
              Icons.event_outlined, // Outlined icon for modern look
              size: 36,
              color: AppColors.grey,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.lightGrey.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: AppColors.subtleShadow, // Warm shadow instead of stark black
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailScreen(event: event),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Image Section
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: event.image.isNotEmpty
                      ? Image.network(
                          event.image,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return _buildPlaceholder(isLoading: true);
                          },
                        )
                      : _buildPlaceholder(),
                ),
                
                // ✅ Content Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Description
                      Text(
                        event.description.isNotEmpty 
                            ? event.description 
                            : 'No description available',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.darkGrey,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      
                      // Date & Time Info
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: AppColors.primary, // Cognac accent
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.date.isNotEmpty ? event.date : 'TBD',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.darkGrey,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (event.time.isNotEmpty) ...[
                            Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: AppColors.primary, // Cognac accent
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                event.time,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.darkGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}