// lib/screens/for_you_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:unveilapp/models/event_model.dart'; // Not directly needed here anymore
import 'package:unveilapp/providers/event_provider.dart';
import 'package:unveilapp/shared/widgets/event_card.dart';

class ForYouPage extends StatelessWidget {
  const ForYouPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<Eventprovider>(
        builder: (context, eventProvider, child) {
          // trigger initial fetch if not already done
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (eventProvider.forYouStatus == EventListStatus.initial) {
              eventProvider.fetchForYouPageEvents();
            }
          });
          // Handle Loading State
          if (eventProvider.forYouStatus == EventListStatus.loading &&
              eventProvider.forYouEvents.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle Error State
          if (eventProvider.forYouStatus == EventListStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Failed to load events.',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      eventProvider.forYouErrorMessage.contains(
                                "SocketException",
                              ) ||
                              eventProvider.forYouErrorMessage.contains(
                                "HttpException",
                              ) ||
                              eventProvider.forYouErrorMessage.contains(
                                "Network error",
                              )
                          ? "Please check your internet connection."
                          : "An unexpected error occurred retrieving events.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      onPressed: () => eventProvider.fetchForYouPageEvents(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Handle No Events Loaded State
          if (eventProvider.forYouEvents.isEmpty &&
              eventProvider.forYouStatus == EventListStatus.loaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.event_busy_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No events available right now.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Check Again'),
                    onPressed: () => eventProvider.fetchForYouPageEvents(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Display Events using the shared EventCard
          return RefreshIndicator(
            onRefresh: () => eventProvider.fetchForYouPageEvents(),
            color: Theme.of(context).colorScheme.secondary,
            child: SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 16.0,
                ), // Padding for the list itself
                itemCount: eventProvider.forYouEvents.length,
                itemBuilder: (context, index) {
                  final event = eventProvider.forYouEvents[index];
                  return EventCard(
                    event: event,
                    // You could provide custom onTap or onFavoriteToggle here if needed:
                    // onTap: () { /* Custom tap action for ForYouPage */ },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
