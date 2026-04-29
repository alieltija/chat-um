import 'package:cloud_firestore/cloud_firestore.dart';

class DbServices {
  static DbServices instance = DbServices();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String userCollection = "Users";

  Future<void> storeUserData(
    String uid,
    String displayName,
    String email,
    String photoURL,
  ) async {
    try {
      return await _db.collection(userCollection).doc(uid).set({
        "displayName": displayName,
        "email": email,
        "photoURL": photoURL,
        "lastSeen": DateTime.now().toUtc(),
      });
    } catch (e) {
      print("Error: $e");
    }
  }
}
