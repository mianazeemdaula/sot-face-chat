import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_chat/core/app_navigator.dart';
import 'package:face_chat/views/auth/login_view.dart';
import 'package:face_chat/views/home/add_post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              appNavReplace(context, LoginView());
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy(
              'created_at',
              descending: true,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Material(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data!.docs[index].data()['body'],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    snapshot.data!.docs[index]
                                        .data()['likes']
                                        .toString(),
                                  ),
                                  SizedBox(width: 5),
                                  IconButton(
                                    icon: Icon(Icons.thumb_up_alt),
                                    onPressed: () {
                                      snapshot.data!.docs[index].reference
                                          .update({
                                        'likes': FieldValue.increment(1),
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                snapshot.data!.docs[index]
                                    .data()['comments']
                                    .toString(),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          appNavPush(context, AddPostView());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
