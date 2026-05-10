import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contac_model.dart';

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

  Stream<Contact> getUserData(String uid) {
    var ref = _db.collection(userCollection).doc(uid);
    return ref.get().asStream().map((snapshot) {
      return Contact.fromFirestore(snapshot);
    });
  }
}
