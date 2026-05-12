import 'package:chatum/models/conversation_model.dart';
import 'package:chatum/services/db_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecentConversationPage extends StatelessWidget {
  const RecentConversationPage({super.key, this.height, this.width});

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
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
        return Container(
          height: height,
          width: width,
          child: StreamBuilder<List<Conversation>>(
            stream: DbServices.instance.getConversation(auth.user!.uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SpinKitWanderingCubes(
                    color: Colors.blue,
                    size: height! * 0.03,
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

              var data = snapshot.data;
              return ListView.builder(
                itemCount: data!.length,
                itemBuilder: (context, index) {
                  var conversation = data[index];
                  return ListTile(
                    onTap: () {},
                    leading: CircleAvatar(
                      radius: width! * 0.06,
                      backgroundImage: NetworkImage(conversation.photoURL),
                      backgroundColor: Colors.grey[800],
                    ),
                    title: Text(conversation.displayName),
                    subtitle: Text(
                      conversation.lastmessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: _trailingWidget(
                      conversation.timestamp,
                      conversation.unseenCount,
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

  Widget _trailingWidget(Timestamp _lastmessageTimestamp, int unseenCount) {
    var _timeDiffrence = _lastmessageTimestamp.toDate().difference(
      DateTime.now(),
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          timeago.format(_lastmessageTimestamp.toDate()),
          style: TextStyle(fontSize: height! * 0.016, color: Colors.white38),
        ),
        Container(
          height: height! * 0.011,
          width: width! * 0.024,
          decoration: BoxDecoration(
            color: unseenCount > 0 ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(500),
          ),
        ),
      ],
    );
  }
}
