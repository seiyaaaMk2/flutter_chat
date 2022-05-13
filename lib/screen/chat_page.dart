import 'dart:core';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/model/chat_room_manager.dart';
import 'package:flutter_chat/screen/view/image_line.dart';
import 'package:flutter_chat/screen/view/scaffold_snackbar.dart';
import 'package:flutter_chat/util/size_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io' as io;
import 'package:image_picker/image_picker.dart';
import './view/message_line.dart';

final _db = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
final _storage = FirebaseStorage.instance;
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
  late io.File _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              onPressed: () async {
                await showDialog<int> (
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('ID:${ChatRoomManager().roomID} のチャットルームを削除します。'),
                      content: Text('よろしいですか？'),
                      actions: [
                        ElevatedButton(onPressed: () {
                          _db.collection('rooms').doc(ChatRoomManager().roomID).delete();
                          Navigator.pop(context);
                          ScaffoldSnackbar.of(context).show('ID:${ChatRoomManager().roomID} のチャットルームを削除しました');
                          Navigator.of(context).pop();
                        }, child: Text('削除する')),
                      ElevatedButton(onPressed: () => { Navigator.of(context).pop() }, child: Text('キャンセル'))
                      ],
                    );
                  },

                );
              },
              icon: Icon(Icons.delete_forever))
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
                  IconButton(onPressed: () async {
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    setState(() {
                      if (pickedFile == null) { return; }
                      uploadFile(pickedFile.path);
                    });
                  }, icon: Icon(Icons.add_photo_alternate)),
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

  Future<void> uploadFile(String sourcePath) async {

    var uploadFileName = "";
    DocumentReference<Map<String, dynamic>> doc = await _db.collection('rooms').doc(ChatRoomManager().roomID).collection('messages').add({
      'message' : "",
      'sender' : _user.email,
      'isImage' : true,
      'time' : FieldValue.serverTimestamp(),
    });

    uploadFileName = doc.id;

    String filePath = "images/" + ChatRoomManager().roomID + "/";
    Reference ref = _storage.ref().child(filePath);  //保存するフォルダ

    io.File file = io.File(sourcePath);
    UploadTask task = ref.child(uploadFileName).putFile(file);
  }
}

class BaseMessageInfo {
  /// 表示名
  late String name;
  /// メールアドレス
  late String messageSender;
  /// 送信時間
  late Timestamp messageTime;

  BaseMessageInfo(name, messageSender, messageTime) {
    this.name = name;
    this.messageSender = messageSender;
    this.messageTime = messageTime;
  }
}

class TextMessageInfo extends BaseMessageInfo {
  /// メッセージ本文
  late String messageText = "";

  TextMessageInfo(name, messageText, messageSender, messageTime): super(name, messageSender, messageTime) {
    this.messageText = messageText;
  }
}

class ImageMessageInfo extends BaseMessageInfo {
  /// 画像本体
  late Image image = Image(
    image: NetworkImage(
        'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
  );

  ImageMessageInfo(name, image, messageSender, messageTime) : super(name, messageSender, messageTime) {
    this.image = image;
  }
}

class MessageStream extends StatelessWidget {
  Stream<List<BaseMessageInfo>> messagesStream(String roomID) {
    return _db
        .collection('rooms')
        .doc(roomID)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots()
        .asyncMap((messages) => Future.wait([for (var message in messages.docs) generateMessageInfo(message)]));
  }

  Future<BaseMessageInfo> generateMessageInfo(QueryDocumentSnapshot<Map<String, dynamic>> message) async {
    var messageData = message.data();
    var doc = await _db.collection('users').doc(message.get('sender')).get();
    var nickName = await doc.get('name');

    bool? isImage = false;
    if(messageData.containsKey('isImage')) {
      isImage = await message.get('isImage');
    }

    if (isImage != null && isImage == true) {
      final fileName = message.id;
      final filePath = "images/" + ChatRoomManager().roomID + "/" + fileName;
      final String url = await _storage.ref(filePath).getDownloadURL();
      final image = new Image(image: new CachedNetworkImageProvider(url));
      return ImageMessageInfo(nickName, image, message.get('sender'), message.get('time'));
    } else {
      print("👺message: " + message.get('message'));
      return TextMessageInfo(nickName, message.get('message'), message.get('sender'), message.get('time'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder (
      stream: messagesStream(ChatRoomManager().roomID),
      builder: (context, AsyncSnapshot<List<BaseMessageInfo>> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        List<Widget> messageLines = [];
        snapshot.data!.forEach((messageInfo) {
          final isMine = _user.email == messageInfo.messageSender;
          var messageLine;
          if (messageInfo is TextMessageInfo) {
            messageLine = MessageLine(sender: messageInfo.name, text: messageInfo.messageText, time: messageInfo.messageTime, isMine: isMine);
          } else if (messageInfo is ImageMessageInfo) {
            messageLine = ImageLine(sender: messageInfo.name, image: messageInfo.image, time: messageInfo.messageTime, isMine: isMine);
          }
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


