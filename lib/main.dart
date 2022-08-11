import 'package:face_chat/views/auth/login_view.dart';
import 'package:flutter/material.dart';

main() {
  runApp(FaceChat());
}

class FaceChat extends StatelessWidget {
  const FaceChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginView(),
    );
  }
}
