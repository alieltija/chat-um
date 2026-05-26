import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_model.dart';

class ConversationSnippet {
  final String uid;
  final String displayName;
  final String photoURL;
  final String lastmessage;
  final String type;
  final int unseenCount;
  final Timestamp timestamp;

  ConversationSnippet({
    required this.uid,
    required this.displayName,
    required this.photoURL,
    required this.lastmessage,
    required this.type,
    required this.unseenCount,
    required this.timestamp,
  });

  factory ConversationSnippet.fromFirestore(DocumentSnapshot snapshot) {
    // Safe extraction of Document fields
    final Map<String, dynamic> data =
        snapshot.data() as Map<String, dynamic>? ?? {};

    return ConversationSnippet(
      uid: snapshot.id,
      displayName: data['displayName'] ?? data['name'] ?? 'Unknown User',
      photoURL: data['photoURL'] ?? data['image'] ?? '',
      lastmessage: data['lastmessage'] ?? '',
      type: data['type'] ?? 'text',
      unseenCount: (data['unseenCount'] is num)
          ? (data['unseenCount'] as num).toInt()
          : 0,
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}

class Conversation {
  final String id;
  final List<dynamic> members;
  final List<Message> messages;
  final String ownerID;

  Conversation({
    required this.id,
    required this.members,
    required this.ownerID,
    required this.messages,
  });

  factory Conversation.fromFirestore(DocumentSnapshot snapshot) {
    final Map<String, dynamic> data =
        snapshot.data() as Map<String, dynamic>? ?? {};

    List<Message> parsedMessages = [];
    final messagesRaw = data["messages"] as List<dynamic>?;

    if (messagesRaw != null) {
      parsedMessages = messagesRaw.map((m) {
        final map = m as Map<String, dynamic>? ?? {};
        return Message(
          type: map["type"] == "image" ? MessageType.Image : MessageType.Text,
          content: map["message"] ?? map["text"] ?? "", // Fallback key safety
          timestamp: map["timestamp"] as Timestamp?,
          senderID: map["senderId"] ?? map["senderID"] ?? "",
        );
      }).toList();
    }

    return Conversation(
      id: snapshot.id,
      members: data["members"] ?? [],
      ownerID: data["ownerID"] ?? "",
      messages: parsedMessages,
    );
  }
}
