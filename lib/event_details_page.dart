import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:unveilapp/models/event_model.dart';

class EventDetailsPage extends StatelessWidget {
  final EventModel event;

  const EventDetailsPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            floating: false,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                event.eventName ?? 'Event Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Hero(
                tag: 'event_image_${event.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      event.image_url ?? '',
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: Colors.grey,
                            child: const Icon(Icons.error, color: Colors.white),
                          ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(context, theme),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'About this Event', theme),
                  const SizedBox(height: 8),
                  Text(
                    event.description ?? 'No description available.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (event.specialGuests != null &&
                      event.specialGuests!.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Special Guests', theme),
                    const SizedBox(height: 8),
                    Text(
                      event.specialGuests!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.calendar_today,
              title: 'Date & Time',
              content: event.displayFullStartTime,
              theme: theme,
            ),
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.location_on,
              title: 'Venue',
              content:
                  '${event.eventVenue ?? 'N/A'}\n${event.eventVenueAddress ?? ''}',
              theme: theme,
            ),
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.confirmation_number,
              title: 'Entrance',
              content:
                  event.is_free == "true" ? "Free" : event.entranceFee ?? 'N/A',
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    ThemeData theme,
  ) {
    return Text(
      title,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final ThemeData theme;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.content,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.secondary, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
