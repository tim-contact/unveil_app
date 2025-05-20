import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unveilapp/models/user_model.dart';

class FirestoreService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');

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
    return _usersCollection.snapshots().map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(
          snapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>,
          null,
        );
      } else {
        return null;
      }
    });
  }
}
