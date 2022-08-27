import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_chat/core/app_navigator.dart';
import 'package:face_chat/core/functions.dart';
import 'package:face_chat/core/snack_bar.dart';
import 'package:face_chat/views/home/home_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationView extends StatefulWidget {
  const RegistrationView({Key? key}) : super(key: key);

  @override
  State<RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  bool isBusy = false;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();

  File? image;

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
        title: Text('Registation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: formKey,
          child: Stack(
            children: [
              Column(
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
                    controller: nameController,
                    decoration: const InputDecoration(
                      label: Text('Name'),
                    ),
                    validator: (String? v) {
                      if (v == null || v.isEmpty) {
                        return "Please enter Name";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      label: Text('Address'),
                    ),
                    validator: (String? v) {
                      if (v == null || v.isEmpty) {
                        return "Please enter address";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        if (formKey.currentState!.validate()) {
                          if (image == null) {
                            appSnackBar(context, "Please select profile image");
                            return;
                          }
                          setState(() {
                            isBusy = true;
                          });
                          String path = await appUploadImage(image!);
                          String userId =
                              FirebaseAuth.instance.currentUser!.uid;
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .set({
                            'addresss': addressController.text,
                            'name': nameController.text,
                            'image': path,
                          });
                          setState(() {
                            isBusy = false;
                          });
                          appNavPopAndPush(context, HomeView());
                        }
                      } catch (e) {
                        appSnackBar(context, e.toString());
                      }
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
              Visibility(
                visible: isBusy,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                    ),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
