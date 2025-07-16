import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unveilapp/models/event_model.dart';
import 'package:unveilapp/models/user_model.dart';
import 'package:unveilapp/services/event_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unveilapp/services/firestore.dart';
import 'dart:async';

enum EventListStatus { initial, loading, loaded, error }

class Eventprovider with ChangeNotifier {
  EventService _eventService = EventService();
  FirestoreService _firestoreService = FirestoreService();
  FirebaseAuth _auth = FirebaseAuth.instance;
  //

  List<EventModel> _forYouEvents = [];
  List<EventModel> get forYouEvents => _forYouEvents;

  EventListStatus _forYouStatus = EventListStatus.initial;
  EventListStatus get forYouStatus => _forYouStatus;

  String _forYouErrorMessage = '';
  String get forYouErrorMessage => _forYouErrorMessage;

  Set<int> _currentUserFavoriteEventIds = {};
  Set<int> get currentUserFavoriteEventIds => _currentUserFavoriteEventIds;

  StreamSubscription<UserModel?>? _userModelSubscription;
  StreamSubscription<User?>? _authStateSubscription;

  Eventprovider(EventService eventService, FirestoreService firestoreService)
    : _eventService = eventService,
      _firestoreService = firestoreService {
    print("EventProvider: Initializing");
    _listenToAuthStateChanges();
  }

  void _listenToAuthStateChanges() {
    _authStateSubscription?.cancel();
    _authStateSubscription = _auth.authStateChanges().listen((User? user) {
      print("EventProvider: Auth state changed: ${user?.uid}");
      _userModelSubscription?.cancel();

      if (user != null) {
        _listenToUserFavorites(user.uid);
        if (_forYouEvents.isEmpty && _forYouStatus == EventListStatus.loading) {
          fetchForYouPageEvents();
        } else {
          _updateEventsFavoriteStatus();
          notifyListeners();
        }
      } else {
        print("EventProvider: User is null, clearing favorites");
        _currentUserFavoriteEventIds.clear();
        _forYouEvents.clear();
        _updateEventsFavoriteStatus();
        notifyListeners();
      }
    });
  }

  void _listenToUserFavorites(String userId) {
    _userModelSubscription?.cancel();
    print("EventProvider: Listening to user favorites for userId: $userId");
    FirestoreService firestoreService = FirestoreService();
    _userModelSubscription = firestoreService
        .getUserStream(userId)
        .listen(
          (UserModel? userModel) {
            if (userModel != null) {
              _currentUserFavoriteEventIds = userModel.favoriteEventIds.toSet();
              print(
                "EventProvider: User favorites updated: ${userModel.favoriteEventIds}",
              );
            } else {
              _currentUserFavoriteEventIds.clear();
              print("EventProvider: User model is null, clearing favorites");
            }

            _updateEventsFavoriteStatus();
            notifyListeners();
          },
          onError: (error) {
            print("EventProvider: Error listening to user favorites: $error");
            _currentUserFavoriteEventIds.clear();
            _updateEventsFavoriteStatus();
            notifyListeners();
          },
        );
  }

  void _updateEventsFavoriteStatus() {
    if (_forYouEvents.isNotEmpty) {
      bool changed = false;
      _forYouEvents =
          _forYouEvents.map((event) {
            final eventId = int.tryParse(event.id ?? '');
            bool newFavStatus =
                eventId != null &&
                _currentUserFavoriteEventIds.contains(event.id);
            if (event.isFavorite != newFavStatus) {
              changed = true;
              return event.copyWith(isFavorite: newFavStatus);
            }
            return event;
          }).toList();
    }
  }

  Future<void> fetchForYouPageEvents() async {
    if (_forYouStatus == EventListStatus.loading && _forYouEvents.isNotEmpty)
      return;
    _forYouStatus = EventListStatus.loading;

    if (_forYouEvents.isEmpty) {
      notifyListeners();
    }

    try {
      final fetchedEvents = await _eventService.fetchForYouEvents();
      _forYouEvents =
          fetchedEvents.map((event) {
            final eventId = int.tryParse(event.id ?? '');
            return event.copyWith(
              isFavorite: _currentUserFavoriteEventIds.contains(eventId),
            );
          }).toList();
      _forYouStatus = EventListStatus.loaded;
      print(
        "EventProvider: Successfully fetched ${_forYouEvents.length} events.",
      );
    } catch (e) {
      _forYouStatus = EventListStatus.error;
      _forYouErrorMessage = e.toString();
      print("EventProvider: Error fetching events: $_forYouErrorMessage");
    }

    notifyListeners();
  }

  Future<void> toggleFavorite(int eventId) async {
    final User? CurrentUser = _auth.currentUser;
    if (CurrentUser == null) {
      _forYouErrorMessage = "Please log in to manage favorite events.";
      notifyListeners();
      return;
    }

    final bool isCurrentlyFavoriteLocally = _currentUserFavoriteEventIds
        .contains(eventId);
    print(
      "EventProvider: Toggling favorite for event $eventId. Currently favorite (local state): $isCurrentlyFavoriteLocally",
    );

    final eventIndex = _forYouEvents.indexWhere((e) => e.id == eventId);
    if (eventIndex >= 0) {
      List<EventModel> updatedEvents = List.from(_forYouEvents);
      updatedEvents[eventIndex] = _forYouEvents[eventIndex].copyWith(
        isFavorite: !isCurrentlyFavoriteLocally,
      );
      _forYouEvents = updatedEvents;
    }

    if (!isCurrentlyFavoriteLocally) {
      _currentUserFavoriteEventIds.add(eventId);
    } else {
      _currentUserFavoriteEventIds.remove(eventId);
    }

    notifyListeners();

    try {
      if (isCurrentlyFavoriteLocally) {
        await _firestoreService.removeFavoriteEventFromUser(eventId);
        print(
          "EventProvider: Removed event $eventId from favorites for user ${CurrentUser.uid}.",
        );
      } else {
        await _firestoreService.addFavoriteEventToUser(eventId);
        print(
          "EventProvider: Added event $eventId to favorites for user ${CurrentUser.uid}.",
        );
      }
    } catch (e) {
      print("EventProvider: Error toggling favorite for event $eventId: $e");

      if (eventIndex >= 0) {
        List<EventModel> revertedEvents = List.from(_forYouEvents);
        revertedEvents[eventIndex] = _forYouEvents[eventIndex].copyWith(
          isFavorite: isCurrentlyFavoriteLocally,
        );
        _forYouEvents = revertedEvents;
      }

      if (!isCurrentlyFavoriteLocally) {
        _currentUserFavoriteEventIds.remove(eventId);
      } else {
        _currentUserFavoriteEventIds.add(eventId);
      }

      _forYouErrorMessage =
          "Failed to update favorite status. Please try again.";
      notifyListeners();
    }
  }

  void dispose() {
    print("EventProvider: Disposing");
    _userModelSubscription?.cancel();
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
