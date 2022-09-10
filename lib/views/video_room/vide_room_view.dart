import 'dart:convert';

import 'package:agora_rtc_engine/rtc_engine.dart';
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

  late String channelName;
  late String token;
  int? agoraUid;
  late ClientRole role;
  String appId = "d6bad162b93145d0b2bdcf01ff8d2566";
  @override
  void initState() {
    super.initState();
    channelName = widget.room.id;
    role = widget.room.data()['creator_id'] == uid
        ? ClientRole.Broadcaster
        : ClientRole.Audience;
    if (role == ClientRole.Broadcaster) {
      FirebaseFirestore.instance.doc("rooms/${widget.room.id}").update({
        'live': true,
      });
    }
    initAgora();
  }

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

  Set<int> uids = Set<int>();

  @override
  void dispose() {
    if (role == ClientRole.Broadcaster) {
      FirebaseFirestore.instance.doc("rooms/${widget.room.id}").update({
        'live': false,
      });
    }
    _engine.leaveChannel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (uid == widget.room.data()['creator_id'])
              const Expanded(child: RtcLocalView.SurfaceView()),
            if (uid != widget.room.data()['creator_id'])
              Expanded(
                child: Stack(
                  children: [
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
      ),
    );
  }
}
