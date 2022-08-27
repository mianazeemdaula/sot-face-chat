import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<String> appUploadImage(File image) async {
  String ext = image.path.split(".").last;
  String path =
      "${DateTime.now().microsecondsSinceEpoch}_${FirebaseAuth.instance.currentUser!.uid}.$ext";
  Reference ref = FirebaseStorage.instance.ref().child(path);
  UploadTask task = ref.putFile(image);
  await task.whenComplete(() => null);
  String link = await ref.getDownloadURL();
  return link;
}
