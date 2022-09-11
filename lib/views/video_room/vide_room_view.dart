import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

class VideoRoomView extends StatefulWidget {
  const VideoRoomView({Key? key, required this.room}) : super(key: key);
  final QueryDocumentSnapshot<Map<String, dynamic>> room;
  @override
  State<VideoRoomView> createState() => _VideoRoomViewState();
}

class _VideoRoomViewState extends State<VideoRoomView> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  final msgTextContoller = TextEditingController();

  late String channelName;
  late String token;
  int? agoraUid;
  late ClientRole role;
  String appId = "d6bad162b93145d0b2bdcf01ff8d2566";
  late DocumentReference<Map<String, dynamic>> roomDoc;
  late DocumentSnapshot<Map<String, dynamic>> authData;
  @override
  void initState() {
    super.initState();
    roomDoc = FirebaseFirestore.instance.doc("rooms/${widget.room.id}");

    channelName = widget.room.id;
    role = widget.room.data()['creator_id'] == uid
        ? ClientRole.Broadcaster
        : ClientRole.Audience;

    initAgora().then((value) async {
      if (role == ClientRole.Broadcaster) {
        await roomDoc.update({
          'live': true,
        });
      } else {
        await roomDoc.update({
          'joined_uids': FieldValue.arrayUnion([uid]),
        });
      }
      FirebaseFirestore.instance.doc("users/$uid").get().then((value) {
        if (mounted) {
          setState(() {
            authData = value;
          });
        }
      });
      stream = roomDoc.snapshots().listen((event) {
        isLive = event.data()!['live'];
        audianceCount = List.from(event.data()!['joined_uids']).length;
        setState(() {});
      });
    });
  }

  late StreamSubscription stream;

  bool isLive = false;
  int audianceCount = 0;

  late RtcEngine _engine;

  Future initAgora() async {
    int _role = role == ClientRole.Broadcaster ? 1 : 0;
    String url =
        "http://livearena.aiustack.com/?channel=$channelName&role=$_role";
    var resposne = await http.get(Uri.parse(url));
    Map<String, dynamic> data = jsonDecode(resposne.body);
    token = data['tokenA'];
    agoraUid = data['uid'];
    _engine = await RtcEngine.create(appId);
    await _engine.enableVideo();
    await _engine.enableAudio();
    await _engine.joinChannel(token, channelName, null, agoraUid!);
    _engine.setEventHandler(RtcEngineEventHandler(
      userJoined: (uid, elapsed) {
        setState(() {
          uids.add(uid);
        });
      },
      userOffline: (uid, reason) {
        setState(() {
          uids.remove(uid);
        });
      },
    ));
  }

  Set<int> uids = <int>{};

  @override
  void dispose() async {
    await stream.cancel();
    if (role == ClientRole.Broadcaster) {
      roomDoc.update({
        'live': false,
      });
    } else {
      roomDoc.update({
        'joined_uids': FieldValue.arrayRemove([uid])
      });
    }
    await _engine.leaveChannel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (uid == widget.room.data()['creator_id'])
                  const Expanded(child: RtcLocalView.SurfaceView()),
                if (uid != widget.room.data()['creator_id'])
                  Expanded(
                    child: Stack(
                      children: [
                        if (uids.isNotEmpty)
                          RtcRemoteView.SurfaceView(
                            channelId: channelName,
                            uid: uids.first,
                          ),
                        Container(
                          height: 250,
                          width: 250,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 5),
                          ),
                          child: RtcLocalView.SurfaceView(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 70,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: isLive ? Colors.red : Colors.grey,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor:
                            isLive ? Colors.red.shade600 : Colors.grey.shade600,
                      ),
                      SizedBox(width: 5),
                      Text("Live")
                    ],
                  ),
                ),
                Container(
                  width: 70,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.supervised_user_circle),
                      SizedBox(width: 5),
                      Text("$audianceCount")
                    ],
                  ),
                )
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: roomDoc
                            .collection('msgs')
                            .orderBy('created_at', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              reverse: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                        snapshot.data!.docs[index]
                                            .data()['sender_image']),
                                  ),
                                  title: Text(
                                    snapshot.data!.docs[index]
                                        .data()['sender_name'],
                                  ),
                                  subtitle: Text(
                                    snapshot.data!.docs[index]
                                        .data()['message'],
                                  ),
                                );
                              },
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('wallet')
                                .doc(widget.room.data()['creator_id'])
                                .update({
                              'balance': FieldValue.increment(200),
                            });
                            FirebaseFirestore.instance
                                .collection('wallet')
                                .doc(uid)
                                .update({
                              'balance': FieldValue.increment(-200),
                            });
                          },
                          icon: Icon(Icons.emoji_emotions, color: Colors.white),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: msgTextContoller,
                          ),
                        ),
                        const SizedBox(width: 5),
                        IconButton(
                          onPressed: () async {
                            if (msgTextContoller.text.isNotEmpty) {
                              await roomDoc.collection('msgs').doc().set({
                                'message': msgTextContoller.text,
                                'sender_id': uid,
                                'sender_name': authData.data()!['name'],
                                'sender_image': authData.data()!['image'],
                                'created_at': FieldValue.serverTimestamp(),
                              });
                              msgTextContoller.clear();
                            }
                          },
                          icon: Icon(Icons.send),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
