import 'package:face_chat/core/app_navigator.dart';
import 'package:face_chat/core/snack_bar.dart';
import 'package:face_chat/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String email = "abc@gmail.com";
  String password = "123456";

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isBusy = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Column(
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    label: Text('Email'),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text('Password'),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (emailController.text == email &&
                        passwordController.text == password) {
                      setState(() {
                        isBusy = true;
                      });
                      await Future.delayed(Duration(seconds: 2));
                      setState(() {
                        isBusy = false;
                      });
                      appNavPush(context, HomeView());
                    } else {
                      appSnackBar(context, "Email or password not mached");
                    }
                  },
                  child: const Text('Login'),
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
    );
  }
}
