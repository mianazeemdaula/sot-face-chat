import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_chat/core/snack_bar.dart';
import 'package:face_chat/models/post.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPostView extends StatefulWidget {
  AddPostView({Key? key}) : super(key: key);

  @override
  State<AddPostView> createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  final formKey = GlobalKey<FormState>();

  final bodyController = TextEditingController();

  File? image;

  Future pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
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
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                ),
                child: GestureDetector(
                  onTap: () {
                    pickImage();
                  },
                  child: image == null
                      ? Center(
                          child: Text('Please Select Image'),
                        )
                      : Image.file(image!),
                ),
              ),
              SizedBox(height: 10),
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
                    var storage = FirebaseStorage.instance;
                    String ext = image!.path.split('.').last;
                    String path =
                        "${DateTime.now().microsecondsSinceEpoch}.$ext";
                    Reference ref = storage.ref().child(path);
                    UploadTask task = ref.putFile(image!);
                    await task.whenComplete(() => null);
                    String downoadPath = await ref.getDownloadURL();
                    Post post = Post.create(
                      body: bodyController.text,
                      image: downoadPath,
                    );
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
