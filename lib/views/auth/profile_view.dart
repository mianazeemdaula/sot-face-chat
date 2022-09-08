import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_chat/core/app_navigator.dart';
import 'package:face_chat/views/inbox/chat_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key, required this.user, required this.uid})
      : super(key: key);
  final Map<String, dynamic> user;
  final String uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user['name']),
      ),
      body: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: CachedNetworkImageProvider(user['image']),
          ),
          ElevatedButton(
            onPressed: () async {
              String authId = FirebaseAuth.instance.currentUser!.uid;
              String chatId = "";
              if (authId.hashCode >= uid.hashCode) {
                chatId = "$authId-$uid";
              } else {
                chatId = "$uid-$authId";
              }
              var doc = await FirebaseFirestore.instance
                  .collection('inbox')
                  .doc(chatId)
                  .get();
              if (!doc.exists) {
                await doc.reference.set(
                  {
                    'uids': FieldValue.arrayUnion([
                      uid,
                      authId,
                    ]),
                    'last_message': '',
                    'last_message_time': FieldValue.serverTimestamp(),
                  },
                );
              }
              appNavPush(
                  context,
                  ChatView(
                    chatId: chatId,
                    userId: uid,
                  ));
            },
            child: Text('Chat'),
          ),
        ],
      ),
    );
  }
}
