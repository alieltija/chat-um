import 'dart:async';

import 'package:chatum/models/contact_model.dart';
import 'package:chatum/screens/conversation/conversation_page.dart';
import 'package:chatum/services/db_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

// ignore: must_be_immutable
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.height, this.width});
  final double? height;
  final double? width;

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = "";
  AuthProvider? auth;
  Timer? refreshTimer;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        counter++;
      });
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: AuthProvider.instance,
      child: _searchPageUI(),
    );
  }

  Widget _searchPageUI() {
    return Builder(
      builder: (BuildContext context) {
        auth = Provider.of<AuthProvider>(context);
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[_searchTextField(), _listViewUsers()],
        );
      },
    );
  }

  Widget _searchTextField() {
    return Container(
      height: widget.height! * 0.08,
      width: widget.width!,
      padding: EdgeInsets.symmetric(vertical: widget.height! * 0.02),
      child: TextField(
        autocorrect: false,
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white,
            size: widget.height! * 0.024,
          ),
          labelText: "Search",
          labelStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _listViewUsers() {
    return StreamBuilder<List<Contact>>(
      stream: searchQuery.trim().isEmpty
          ? FirebaseFirestore.instance
                .collection("Users")
                .snapshots()
                .map(
                  (snap) => snap.docs
                      .map((doc) => Contact.fromFirestore(doc))
                      .where((u) => u.uid != auth!.user!.uid)
                      .toList(),
                )
          : DbServices.instance.getUsers(searchQuery, auth!.user!.uid),

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Expanded(
            child: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Expanded(child: Center(child: Text("No user found")));
        }

        var users = snapshot.data!;

        return Expanded(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              var currentTime = DateTime.now();
              var lastSeen = !user.lastSeen.toDate().isBefore(
                currentTime.subtract(const Duration(minutes: 2)),
              );
              return ListTile(
                // ---- UPDATE ONTAP HERE ----
                onTap: () {
                  // 1. Generate unique chat room ID based on both user IDs sorted alphabetically
                  List<String> ids = [auth!.user!.uid, user.uid];
                  ids.sort();
                  String conversationId = ids.join("_");

                  // 2. Navigate to ConversationPage via your route string or directly
                  // If you pass arguments through dynamic settings routing, match your names:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConversationPage(
                        conversationId: conversationId,
                        receiverId: user.uid,
                        receiverName: user.displayName,
                        receiverImage: user.photoURL,
                      ),
                    ),
                  );
                },
                leading: CircleAvatar(
                  radius: widget.width! * 0.06,
                  backgroundImage: user.photoURL.trim().isNotEmpty
                      ? NetworkImage(user.photoURL)
                      : null,
                  backgroundColor: Colors.grey[800],
                  child: user.photoURL.trim().isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                title: Text(user.displayName),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    lastSeen
                        ? Text(
                            "Active now",
                            style: TextStyle(
                              fontSize: widget.height! * 0.016,
                              color: Colors.white38,
                            ),
                          )
                        : Text(
                            "Last Seen",
                            style: TextStyle(
                              fontSize: widget.height! * 0.016,
                              color: Colors.white38,
                            ),
                          ),
                    lastSeen
                        ? Container(
                            height: widget.width! * 0.02,
                            width: widget.width! * 0.02,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          )
                        : Text(
                            timeago.format(user.lastSeen.toDate()),
                            style: TextStyle(
                              fontSize: widget.height! * 0.015,
                              color: Colors.white38,
                            ),
                          ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
