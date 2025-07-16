import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unveilapp/providers/event_provider.dart';

import 'package:unveilapp/routes.dart';
import 'package:unveilapp/theme.dart';

import 'package:unveilapp/services/auth_service.dart';
import 'package:unveilapp/services/firestore.dart';
import 'package:unveilapp/services/get_location.dart';
import 'package:unveilapp/services/event_service.dart';
import 'package:unveilapp/shared/bottom_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<LocationService>(create: (_) => LocationService()),
        ChangeNotifierProvider<BottomNavProvider>(
          create: (_) => BottomNavProvider(),
        ),
        Provider<EventService>(create: (_) => EventService()),
        ChangeNotifierProvider<Eventprovider>(
          create:
              (context) => Eventprovider(
                context.read<EventService>(),
                context.read<FirestoreService>(),
              ),
        ),
      ],

      child: MaterialApp(
        title: 'Unveil App',
        theme: AppTheme.darkTheme,
        initialRoute: '/',
        routes: appRoutes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
