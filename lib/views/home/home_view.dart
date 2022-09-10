import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_chat/core/app_navigator.dart';
import 'package:face_chat/views/auth/login_view.dart';
import 'package:face_chat/views/home/add_post.dart';
import 'package:face_chat/views/home/map_tab.dart';
import 'package:face_chat/views/home/posts_tab.dart';
import 'package:face_chat/views/home/video_room_tab.dart';
import 'package:face_chat/views/inbox/inbox_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  int pageIndex = 0;

  // Local Notifications variables
  AndroidInitializationSettings androidLNInit =
      const AndroidInitializationSettings('app_icon');
  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project

  final IOSInitializationSettings iosLNInit = IOSInitializationSettings(
    onDidReceiveLocalNotification: (id, title, body, payload) {},
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  late AndroidNotificationChannel channel;
  late NotificationDetails notificainoDetails;

  @override
  void initState() {
    super.initState();

    channel = const AndroidNotificationChannel(
      'com.sot.face_chat',
      'notifications',
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    notificainoDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
      ),
    );

    flutterLocalNotificationsPlugin.initialize(InitializationSettings(
      android: androidLNInit,
      iOS: iosLNInit,
    ));

    FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getToken().then((token) {
      FirebaseFirestore.instance.doc("users/$uid").update({
        'fcm_token': token,
      });
    });

    FirebaseMessaging.onMessage.listen((msg) {
      String title = msg.notification!.title!;
      String body = msg.notification!.body!;
      flutterLocalNotificationsPlugin.show(
        msg.hashCode,
        title,
        body,
        notificainoDetails,
      );
      print("OnMessage $title , $body , ${msg.data.toString()}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      String title = msg.notification!.title!;
      String body = msg.notification!.body!;
      print("OnmessageOpenedApp $title , $body , ${msg.data.toString()}");
    });
  }

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
        children: [PostTab(), MapTab(), InboxView(), VideoRoomTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // appNavPush(context, AddPostView());
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: pageIndex == 0
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.startFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (int newIndex) {
          setState(() {
            pageIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Inbox"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Rooms"),
        ],
      ),
    );
  }
}
