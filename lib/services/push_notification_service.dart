// lib/services/push_notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// If you need to store the token in Firestore:
// import 'package:unveilapp/services/firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// Function to handle messages when the app is in the background or terminated
// This needs to be a top-level function (not inside a class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you need to do some processing with the message (e.g., data messages), do it here
  print("Handling a background message: ${message.messageId}");
  print('Message data: ${message.data}');
  print('Message notification: ${message.notification?.title}');
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  // If you were storing tokens, you'd inject FirestoreService
  // final Firestore _firestoreService;
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // PushNotificationService(this._firestoreService);

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // --- Initialize Local Notifications ---
    await _initializeLocalNotifications();

    // --- Request Permissions ---
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false, // Set to true for "provisional" permissions on iOS
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission. Initializing notifications...');
      // --- Subscribe to Topic ---
      // This is the most efficient way to send "new event" notifications to everyone
      await _fcm.subscribeToTopic('daily_event_digest');
      await _fcm.subscribeToTopic('event_reminders_24hr');
      print(
        "Subscribed to 'daily_event_digest' and 'event_reminders_24hr' topics.",
      );

      // --- Handle different notification states ---
      _setupListeners();

      // Get the token and save it to Firestore (if you need to target individual users later)
      // _getTokenAndSave();
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void _handleMessageNavigation(Map<String, dynamic> data) {
    final String? eventId = data['eventId'];
    if (eventId != null) {
      print("Notification tapped! Navigate to details for event ID: $eventId");
      // TODO: Implement your global navigation logic here.
      // You might use a GlobalKey<NavigatorState> or a state management solution
      // to navigate to the EventDetailsPage for this eventId.
      // Example: navigatorKey.currentState?.pushNamed('/event-details', arguments: eventId);
    }
  }

  // --- Optional: For saving token to Firestore for direct user messaging ---
  // Future<void> _getTokenAndSave() async {
  //   final fcmToken = await _fcm.getToken();
  //   if (fcmToken != null) {
  //     print("My FCM Token: $fcmToken");
  //     final currentUser = _auth.currentUser;
  //     if (currentUser != null) {
  //       await _firestoreService.saveUserFCMToken(fcmToken);
  //     }
  //   }
  // }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Local notification tapped: ${response.payload}');
        // Handle local notification tap
        if (response.payload != null) {
          _handleMessageNavigation({'eventId': response.payload});
        }
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  void _setupListeners() {
    // --- Handle Terminated State ---
    // If the app is opened from a terminated state via a notification, this message is returned.
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state by notification!');
        // TODO: Handle navigation to a specific page based on the message data
        // For example: if (message.data['eventId'] != null) { ... navigate ... }
        _handleMessageNavigation(message.data);
      }
    });

    // --- Handle Background State ---
    // This listener is called when the app is in the background and the user taps on the notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background state by notification!');
      // TODO: Handle navigation
      _handleMessageNavigation(message.data);
    });

    // --- Handle Foreground State ---
    // This listener is called when a notification is received while the app is in the foreground.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        print('Message also contained a notification: ${notification.title}');
        // On Android, we need to manually display a notification using flutter_local_notifications
        // because FCM doesn't show heads-up notifications when the app is in the foreground.
        // iOS handles this automatically.
        if (android != null) {
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel', // Must match channel_id in AndroidManifest.xml
                'High Importance Notifications',
                channelDescription:
                    'This channel is used for important notifications.',
                icon: '@mipmap/ic_launcher', // Standard launcher icon
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
            payload: message.data['eventId'], // Example payload
          );
        }
      }
    });

    // --- Background Message Handler ---
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}
