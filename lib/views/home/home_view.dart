import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_chat/core/app_navigator.dart';
import 'package:face_chat/models/post.dart';
import 'package:face_chat/views/auth/login_view.dart';
import 'package:face_chat/views/home/add_post.dart';
import 'package:face_chat/views/home/edit_post.dart';
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
              appNavReplace(context, const LoginView());
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
                Post post = Post.fromJson(snapshot.data!.docs[index]);
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Material(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(),
                              SizedBox(width: 5),
                              Text('User Name'),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 0,
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem(
                                    value: 1,
                                    child: Text('Delete'),
                                  ),
                                ],
                                onSelected: (int v) {
                                  if (v == 0) {
                                    appNavPush(
                                      context,
                                      EditPostView(
                                        post: post,
                                      ),
                                    );
                                  } else if (v == 1) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Are you sure to delete this post?",
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('No'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('posts')
                                                            .doc(post.id)
                                                            .delete();
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('Yes'),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          if (post.image != null) Image.network(post.image!),
                          Text(
                            post.body,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    post.likes.toString(),
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
                                "${post.comments} comments",
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
