// lib/widgets/event_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unveilapp/models/event_model.dart';
import 'package:unveilapp/providers/event_provider.dart';
// import 'package:unveilapp/screens/event_details_page.dart'; // TODO: Create and import for navigation

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback?
  onFavoriteToggle; // Optional callback if card manages its own toggle
  final VoidCallback? onTap; // Optional callback for card tap

  const EventCard({
    Key? key,
    required this.event,
    this.onFavoriteToggle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap:
            onTap ??
            () {
              // TODO: Navigate to EventDetailsPage
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tapped on ${event.eventName}')),
              );
            },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageSection(context, theme),
            _buildDetailsSection(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, ThemeData theme) {
    if (event.image_url != null && event.image_url!.isNotEmpty) {
      return Hero(
        tag: 'event_image_${event.id}',
        child: Image.network(
          event.image_url!,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => Container(
                height: 200,
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 60,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                  color: theme.colorScheme.secondary,
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Container(
        height: 200,
        color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
        child: Icon(
          Icons.event_seat_outlined,
          size: 80,
          color: theme.colorScheme.onSecondaryContainer.withOpacity(0.5),
        ),
      );
    }
  }

  Widget _buildDetailsSection(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  event.eventName ?? 'Unnamed Event',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Hardcoded favorite icon (non-functional)
              Consumer<Eventprovider>(
                builder: (context, eventProvider, child) {
                  final eventId = int.tryParse(event.id ?? '');
                  bool isFavorite =
                      eventId != null &&
                      eventProvider.currentUserFavoriteEventIds.contains(
                        eventId,
                      );
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color:
                          isFavorite
                              ? theme.colorScheme.secondary
                              : theme.iconTheme.color?.withOpacity(0.7),
                      size: 28,
                    ),
                    onPressed: () {
                      if (eventId != null) {
                        eventProvider.toggleFavorite(eventId);
                      } else {
                        debugPrint('Invalid event ID: ${event.id}');
                      }
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            text: event.displayFullStartTime,
            iconColor: theme.colorScheme.primary,
            theme: theme,
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.location_on_outlined,
            text: event.eventVenue ?? 'Unknown Venue',
            iconColor: theme.colorScheme.primary,
            theme: theme,
          ),
          if (event.eventVenueAddress != null &&
              event.eventVenueAddress!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 28.0, top: 2.0),
              child: Text(
                event.eventVenueAddress!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    event.is_free == 'true'
                        ? theme.colorScheme.tertiaryContainer.withOpacity(0.8)
                        : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                event.is_free == 'true'
                    ? "FREE EVENT"
                    : "Fee: ${event.entranceFee ?? 'N/A'}",
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      event.is_free == 'true'
                          ? theme.colorScheme.onTertiaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final ThemeData theme;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.theme,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 18,
          color:
              iconColor ?? theme.colorScheme.onSurfaceVariant.withOpacity(0.9),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
