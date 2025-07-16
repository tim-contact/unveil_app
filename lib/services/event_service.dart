// lib/services/event_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unveilapp/models/event_model.dart'; // Adjust path if necessary
// Uncomment if you need to send auth tokens for protected routes
// import 'package:firebase_auth/firebase_auth.dart';

class EventService {
  // --- IMPORTANT: CONFIGURE YOUR BASE URL ---
  // Option 1: Local development with Android Emulator
  // static const String _baseUrl = "http://10.0.2.2:3000/api"; // Port 3000 is an example

  // Option 2: Local development with iOS Simulator or Web (if backend on same machine)
  static const String _baseUrl =
      "http://10.232.129.109:3000/api"; // Defaulting to this for now

  // Option 3: Deployed backend (REPLACE WITH YOUR ACTUAL DEPLOYED URL)
  // static const String _baseUrl = "https://your-deployed-backend-app.com/api";
  // ------------------------------------------

  // Helper to get Firebase ID token for authenticated requests (if needed)
  // Future<String?> _getIdToken() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     try {
  //       return await user.getIdToken(true); // Pass true to force refresh if needed
  //     } catch (e) {
  //       print("Error getting ID token: $e");
  //       return null;
  //     }
  //   }
  //   return null;
  // }

  // Helper for constructing headers
  Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    // if (requireAuth) {
    //   final token = await _getIdToken();
    //   if (token != null) {
    //     headers['Authorization'] = 'Bearer $token';
    //   } else {
    //     // Handle case where auth is required but token is not available
    //     // This might involve throwing an error or returning a specific status
    //     print("Auth required but no token available.");
    //   }
    // }
    return headers;
  }

  /// Fetches events for the "For You" page.
  /// Corresponds to your backend's GET /api/forYouEvents endpoint.
  Future<List<EventModel>> fetchForYouEvents() async {
    final Uri url = Uri.parse('$_baseUrl/forYouEvents');
    print("EventService: Fetching events for ForYouPage from: $url");

    try {
      final headers = await _getHeaders(); // Public endpoint for now
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 20)); // Increased timeout

      if (response.statusCode == 200) {
        // The backend directly returns an array of events for this endpoint
        List<dynamic> body = jsonDecode(response.body);
        List<EventModel> events =
            body
                .map(
                  (dynamic item) =>
                      EventModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
        print(
          "EventService: Fetched ${events.length} events for ForYouPage successfully.",
        );
        return events;
      } else {
        print(
          "EventService: Failed to load ForYouPage events. Status: ${response.statusCode}, Body: ${response.body}",
        );
        throw Exception(
          'Failed to load events (Status Code: ${response.statusCode} - ${response.reasonPhrase})',
        );
      }
    } catch (e) {
      print("EventService: Error fetching ForYouPage events: $e");
      // More specific error handling (e.g., SocketException for no network)
      if (e is http.ClientException ||
          e.toString().contains('SocketException')) {
        throw Exception('Network error. Please check your connection.');
      }
      throw Exception('An error occurred while fetching events: $e');
    }
  }

  /// Fetches a single event by its ID.
  /// Corresponds to your backend's GET /api/event/:eventId endpoint.
  Future<EventModel?> fetchEventById(int id) async {
    // Ensure your backend endpoint matches this path structure (e.g., /event/:id or /events/:id)
    final Uri url = Uri.parse('$_baseUrl/eventDetails/$id');
    print("EventService: Fetching event by ID $id from: $url");

    try {
      final headers = await _getHeaders(); // Assuming public for now
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(response.body);
        EventModel event = EventModel.fromJson(body);
        print("EventService: Fetched event ID $id successfully.");
        return event;
      } else if (response.statusCode == 404) {
        print("EventService: Event ID $id not found on backend.");
        return null; // Event not found
      } else {
        print(
          "EventService: Failed to load event ID $id. Status: ${response.statusCode}, Body: ${response.body}",
        );
        throw Exception(
          'Failed to load event details (Status Code: ${response.statusCode} - ${response.reasonPhrase})',
        );
      }
    } catch (e) {
      print("EventService: Error fetching event ID $id: $e");
      if (e is http.ClientException ||
          e.toString().contains('SocketException')) {
        throw Exception('Network error. Please check your connection.');
      }
      throw Exception('An error occurred while fetching event details: $e');
    }
  }

  /// Fetches nearby events based on user's location and a radius.
  /// Corresponds to your backend's GET /api/nearbyEvents endpoint.
  Future<List<EventModel>> fetchNearbyEvents({
    required double latitude,
    required double longitude,
    int radiusInMeters = 50000, // Default radius: 50km
  }) async {
    final queryParameters = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'radius': radiusInMeters.toString(),
    };

    // Constructing the URI with query parameters
    // Splitting _baseUrl to correctly form authority and path for Uri.http/https
    final String scheme = _baseUrl.startsWith('https') ? 'https' : 'http';
    final String authority =
        _baseUrl.replaceAll(RegExp(r'^https?://'), '').split('/')[0];
    final String unencodedPath =
        '${_baseUrl.substring(_baseUrl.indexOf(authority) + authority.length)}/nearbyEvents';

    final Uri url =
        scheme == 'https'
            ? Uri.https(authority, unencodedPath, queryParameters)
            : Uri.http(authority, unencodedPath, queryParameters);

    print("EventService: Fetching nearby events from: $url");

    try {
      // Assuming this route is protected in your backend as per your example
      final headers = await _getHeaders(requireAuth: true);
      // If the token is not available and auth is required, _getHeaders might need to throw or this function should check.
      // For simplicity, assuming _getHeaders handles adding the token if requireAuth is true.
      // If you require authentication for this endpoint, make sure your _getHeaders function
      // correctly fetches and adds the Firebase ID token.

      final response = await http
          .get(url, headers: headers)
          .timeout(
            const Duration(seconds: 25),
          ); // Longer timeout for potentially complex query

      if (response.statusCode == 200) {
        // Assuming the backend returns { "events": [...] }
        Map<String, dynamic> decodedResponse = jsonDecode(response.body);
        List<dynamic> body = decodedResponse['events'] ?? [];
        List<EventModel> events =
            body
                .map(
                  (dynamic item) =>
                      EventModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
        print(
          "EventService: Fetched ${events.length} nearby events successfully.",
        );
        return events;
      } else {
        print(
          "EventService: Failed to load nearby events. Status: ${response.statusCode}, Body: ${response.body}",
        );
        // Check for specific auth errors if applicable
        if (response.statusCode == 401 || response.statusCode == 403) {
          throw Exception('Authentication error: Please log in again.');
        }
        throw Exception(
          'Failed to load nearby events (Status Code: ${response.statusCode} - ${response.reasonPhrase})',
        );
      }
    } catch (e) {
      print("EventService: Error fetching nearby events: $e");
      if (e is http.ClientException ||
          e.toString().contains('SocketException')) {
        throw Exception('Network error. Please check your connection.');
      }
      throw Exception('An error occurred while fetching nearby events: $e');
    }
  }

  // --- Placeholder for future methods ---

  // Example: Posting a new event (would require a different backend endpoint and model)
  // Future<EventModel> createEvent(Map<String, dynamic> eventData) async {
  //   final Uri url = Uri.parse('$_baseUrl/addNewEvent'); // Or your create event endpoint
  //   final headers = await _getHeaders(requireAuth: true);
  //
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: headers,
  //       body: jsonEncode(eventData),
  //     ).timeout(const Duration(seconds: 20));
  //
  //     if (response.statusCode == 201) { // 201 Created
  //       return EventModel.fromJson(jsonDecode(response.body));
  //     } else {
  //       throw Exception('Failed to create event (Status: ${response.statusCode})');
  //     }
  //   } catch (e) {
  //     throw Exception('Error creating event: $e');
  //   }
  // }
}
