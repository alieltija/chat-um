import 'package:cloud_firestore/cloud_firestore.dart';

class ChatServices {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderImage,
    required String senderName,
    required String recieverId,
    required String receiverName,
    required String receiverImage,
    required String messageText,
    required String messageType,
  }) async {
    final WriteBatch batch = _db.batch();
    final Timestamp now = Timestamp.now();

    // Add message to main message collection

    final DocumentReference messageReference = _db
        .collection("Conversations")
        .doc(conversationId)
        .collection("messages")
        .doc();

    batch.set(messageReference, {
      "senderId": senderId,
      "text": messageText,
      "type": messageType,
      "timestamp": now,
    });

    // Update the main message collection

    final DocumentReference conversationReference = _db
        .collection("Conversations")
        .doc(conversationId);

    batch.update(conversationReference, {
      "lastmessage": {
        "text": messageText,
        "senderId": senderId,
        "timestamp": now,
      },
      "updatedAt": now,
    });

    // Update sender inbox view

    final DocumentReference senderInboxRef = _db
        .collection("Users")
        .doc(senderId)
        .collection("Conversations")
        .doc(recieverId);

    batch.set(senderInboxRef, {
      "displayName": receiverName, // Store who I'm talking to
      "photoURL": receiverImage,
      "lastmessage": messageText,
      "timestamp": now,
      "type": messageType,
    }, SetOptions(merge: true));

    // Update receiver inbox view (Store sender's info here)

    final DocumentReference reciverInboxRef = _db
        .collection("Users")
        .doc(recieverId)
        .collection("Conversations")
        .doc(senderId);

    batch.set(reciverInboxRef, {
      "displayName": senderName, // Store who is talking to me
      "photoURL": senderImage,
      "lastmessage": messageText,
      "timestamp": now,
      "type": messageType,
      "unseenCount": FieldValue.increment(1),
    }, SetOptions(merge: true));
    try {
      await batch.commit();
    } catch (e) {
      print("Error sending message: $e");
      rethrow;
    }
  }

  // Reset the unseen count when the user open chat

  static Future<void> resetUnseenCount(String myId, String otherId) async {
    try {
      await _db
          .collection('Users')
          .doc(myId)
          .collection('Conversations')
          .doc(otherId)
          .update({'unseenCount': 0});
    } catch (e) {
      print("Could not rest count: $e");
    }
  }
}
