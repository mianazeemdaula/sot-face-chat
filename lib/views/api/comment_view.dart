import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:face_chat/core/const.dart';
import 'package:face_chat/models/comment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class CommentsView extends StatelessWidget {
  const CommentsView({Key? key, required this.postId}) : super(key: key);
  final int postId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<http.Response>(
        future: http.get(Uri.parse("${Const.ApiURL}/posts/$postId/comments")),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Comment> comments = commentFromJson(snapshot.data!.body);
            return ListView.separated(
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(comments[index].name[0].toUpperCase()),
                  ),
                  title: Text(comments[index].email),
                  subtitle: Text(comments[index].body),
                );
              },
              separatorBuilder: (context, index) {
                return index % 3 == 0
                    ? GestureDetector(
                        onTap: () {
                          Uri path = Uri.parse(
                              "whatsapp://send?phone=03484920035&text=hello");
                          launchUrl(path);
                        },
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://via.placeholder.com/500x90.png?text=Google%20Ad",
                        ),
                      )
                    : Divider();
              },
              itemCount: comments.length,
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
