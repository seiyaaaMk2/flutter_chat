import 'package:flutter/material.dart';
import 'package:flutter_chat/model/chat_room_manager.dart';
import 'dart:math';
import 'package:intl/intl.dart';

import 'package:flutter_chat/screen/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/screen/enter_room_page.dart';
import 'package:flutter_chat/screen/view/scaffold_snackbar.dart';
import 'package:flutter_signin_button/button_builder.dart';

final _db = FirebaseFirestore.instance;

class HomePage extends StatefulWidget {
  static const String id = 'home_page';
  final String title = 'Home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: SignInButtonBuilder(
              icon: Icons.mark_chat_unread_rounded,
              backgroundColor: Colors.lightBlueAccent,
              text: '部屋を作って入る',
              onPressed: () {
                _createRoomWithNewRoomID();
              },
            ),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
          ),
          Container(
            child: SignInButtonBuilder(
              icon: Icons.login,
              backgroundColor: Colors.teal,
              text: '既存の部屋に入る',
              onPressed: () => Navigator.pushNamed(context, EnterRoomPage.id),
            ),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }

  String createRandomIDString() {
    var rand = new Random();
    int num = (rand.nextDouble() * 10000).toInt();
    return num.toString().padLeft(4, "0");
  }

  Future<void> _createRoomWithNewRoomID() async {
    var randomRoomID = createRandomIDString();
    DocumentSnapshot<Map<String, dynamic>>? snap = await _db.collection('rooms').doc(randomRoomID).get().then((DocumentSnapshot<Map<String, dynamic>> value) async {
      if (value.exists) {
        _createRoomWithNewRoomID();
      } else {
        ChatRoomManager().roomID = randomRoomID;
        await _db.collection('rooms').doc(randomRoomID).set({});
        ScaffoldSnackbar.of(context).show('ID:${ChatRoomManager().roomID} のチャットルームを作成しました');
        Navigator.pushNamed(context, ChatPage.id);
      }
    });
  }
}
