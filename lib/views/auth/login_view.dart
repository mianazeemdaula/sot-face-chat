import 'package:face_chat/core/app_navigator.dart';
import 'package:face_chat/core/snack_bar.dart';
import 'package:face_chat/views/auth/signup_view.dart';
import 'package:face_chat/views/home/home_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isBusy = false;

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: formKey,
          child: Stack(
            children: [
              Column(
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      label: Text('Email'),
                    ),
                    validator: (String? v) {
                      if (v == null || v.isEmpty) {
                        return "Please enter email";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      label: Text('Password'),
                    ),
                    obscureText: true,
                    validator: (String? v) {
                      if (v == null || v.isEmpty) {
                        return "Please enter password";
                      } else if (v.length < 6) {
                        return "Please enter at least 6 character";
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
                          setState(() {
                            isBusy = true;
                          });
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text,
                          );
                          setState(() {
                            isBusy = false;
                          });
                          appNavReplace(context, HomeView());
                        }
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          isBusy = false;
                        });
                        print(e.code);
                        if (e.code == 'wrong-password') {
                          appSnackBar(context, e.message!);
                        } else if (e.code == 'user-not-found') {
                          appSnackBar(context, e.message!);
                        } else if (e.code == 'user-disabled') {
                          appSnackBar(context, e.message!);
                        }
                      }
                    },
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Dont have an account? "),
                      const SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        onTap: () {
                          appNavPush(context, SignupView());
                        },
                        child: const Text("Signup"),
                      )
                    ],
                  )
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
