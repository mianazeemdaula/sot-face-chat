import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_chat/core/snack_bar.dart';
import 'package:face_chat/models/post.dart';
import 'package:flutter/material.dart';

class AddPostView extends StatelessWidget {
  AddPostView({Key? key}) : super(key: key);
  final formKey = GlobalKey<FormState>();
  final bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: bodyController,
                decoration: const InputDecoration(
                  labelText: "Whats in your mind",
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 5,
                validator: (String? v) {
                  if (v == null || v.isEmpty) {
                    return "Please enter somting";
                  } else if (v.length < 5) {
                    return "Please enter at least 5 charaters";
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    Post post = Post.create(body: bodyController.text);
                    await FirebaseFirestore.instance
                        .collection('posts')
                        .doc()
                        .set(post.toJson());
                    Navigator.pop(context);
                    appSnackBar(context, "Your post has been created.");
                  }
                },
                child: const Text('Save Post'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
