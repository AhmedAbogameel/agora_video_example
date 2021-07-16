import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

const appId = "fd581ce4c5674aebbdcf3afbb4067aa1";
const token = "006fd581ce4c5674aebbdcf3afbb4067aa1IABoj8bDu+KQxQ68LTeMWti/9Pc7vgw55h2+d89xkggNZgx+f9gAAAAAEAAApPzog+HyYAEAAQCD4fJg";

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _remoteUid;
  RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initForAgora();
  }

  Future<void> initForAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = await RtcEngine.createWithConfig(RtcEngineConfig(appId));

    await _engine.enableVideo();

    _engine.setEventHandler(
      RtcEngineEventHandler(

        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print("local user $uid joined");
        },

        userJoined: (int uid, int elapsed) {
          print("remote user $uid joined");
          setState(() {
            _remoteUid = uid;
          });
        },

        userOffline: (int uid, UserOfflineReason reason) {
          print("remote user $uid left channel");
          setState(() {
            _remoteUid = null;
          });
        },

      ),
    );

    await _engine.joinChannel(token, "test", null, 0);
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call Example'),
      ),
      body: Column(
        children: [
          Expanded(child: _renderLocalPreview()),
          Expanded(child: _renderRemoteVideo()),
        ],
      ),
    );
  }

  // current user video
  Widget _renderLocalPreview() => RtcLocalView.SurfaceView();

  // remote user video
  Widget _renderRemoteVideo() {
    if (_remoteUid != null)
      return RtcRemoteView.SurfaceView(uid: _remoteUid);
    else
      return Text(
        'Please wait user to join',
        textAlign: TextAlign.center,
      );
  }
}