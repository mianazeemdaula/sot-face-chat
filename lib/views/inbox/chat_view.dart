import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChatView extends StatelessWidget {
  ChatView({Key? key, required this.chatId}) : super(key: key);
  final String chatId;

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
                  return ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Text(snapshot.data!.docs[index].data()['message']);
                    },
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
