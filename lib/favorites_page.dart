// lib/screens/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unveilapp/models/event_model.dart';
import 'package:unveilapp/models/user_model.dart' as firestore_user; // Aliased
import 'package:unveilapp/services/event_service.dart';
import 'package:unveilapp/services/firestore.dart';
import 'package:unveilapp/services/auth_service.dart';
import 'package:unveilapp/shared/widgets/event_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );
    final String? currentUserId = authService.user?.uid;

    if (currentUserId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Please log in to view and manage your favorite events.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<firestore_user.UserModel?>(
          stream: firestoreService.getUserStream(currentUserId),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting &&
                !userSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (userSnapshot.hasError) {
              return Center(
                child: Text("Error loading favorites: ${userSnapshot.error}"),
              );
            }
            // Allow building list even if userSnapshot.data is null initially,
            // as favoriteEventIds will be empty.
            final favoriteEventIds = userSnapshot.data?.favoriteEventIds ?? [];

            if (favoriteEventIds.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No favorite events yet.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the ❤️ on an event to add it here.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 12.0,
              ),
              itemCount: favoriteEventIds.length,
              itemBuilder: (context, index) {
                final eventId = favoriteEventIds[index];
                // This FavoriteEventLoader will fetch and display the EventCard
                return FavoriteEventLoader(eventId: eventId);
              },
            );
          },
        ),
      ),
    );
  }
}

class FavoriteEventLoader extends StatelessWidget {
  final int eventId;

  const FavoriteEventLoader({Key? key, required this.eventId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final eventService = Provider.of<EventService>(context, listen: false);

    return FutureBuilder<EventModel?>(
      future: eventService.fetchEventById(
        eventId,
      ), // Fetches event details from PostgreSQL backend
      builder: (context, eventSnapshot) {
        if (eventSnapshot.connectionState == ConnectionState.waiting) {
          // You can return a shimmer/placeholder card here for better UX
          return const Card(
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
            child: SizedBox(
              height: 250,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }
        if (eventSnapshot.hasError ||
            !eventSnapshot.hasData ||
            eventSnapshot.data == null) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
            color: Theme.of(
              context,
            ).colorScheme.errorContainer.withOpacity(0.5),
            child: ListTile(
              leading: Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              title: Text(
                'Could not load event (ID: $eventId)',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              subtitle: Text(
                'This event might have been removed or an error occurred.',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onErrorContainer.withOpacity(0.8),
                ),
              ),
            ),
          );
        }

        final eventFromApi = eventSnapshot.data!;

        // The EventCard itself uses a Consumer<EventProvider> to get the live favorite status.
        // So, we don't strictly need to pass isFavorite here, but the EventModel from API
        // won't have it. The EventCard's Consumer will handle it.

        final eventWithFavoriteStatus = eventFromApi.copyWith(
          isFavorite: true, // Assume it's favorite since we're in FavoritesPage
        );
        return EventCard(event: eventWithFavoriteStatus);
      },
    );
  }
}
