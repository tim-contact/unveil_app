import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unveilapp/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart' as loc;

class FirestoreService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Adds or updates a user in the 'users' collection using their UID as the document ID
  Future<void> addUser(UserModel user) async {
    print("🛠 addUser called with: ${user.toJson()}");
    if (user.uid == null || user.uid!.isEmpty) {
      throw Exception('User UID is null or empty. Cannot write to Firestore.');
    }

    try {
      await _usersCollection
          .doc(user.uid)
          .set(
            user.toFirestore(),
            SetOptions(merge: true),
          ); // merge to avoid overwriting everything
      print('✅ User ${user.uid} added/updated in Firestore.');
    } catch (e) {
      print('❌ Error adding user to Firestore: $e');
      rethrow;
    }
  }

  /// Fetches a user from the 'users' collection using their UID

  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot snapshot = await _usersCollection.doc(uid).get();
      if (snapshot.exists) {
        UserModel user = snapshot.data() as UserModel;
        print('✅ User ${user.uid} fetched from Firestore.');
        return user;
      } else {
        print('❌ User with UID $uid does not exist in Firestore.');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching user from Firestore: $e');
      rethrow;
    }
  }

  Stream<List<UserModel>> getUsers() {
    return _usersCollection.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map(
                (doc) => UserModel.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                  null,
                ),
              )
              .toList(),
    );
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromFirestore(
          snapshot as DocumentSnapshot<Map<String, dynamic>>,
          null,
        );
      } else {
        return null;
      }
    });
  }

  Future<void> addFavoriteEventToUser(int eventId) async {
    User? user = _auth.currentUser;
    if (user == null || user.uid.isEmpty) {
      throw Exception('No user is currently signed in.');
    }

    try {
      DocumentReference userDoc = _usersCollection.doc(user.uid);
      await userDoc.update({
        'favoriteEventIds': FieldValue.arrayUnion([eventId]),
      });
      print('✅ Event $eventId added to user ${user.uid} favorites.');
    } catch (e) {
      print('❌ Error adding favorite event: $e');
      rethrow;
    }
  }

  Future<void> removeFavoriteEventFromUser(int eventId) async {
    User? user = _auth.currentUser;
    if (user == null || user.uid.isEmpty) {
      throw Exception('No user is currently signed in.');
    }
    try {
      DocumentReference userDoc = _usersCollection.doc(user.uid);
      await userDoc.update({
        'favoriteEventIds': FieldValue.arrayRemove([eventId]),
      });
      print('✅ Event $eventId removed from user ${user.uid} favorites.');
    } catch (e) {
      print('❌ Error removing favorite event: $e');
      rethrow;
    }
  }

  Future<void> updateUserLocation(
    String uid,
    loc.LocationData locationData,
  ) async {
    try {
      await _usersCollection.doc(uid).update({
        'location': {
          'latitude': locationData.latitude,
          'longitude': locationData.longitude,
          'accuracy': locationData.accuracy,
          'altitude': locationData.altitude,
          'speed': locationData.speed,
          'speedAccuracy': locationData.speedAccuracy,
          'heading': locationData.heading,
          'time': locationData.time,
        },
      });
      print('✅ User location updated for UID: $uid');
    } catch (e) {
      print('❌ Error updating user location: $e');
      rethrow;
    }
  }
}
