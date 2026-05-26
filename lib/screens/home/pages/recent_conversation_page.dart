import '../../../models/conversation_model.dart';
import '../../../services/db_services.dart';
import '../../../services/chat_services.dart'; // Make sure this is imported
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timer_builder/timer_builder.dart';
import '../../../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/navigation_services.dart';
import '../../conversation/conversation_page.dart';

class RecentConversationPage extends StatefulWidget {
  const RecentConversationPage({super.key, this.height, this.width});

  final double? height;
  final double? width;

  @override
  State<RecentConversationPage> createState() => _RecentConversationPageState();
}

class _RecentConversationPageState extends State<RecentConversationPage> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationPageUI(),
      ),
    );
  }

  Widget _conversationPageUI() {
    return Builder(
      builder: (BuildContext context) {
        var auth = Provider.of<AuthProvider>(context);
        return SizedBox(
          height: widget.height,
          width: widget.width,
          child: StreamBuilder<List<ConversationSnippet>>(
            stream: DbServices.instance.getUserConversation(auth.user!.uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SpinKitWanderingCubes(
                    color: Colors.blue,
                    size: widget.height! * 0.03,
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "No conversations yet",
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              var data = snapshot.data!;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  var snippet = data[index];
                  return ListTile(
                    onTap: () async {
                      // Automatically reset unseen count on tap
                      await ChatServices.resetUnseenCount(
                        auth.user!.uid,
                        snippet.uid,
                      );
                      print(
                        "Snippet data: ${snippet.uid} ${snippet.photoURL} ${snippet.displayName}, ${snippet.lastmessage}, ${snippet.timestamp.toDate()}",
                      );

                      // Hardcoded placeholder conversation lookup fallback
                      // Replace logic below with a shared deterministic ID if your matching matrix requires it
                      String determinedRoomId =
                          snippet.uid.hashCode <= auth.user!.uid.hashCode
                          ? "${snippet.uid}_${auth.user!.uid}"
                          : "${auth.user!.uid}_${snippet.uid}";

                      NavigationServices.instance.navigateToRoute(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return ConversationPage(
                              conversationId: determinedRoomId,
                              receiverId: snippet.uid,
                              receiverName: snippet.displayName,
                              receiverImage: snippet.photoURL,
                            );
                          },
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      radius: widget.width! * 0.06,
                      backgroundImage: snippet.photoURL.trim().isNotEmpty
                          ? NetworkImage(snippet.photoURL)
                          : null,
                      backgroundColor: Colors.grey[800],
                      child: snippet.photoURL.trim().isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      snippet.displayName,
                      style: const TextStyle(color: Colors.white),
                    ),

                    subtitle: Text(
                      snippet.lastmessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: _trailingWidget(
                      snippet.timestamp,
                      snippet.unseenCount,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _trailingWidget(Timestamp lastmessageTimestamp, int unseenCount) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        TimerBuilder.periodic(
          const Duration(minutes: 1),
          builder: (context) {
            return Text(
              timeago.format(lastmessageTimestamp.toDate()),
              style: TextStyle(
                fontSize: widget.height! * 0.016,
                color: Colors.white38,
              ),
            );
          },
        ),
        Container(
          height: widget.height! * 0.015,
          width: widget.width! * 0.03,
          decoration: BoxDecoration(
            color: unseenCount > 0 ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(500),
          ),
          child: unseenCount > 0
              ? Center(
                  child: Text(
                    "$unseenCount",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}
