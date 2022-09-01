import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_chat/core/app_navigator.dart';
import 'package:face_chat/models/post.dart';
import 'package:face_chat/views/auth/login_view.dart';
import 'package:face_chat/views/home/add_post.dart';
import 'package:face_chat/views/home/edit_post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeView extends StatefulWidget {
  HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  int pageIndex = 0;

  LatLng myPosition = LatLng(30.673115, 73.649839);

  @override
  void initState() {
    super.initState();
    getPermissionAndLocation();
  }

  Future getPermissionAndLocation() async {
    await Geolocator.requestPermission();

    Position p = await Geolocator.getCurrentPosition();
    Geolocator.getPositionStream().listen((event) {
      setState(() {
        myPosition = LatLng(event.latitude, event.longitude);
      });
    });
  }

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
      body: IndexedStack(
        index: pageIndex,
        children: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                    return FutureBuilder<
                        DocumentSnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance
                          .doc(
                              "users/${snapshot.data!.docs[index].data()['user_id']}")
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: CachedNetworkImage(
                                                imageUrl: userSnapshot.data!
                                                    .data()!['image'],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(userSnapshot.data!
                                              .data()!['name']),
                                        ],
                                      ),
                                      if (post.userId == uid)
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
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          const Text(
                                                            "Are you sure to delete this post?",
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    const Text(
                                                                        'No'),
                                                              ),
                                                              TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'posts')
                                                                      .doc(post
                                                                          .id)
                                                                      .delete();
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    Text('Yes'),
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
                                  const SizedBox(height: 5),
                                  if (post.image != null)
                                    CachedNetworkImage(
                                      imageUrl: post.image!,
                                      height: 250,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  const SizedBox(height: 5),
                                  Text(
                                    post.body,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            post.likes.length.toString(),
                                          ),
                                          const SizedBox(width: 5),
                                          IconButton(
                                            icon: Icon(
                                              Icons.thumb_up_alt,
                                              color: post.isLiked
                                                  ? Colors.blue
                                                  : Colors.black,
                                            ),
                                            onPressed: () {
                                              snapshot
                                                  .data!.docs[index].reference
                                                  .update({
                                                'likes': post.isLiked
                                                    ? FieldValue.arrayRemove(
                                                        [uid])
                                                    : FieldValue.arrayUnion(
                                                        [uid]),
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showComments(context, post);
                                        },
                                        child: Text(
                                          "${post.comments} comments",
                                        ),
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
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(30.672710, 73.649142),
              zoom: 16,
            ),
            markers: {
              Marker(
                  markerId: MarkerId('sot'),
                  position: myPosition,
                  onTap: () {
                    print("OnMarker Tap");
                  },
                  infoWindow: InfoWindow(
                    title: "This is the infor of the driver one",
                  ))
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          appNavPush(context, AddPostView());
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: pageIndex == 0
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.startFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: (int newIndex) {
          setState(() {
            pageIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map")
        ],
      ),
    );
  }

  Future showComments(BuildContext context, Post post) async {
    final commentFormKey = GlobalKey<FormState>();
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Form(
            key: commentFormKey,
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('comments')
                        .where('post_id', isEqualTo: post.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(),
                              title: Text('username'),
                              subtitle: Text(
                                snapshot.data!.docs[index].data()['comment'],
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
                ),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: commentController,
                          validator: (String? v) {
                            if (v == null || v.isEmpty) {
                              return "Please enter comment";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 5),
                      IconButton(
                        onPressed: () async {
                          if (commentFormKey.currentState!.validate()) {
                            await FirebaseFirestore.instance
                                .collection("comments")
                                .doc()
                                .set({
                              'post_id': post.id,
                              'user_id': uid,
                              'comment': commentController.text,
                              'created_at': FieldValue.serverTimestamp(),
                            });
                            await FirebaseFirestore.instance
                                .collection("posts")
                                .doc(post.id)
                                .update(
                              {'comments': FieldValue.increment(1)},
                            );
                            commentController.clear();
                          }
                        },
                        icon: Icon(Icons.send),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
