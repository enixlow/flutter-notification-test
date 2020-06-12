import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class FirebaseCloudMessaging extends StatefulWidget {
  @override
  _FirebaseCloudMessagingState createState() => _FirebaseCloudMessagingState();
}

class _FirebaseCloudMessagingState extends State<FirebaseCloudMessaging> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String userToken = "";
  //register user to firebase and get token
  void getFirebaseToken() async {
    _firebaseMessaging.getToken().then((token) => setState(() {
          print(token);
          setState(() {
            userToken = token;
          });
        }));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getFirebaseToken();
    //firebase configuration when receive notification
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print("onMessage: $message");
      final notification = message['notification'];
    }, onLaunch: (Map<String, dynamic> message) async {
      print("onLaunch: $message");
      final notification = message['data'];
    }, onResume: (Map<String, dynamic> message) async {
      print("onResume: $message");
      final notification = message['data'];
    });
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    Stream<String> tokenRefreshStream = _firebaseMessaging.onTokenRefresh;
    tokenRefreshStream.listen((token) {
      print("onTokenRefresh: "+token);
      _writeTextFile(token);
    });
  }

  _writeTextFile(String token) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/token_history.txt');
    print('Directory path: ${directory.path}');
    await file.writeAsString(token);
  }

  Future<String> _read() async {
  String text;
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/token_history.txt');
    text = await file.readAsString();
    print(text);
  } catch (e) {
    print("Couldn't read file");
  }
  return text;
}


  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          Container(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment:  MainAxisAlignment.start,
              children: <Widget>[
                Text('----------------------' + userToken),
                FloatingActionButton(onPressed: () {
                  Clipboard.setData(ClipboardData(text: userToken?? "NO TOKEN"));
                }),
              ],
            ),
          ),
        ],
      );
}
