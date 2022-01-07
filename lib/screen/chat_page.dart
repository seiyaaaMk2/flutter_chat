import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/model/chat_room_manager.dart';
import './view/message_line.dart';

final _db = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
User _user = _auth.currentUser!;

class ChatPage extends StatefulWidget {
  static const String id = 'chat_page';
  String title = 'Chat Room: ${ChatRoomManager().roomID}';

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageTextController = TextEditingController();
  String messageText = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              onPressed: (){
                _auth.signOut();
                Navigator.pop(context);
              },
              icon: Icon(Icons.close))
        ],
        title: Text(widget.title),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value){
                        messageText = value;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0
                        ),
                        hintText: '${ChatRoomManager().roomID}にテキストを入力',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      messageTextController.clear();
                      _db.collection('rooms').doc(ChatRoomManager().roomID).collection('messages').add({
                        'message' : messageText,
                        'sender' : _user.email,
                        'time' : FieldValue.serverTimestamp(),
                      });
                    },
                    child: Text(
                      '送信',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot> (
      // stream: _db.collection('messages').orderBy('time', descending: true).limit(50).snapshots(),
      stream: _db.collection('rooms').doc(ChatRoomManager().roomID).collection('messages').orderBy('time', descending: true).limit(50).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        dynamic temp = snapshot.data;
        final messages = temp != null ? snapshot.data!.docs : [];
        List<MessageLine> messageLines = [];
        messages.forEach((message) {
          final Map<String, dynamic> doc = message.data();
          final messageText = doc['message'];
          final messageSender = doc['sender'];
          final messageTime = doc['time'];

          final messageLine = MessageLine(
            text: messageText,
            sender: messageSender,
            time: messageTime,
            isMine: _user.email == messageSender,
          );

          messageLines.add(messageLine);

        });

        return Expanded(child: ListView(
          reverse: true,
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          children: messageLines,
        ));
      },
    );
  }
}


