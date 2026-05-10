import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String uid;
  final String displayName;
  final String email;
  final String photoURL;
  final Timestamp lastSeen;

  Contact({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoURL,
    required this.lastSeen,
  });

  factory Contact.fromFirestore(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>?;
    return Contact(
      uid: snapshot.id,
      lastSeen: data?["lastSeen"] ?? Timestamp.now(),
      email: data?["email"] ?? "",
      displayName: data?["displayName"] ?? "",
      photoURL: data?["photoURL"] ?? "",
    );
  }
}
