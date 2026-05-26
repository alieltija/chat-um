import 'dart:async';
import 'package:chatum/models/conversation_model.dart';
import 'package:chatum/models/message_model.dart';
import 'package:chatum/providers/auth_provider.dart';
import 'package:chatum/services/chat_services.dart';
import 'package:chatum/services/db_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

class ConversationPage extends StatefulWidget {
  final String conversationId;
  final String receiverId;
  final String receiverImage;
  final String receiverName;

  const ConversationPage({
    super.key,
    required this.conversationId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
  });

  @override
  State<StatefulWidget> createState() {
    return _ConversationPageState();
  }
}

class _ConversationPageState extends State<ConversationPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _listViewController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  late AuthProvider _auth;

  String _messageText = "";

  @override
  void dispose() {
    _listViewController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(18, 18, 18, 1.0),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(31, 31, 31, 1.0),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              radius: _deviceWidth * 0.045,
              backgroundImage: widget.receiverImage.trim().isNotEmpty
                  ? NetworkImage(widget.receiverImage)
                  : null,
              backgroundColor: Colors.grey[800],
              child: widget.receiverImage.trim().isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              widget.receiverName,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationPageUI(),
      ),
    );
  }

  Widget _conversationPageUI() {
    return Builder(
      builder: (BuildContext context) {
        _auth = Provider.of<AuthProvider>(context);
        return Column(
          children: <Widget>[
            Expanded(child: _messageListView()),
            _messageField(context),
          ],
        );
      },
    );
  }

  Widget _messageListView() {
    return StreamBuilder<List<Message>>(
      stream: DbServices.instance.getCollectionMessages(widget.conversationId),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // Auto-scroll to the bottom safely using frame scheduling loops
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              if (_listViewController.hasClients) {
                _listViewController.jumpTo(
                  _listViewController.position.maxScrollExtent,
                );
              }
            } catch (e) {
              print("Scroll controller handled safety check: $e");
            }
          });
        }

        if (snapshot.hasData) {
          List<Message> messagesList = snapshot.data!;
          if (messagesList.isNotEmpty) {
            return ListView.builder(
              controller: _listViewController,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              itemCount: messagesList.length,
              itemBuilder: (BuildContext context, int index) {
                var message = messagesList[index];
                bool isOwnMessage = message.senderID == _auth.user!.uid;
                return _messageListViewChild(isOwnMessage, message);
              },
            );
          } else {
            return const Center(
              child: Text(
                "Let's start a conversation!",
                style: TextStyle(color: Colors.white54),
              ),
            );
          }
        } else {
          return const Center(
            child: SpinKitWanderingCubes(color: Colors.blue, size: 50.0),
          );
        }
      },
    );
  }

  Widget _messageListViewChild(bool isOwnMessage, Message message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isOwnMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          if (!isOwnMessage) _userImageWidget(),
          SizedBox(width: _deviceWidth * 0.02),
          message.type == MessageType.Text
              ? _textMessageBubble(
                  isOwnMessage,
                  message.content!,
                  message.timestamp ?? Timestamp.now(),
                )
              : _imageMessageBubble(
                  isOwnMessage,
                  message.content!,
                  message.timestamp ?? Timestamp.now(),
                ),
        ],
      ),
    );
  }

  Widget _userImageWidget() {
    double imageRadius = _deviceWidth * 0.09;
    return Container(
      height: imageRadius,
      width: imageRadius,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(500),
        image: widget.receiverImage.trim().isNotEmpty
            ? DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(widget.receiverImage),
              )
            : null,
      ),
      child: widget.receiverImage.trim().isEmpty
          ? const Icon(Icons.person, color: Colors.white)
          : null,
    );
  }

  Widget _textMessageBubble(
    bool isOwnMessage,
    String message,
    Timestamp timestamp,
  ) {
    List<Color> colorScheme = isOwnMessage
        ? [Colors.blue, const Color.fromRGBO(42, 117, 188, 1)]
        : [
            const Color.fromRGBO(69, 69, 69, 1),
            const Color.fromRGBO(43, 43, 43, 1),
          ];

    return Container(
      width: _deviceWidth * 0.70,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: colorScheme,
          stops: const [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              timeago.format(timestamp.toDate()),
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageMessageBubble(
    bool isOwnMessage,
    String imageURL,
    Timestamp timestamp,
  ) {
    List<Color> colorScheme = isOwnMessage
        ? [Colors.blue, const Color.fromRGBO(42, 117, 188, 1)]
        : [
            const Color.fromRGBO(69, 69, 69, 1),
            const Color.fromRGBO(43, 43, 43, 1),
          ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: colorScheme,
          stops: const [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: _deviceHeight * 0.30,
            width: _deviceWidth * 0.55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(imageURL),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            timeago.format(timestamp.toDate()),
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _messageField(BuildContext context) {
    return Container(
      height: _deviceHeight * 0.08,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(43, 43, 43, 1),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: _deviceWidth * 0.04,
        vertical: _deviceHeight * 0.02,
      ),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[_messageTextField(), _sendMessageButton(context)],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.65,
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        controller: _textController,
        validator: (input) {
          if (input == null || input.trim().isEmpty) {
            return "Please enter a message";
          }
          return null;
        },
        onChanged: (input) {
          _messageText = input;
        },
        cursorColor: Colors.white,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Type a message",
          hintStyle: TextStyle(color: Colors.white30),
        ),
        autocorrect: false,
      ),
    );
  }

  Widget _sendMessageButton(BuildContext context) {
    return SizedBox(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      child: IconButton(
        icon: const Icon(Icons.send, color: Colors.blue),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();

            try {
              final String cleanMessage = _textController.text.trim();

              await ChatServices.sendMessage(
                conversationId: widget.conversationId,
                senderId: _auth.user!.uid,
                senderName: _auth.currentUserModel?.name ?? "User",
                senderImage: _auth.currentUserModel?.image ?? "",
                recieverId: widget.receiverId,
                receiverName: widget.receiverName,
                receiverImage: widget.receiverImage,
                messageText: cleanMessage,
                messageType: "text",
              );

              // Clear the UI fields completely on success
              _textController.clear();
              _messageText = "";
              _formKey.currentState!.reset();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to send message: $e")),
                );
              }
            }
          }
        },
      ),
    );
  }
}
