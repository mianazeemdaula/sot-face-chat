import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_chat/core/functions.dart';
import 'package:face_chat/core/snack_bar.dart';
import 'package:face_chat/models/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPostView extends StatefulWidget {
  const AddPostView({Key? key}) : super(key: key);

  @override
  State<AddPostView> createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  final formKey = GlobalKey<FormState>();

  final bodyController = TextEditingController();

  File? image;
  bool isBusy = false;

  void selectImage(ImageSource source) async {
    var picker = ImagePicker();
    XFile? pickedImage = await picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
    }
  }

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
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                ),
                child: image == null
                    ? const Center(
                        child: Text('Select Image'),
                      )
                    : Image.file(image!),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      selectImage(ImageSource.gallery);
                    },
                    icon: Icon(Icons.image),
                  ),
                  IconButton(
                    onPressed: () {
                      selectImage(ImageSource.camera);
                    },
                    icon: Icon(Icons.camera),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
                    if (image == null) {
                      appSnackBar(context, "Please select image");
                      return;
                    }
                    setState(() {
                      isBusy = true;
                    });
                    String link = await appUploadImage(image!);

                    Post post = Post.create(
                      body: bodyController.text,
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      image: link,
                    );
                    await FirebaseFirestore.instance
                        .collection('posts')
                        .doc()
                        .set(post.toJson());
                    setState(() {
                      isBusy = false;
                    });
                    Navigator.pop(context);
                    appSnackBar(context, "Your post has been created.");
                  }
                },
                child: const Text('Save Post'),
              ),
              if (isBusy) const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
