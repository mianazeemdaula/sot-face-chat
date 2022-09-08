import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_chat/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:http/http.dart' as http;

class ChatView extends StatelessWidget {
  ChatView({Key? key, required this.chatId, required this.userId})
      : super(key: key);
  final String chatId;

  final String userId;

  final formKey = GlobalKey<FormState>();
  final msgTextContoller = TextEditingController();

  final authId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .doc("inbox/$chatId")
                  .collection('msgs')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var msg =
                            Message.fromJson(snapshot.data!.docs[index].data());
                        bool isMineMsg = msg.sendBy == authId;
                        return Row(
                          mainAxisAlignment: isMineMsg
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: isMineMsg
                                    ? Colors.blue.shade100
                                    : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Column(
                                crossAxisAlignment: isMineMsg
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(msg.message),
                                  SizedBox(height: 2),
                                  Text(
                                    msg.createdAt.toString().substring(10, 16),
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: msgTextContoller,
                    validator: (String? msg) {
                      if (msg == null || msg.isEmpty) {
                        return "Please enter message";
                      }
                      return null;
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("inbox")
                      .doc(chatId)
                      .collection("msgs")
                      .doc()
                      .set({
                    "message": msgTextContoller.text,
                    'created_at': FieldValue.serverTimestamp(),
                    'send_by': authId,
                  });
                  await FirebaseFirestore.instance
                      .collection("inbox")
                      .doc(chatId)
                      .update({
                    "last_message": msgTextContoller.text,
                    'last_message_time': FieldValue.serverTimestamp(),
                  });

                  String? token;
                  var user = await FirebaseFirestore.instance
                      .doc("users/$userId")
                      .get();
                  if (user.exists) {
                    token = user.data()!['fcm_token'];
                  }
                  if (token != null) {
                    http.post(
                        Uri.parse('https://api.rnfirebase.io/messaging/send'),
                        headers: {
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: jsonEncode({
                          'token': token,
                          'data': {
                            'screen': 'chat',
                            'user': authId,
                          },
                          'notification': {
                            'title': 'New Message',
                            'body': msgTextContoller.text,
                          },
                        }));
                  }

                  msgTextContoller.clear();
                },
                icon: Icon(Icons.send),
              ),
            ],
          )
        ],
      ),
    );
  }
}
