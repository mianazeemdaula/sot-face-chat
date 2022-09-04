import 'package:face_chat/core/app_navigator.dart';
import 'package:face_chat/views/auth/login_view.dart';
import 'package:face_chat/views/home/add_post.dart';
import 'package:face_chat/views/home/map_tab.dart';
import 'package:face_chat/views/home/posts_tab.dart';
import 'package:face_chat/views/inbox/inbox_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              appNavReplace(context, const LoginView());
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: IndexedStack(
        index: pageIndex,
        children: [PostTab(), MapTab(), InboxView()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          appNavPush(context, AddPostView());
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: pageIndex == 0
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.startFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: (int newIndex) {
          setState(() {
            pageIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Inbox"),
        ],
      ),
    );
  }
}
