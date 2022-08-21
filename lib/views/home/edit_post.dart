import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_chat/core/snack_bar.dart';
import 'package:face_chat/models/post.dart';
import 'package:flutter/material.dart';

class EditPostView extends StatelessWidget {
  EditPostView({Key? key, required this.post}) : super(key: key);
  final Post post;
  final formKey = GlobalKey<FormState>();
  late TextEditingController bodyController;

  @override
  Widget build(BuildContext context) {
    bodyController = TextEditingController(text: post.body);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
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
                    await FirebaseFirestore.instance
                        .collection('posts')
                        .doc(post.id)
                        .update({
                      'body': bodyController.text,
                      'updated_at': FieldValue.serverTimestamp(),
                    });
                    Navigator.pop(context);
                    appSnackBar(context, "Your post has been updated.");
                  }
                },
                child: const Text('Update Post'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
