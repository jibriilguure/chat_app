import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Message extends StatefulWidget {
  const Message({super.key});

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  var _messageController = TextEditingController();

  void _dir() async {
    final enterdMessage = _messageController.text;

    if (enterdMessage.trim().isEmpty) {
      return;
    }
    // //massax si aad u dirto massage ka xiga
    _messageController.clear();
    FocusScope.of(context).unfocus();
//firebase auth
    final thisUser = FirebaseAuth.instance.currentUser!;
    //fireabse sotrage
    final userData = await FirebaseFirestore.instance
        .collection('theusers')
        .doc(thisUser.uid)
        .get();

    //to firebase
    FirebaseFirestore.instance.collection('chat').add({
      'text': enterdMessage,
      'createAt': Timestamp.now(),
      'userId': thisUser.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Dir Qoralka..'),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
              color: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.send),
              onPressed: _dir)
        ],
      ),
    );
  }
}
