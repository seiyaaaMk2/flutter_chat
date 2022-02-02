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

class MessageInfo {
  /// 表示名
  late String name;
  late String messageText;
  /// メールアドレス
  late String messageSender;
  late Timestamp messageTime;

  MessageInfo(name, messageText, messageSender, messageTime) {
    this.name = name;
    this.messageText = messageText;
    this.messageSender = messageSender;
    this.messageTime = messageTime;
  }
}

class MessageStream extends StatelessWidget {
  Stream<List<MessageInfo>> messagesStream(String roomID) {
    return _db
        .collection('rooms')
        .doc(roomID)
        .collection('messages')
        .orderBy('time')
        .snapshots()
        .asyncMap((messages) => Future.wait([for (var message in messages.docs) generateMessageInfo(message)]));
  }

  Future<MessageInfo> generateMessageInfo(QueryDocumentSnapshot message) async {
    var doc = await _db.collection('users').doc(message.get('sender')).get();
    var nickName = await doc.get('name');
    return MessageInfo(nickName, message.get('message'), message.get('sender'), message.get('time'));
  }

  @override
  Widget build(BuildContext context) {
    // return StreamBuilder<QuerySnapshot> (
    return StreamBuilder (
      stream: messagesStream("1111"),
      builder: (context, AsyncSnapshot<List<MessageInfo>> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        List<MessageLine> messageLines = [];
        snapshot.data!.forEach((messageInfo) {
          final isMine = _user.email == messageInfo.messageSender;
          final messageLine = MessageLine(sender: messageInfo.name, text: messageInfo.messageText, time: messageInfo.messageTime, isMine: isMine);
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


