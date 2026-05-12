import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String uid;
  final String lastmessage;
  final String displayName;
  final String photoURL;
  final String type;
  final Timestamp timestamp;
  final int unseenCount;

  Conversation({
    required this.uid,
    required this.lastmessage,
    required this.type,
    required this.timestamp,
    required this.unseenCount,
    required this.displayName,
    required this.photoURL,
  });

  factory Conversation.fromFirestore(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;

    return Conversation(
      uid: snapshot.id,
      lastmessage: data['lastmessage'] ?? "",
      displayName: data['displayName'] ?? "Unknown",
      photoURL: data['photoURL'] ?? "",
      timestamp: data['timestamp'] ?? Timestamp.now(),
      type: data['type'] ?? "text",
      unseenCount: data['unseenCount'] ?? 0,
    );
  }
}
