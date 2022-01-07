import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/model/chat_room_manager.dart';
import 'package:flutter_chat/screen/view/scaffold_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat/screen/chat_page.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final _db = FirebaseFirestore.instance;

class EnterRoomPage extends StatefulWidget {
  static const String id = 'enter_room_page';
  final String title = 'Room select';

  @override
  _EnterRoomPageState createState() => _EnterRoomPageState();
}

class _EnterRoomPageState extends State<EnterRoomPage> {
  final TextEditingController _roomIdController = TextEditingController();
  int roomID = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: const Text(
                  'ルームIDを入力してください',
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ),
              TextFormField(
                controller: _roomIdController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Room ID'),
              ),
              Container(
                child: SignInButtonBuilder(
                  icon: Icons.login,
                  backgroundColor: Colors.grey[700]!,
                  text: '部屋に入る',
                  onPressed: () async {
                    _enterRoomWithRoomID();
                  },
                ),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  Future<void> _enterRoomWithRoomID() async {
    String inputValue = _roomIdController.text;
    if (inputValue.isEmpty && inputValue.length != 4) {
      ScaffoldSnackbar.of(context).show('IDを入力してください');
      return;
    }
    roomID = int.tryParse(inputValue) ?? -1;
    if (roomID == -1) {
      ScaffoldSnackbar.of(context).show('4桁のIDを入力してください');
      return;
    }
    DocumentSnapshot<Map<String, dynamic>>? snap = await _db.collection('rooms').doc(_roomIdController.text).get().then((DocumentSnapshot<Map<String, dynamic>> value) async {
      if (value.exists) {
        ChatRoomManager().roomID = _roomIdController.text;
        ScaffoldSnackbar.of(context).show('ID:${ChatRoomManager().roomID} のチャットルームに入室しました');
        Navigator.pushNamed(context, ChatPage.id);
      } else {
        ScaffoldSnackbar.of(context).show('ID:${_roomIdController.text} のチャットルームはありません');
      }
    });
  }
}
