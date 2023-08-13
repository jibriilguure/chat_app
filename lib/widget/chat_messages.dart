import 'package:chat_app/widget/chat_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("chat")
            .orderBy("createAt", descending: true)
            .snapshots(),
        builder: (context, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Wax Massage ah ma jiraan!"),
            );
          }
          if (chatSnapshot.hasError) {
            return const Center(
              child: Text("khalad baa jira!"),
            );
          }
          final messages = chatSnapshot.data!.docs;
          return ListView.builder(
              padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final chatMessage = messages[index].data();
                final nextChatMessage = index + 1 < messages.length
                    ? messages[index + 1].data()
                    : null;
                final currentUserId = chatMessage['userId'];

                final nextUserId =
                    nextChatMessage != null ? nextChatMessage['userId'] : null;

                final nextUserIsSame = nextUserId == currentUserId;

                if (nextUserIsSame) {
                  return MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentUserId,
                  );
                } else {
                  return MessageBubble.first(
                    userImage: chatMessage['userImage'],
                    username: chatMessage['username'],
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentUserId,
                  );
                }
              });
        });
  }
}
