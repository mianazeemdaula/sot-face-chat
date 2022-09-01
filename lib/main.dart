import 'dart:io';

import 'package:face_chat/views/splash/splash_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ? for null value (means no value at the time of the creation/making);
// make sure value is not null
// manullay define the null safty check !

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (Platform.isAndroid) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
  runApp(const FaceChat());
}

class FaceChat extends StatelessWidget {
  const FaceChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          fillColor: Colors.blue.shade100,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 18,
          ),
        ),
      ),
      home: const SplashView(),
    );
  }
}
