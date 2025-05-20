import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firestore.dart';
import 'package:unveilapp/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart' as location;
import 'get_location.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final LocationService _locationService = LocationService();
  final FirestoreService _firestore = FirestoreService();
  final userStream = FirebaseAuth.instance.authStateChanges();
  final user = FirebaseAuth.instance.currentUser;

  Future<void> anonLogin() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled the sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("User signed in: ${googleUser.email}");

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      print("✅ Firebase Auth User obtained: ${userCredential.user!.uid}");

      location.LocationData? locationData;
      try {
        print("➡️ Attemmpting to get location data...");
        locationData = await _locationService.getCurrentLocation();
        if (locationData != null) {
          print(
            "✅ Location data obtained: Lat: ${locationData.latitude}, Lon: ${locationData.longitude}",
          );
        } else {
          print("❌ Location data is null.");
        }
      } catch (e) {
        print("❌ Error getting location data: $e");
      }

      // Store user data in Firestore

      UserModel userModel = UserModel(
        uid: userCredential.user?.uid,
        name: googleUser.displayName,
        email: googleUser.email,
        signedInAt: Timestamp.now(),
        location: locationData,
      );
      print("📤 Sending to Firestore: ${userModel.toJson()}");

      try {
        print("➡️ About to call FirestoreService.addUser()");
        await _firestore.addUser(userModel);
        print(
          "✅✅✅ User data successfully written to Firestore with UID: ${userModel.uid} ✅✅✅",
        );
      } catch (e) {
        print('❌ Error adding user to Firestore: $e');
        return null;
      }
      User? user = userCredential.user;
      return user;
    } on FirebaseAuthException catch (e, stackTrace) {
      print("🔥 Unexpected error: $e");
      print("🪵 Stacktrace: $stackTrace");

      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }
}
