import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_chat/core/app_navigator.dart';
import 'package:face_chat/views/inbox/chat_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InboxView extends StatelessWidget {
  InboxView({Key? key}) : super(key: key);
  final authId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('inbox')
          .where('uids', arrayContains: authId)
          .orderBy('last_message_time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              String userId = snapshot.data!.docs[index].data()['uids'][0];
              if (userId == authId) {
                userId = snapshot.data!.docs[index].data()['uids'][1];
              }
              // return Text(userId);
              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance.doc("users/$userId").get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.hasData) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          userSnapshot.data!.data()!['image'],
                        ),
                      ),
                      title: Text(userSnapshot.data!.data()!['name']),
                      subtitle: Text(
                          snapshot.data!.docs[index].data()['last_message']),
                      onTap: () {
                        appNavPush(
                            context,
                            ChatView(
                              chatId: snapshot.data!.docs[index].id,
                              userId: userId,
                            ));
                      },
                    );
                  } else if (userSnapshot.hasError) {
                    return const Center(
                      child: Text("Error"),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
