import 'dart:convert';
import 'package:face_chat/core/app_navigator.dart';
import 'package:face_chat/core/const.dart';
import 'package:face_chat/core/snack_bar.dart';
import 'package:face_chat/views/api/comment_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RestApiTab extends StatefulWidget {
  const RestApiTab({Key? key}) : super(key: key);

  @override
  State<RestApiTab> createState() => _RestApiTabState();
}

class _RestApiTabState extends State<RestApiTab> {
  List<Map<String, dynamic>> posts = [];

  Future<bool> fetchPosts() async {
    http.Response res = await http.get(Uri.parse("${Const.ApiURL}/posts"));
    if (res.statusCode == 200) {
      List _data = jsonDecode(res.body);
      setState(() {
        posts = _data.cast<Map<String, dynamic>>();
      });
      return true;
    } else {
      throw Future.error(res.statusCode);
    }
  }

  @override
  void initState() {
    myFuture = fetchPosts();
    super.initState();
  }

  late Future<bool> myFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: myFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return RefreshIndicator(
            onRefresh: () async {
              await fetchPosts();
            },
            child: ListView.separated(
              itemCount: posts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return Material(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${posts[index]['title']} ${posts[index]['id']}",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 5),
                        Text(posts[index]['body']),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                try {
                                  int id = posts[index]['id'];
                                  http.Response res = await http.delete(
                                      Uri.parse("${Const.ApiURL}/posts/$id"));
                                  if (res.statusCode == 200) {
                                    posts.removeWhere((e) => e['id'] == id);
                                    setState(() {});
                                  }
                                } catch (e) {
                                  appSnackBar(context, e.toString());
                                }
                              },
                              icon: const Icon(Icons.delete),
                            ),
                            IconButton(
                              onPressed: () async {
                                try {
                                  int id = posts[index]['id'];
                                  appNavPush(context, CommentsView(postId: id));
                                } catch (e) {
                                  appSnackBar(context, e.toString());
                                }
                              },
                              icon: const Icon(Icons.comment),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
