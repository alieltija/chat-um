import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { Text, Image }

class Message {
  String? senderID;
  String? content;
  Timestamp? timestamp;
  MessageType? type;

  Message({this.senderID, this.content, this.timestamp, this.type});
}
