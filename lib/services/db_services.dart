import 'package:chatum/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contact_model.dart';
import '../models/conversation_model.dart';

class DbServices {
  static final DbServices instance = DbServices._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String userCollection = "Users";
  String conversations = "Conversations";

  DbServices._();

  Future<void> storeUserData(
    String uid,
    String displayName,
    String email,
    String photoURL,
  ) async {
    try {
      await _db.collection(userCollection).doc(uid).set({
        "displayName": displayName,
        "searchName": displayName.toLowerCase(),
        "email": email,
        "photoURL": photoURL,
        "lastSeen": DateTime.now().toUtc(),
      });
    } catch (e) {
      print("Error storing user data: $e");
    }
  }

  Stream<Contact> getUserData(String uid) {
    return _db
        .collection(userCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) => Contact.fromFirestore(snapshot));
  }

  Future<DocumentSnapshot> getUserDataFuture(String uid) async {
    return await _db.collection(userCollection).doc(uid).get();
  }

  // FIX: This dashboard layout serves snippets, NOT full conversations
  Stream<List<ConversationSnippet>> getUserConversation(String uid) {
    return _db
        .collection(userCollection)
        .doc(uid)
        .collection(conversations)
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ConversationSnippet.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> updateLastSeen(String uid) async {
    try {
      await _db.collection(userCollection).doc(uid).update({
        "lastSeen": DateTime.now().toUtc(),
      });
    } catch (e) {
      print("Error updating last seen: $e");
    }
  }

  Stream<List<Contact>> getUsers(String searchName, String currentUserId) {
    if (searchName.trim().isEmpty) {
      return Stream.value([]);
    }

    String lowerCaseQuery = searchName.toLowerCase();

    return _db
        .collection(userCollection)
        .where("searchName", isGreaterThanOrEqualTo: lowerCaseQuery)
        .where("searchName", isLessThanOrEqualTo: '$lowerCaseQuery\uf8ff')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Contact.fromFirestore(doc))
              .where((contact) => contact.uid != currentUserId)
              .toList();
        });
  }

  Stream<Conversation> getConversation(String conversationID) {
    return _db
        .collection(conversations)
        .doc(conversationID)
        .snapshots()
        .map((doc) => Conversation.fromFirestore(doc));
  }

  Stream<List<Message>> getCollectionMessages(String conversationID) {
    return _db
        .collection(conversations)
        .doc(conversationID)
        .collection("messages")
        .orderBy(
          "timestamp",
          descending: false,
        ) // Older messages top, newer bottom
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final map = doc.data();
            return Message(
              type: map["type"] == "image"
                  ? MessageType.Image
                  : MessageType.Text,
              content: map["text"] ?? map["message"] ?? "",
              timestamp: map["timestamp"] as Timestamp?,
              senderID: map["senderId"] ?? map["senderID"] ?? "",
            );
          }).toList();
        });
  }
}
