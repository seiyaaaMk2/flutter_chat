import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/util/size_config.dart';
import 'package:intl/intl.dart';

class ImageLine extends StatelessWidget {
  final String sender;
  final Image image;
  final Timestamp time;
  final bool isMine;

  ImageLine(
      {required this.sender,
      required this.image,
      required this.time,
      required this.isMine});

  String messageTime() {
    DateFormat outputFormat = DateFormat('HH:mm');
    return outputFormat.format(time.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            // sender,
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Row(
            mainAxisAlignment:
                isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                    right: isMine ? 5.0 : 0.0,
                    top: 10.0,
                    left: isMine ? 0.0 : 5.0),
                alignment: Alignment.bottomCenter,
                child: Text(
                  messageTime(),
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black54,
                  ),
                ),
              ),
              Material(
                borderRadius: isMine
                    ? BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        bottomLeft: Radius.circular(30.0),
                        bottomRight: Radius.circular(30.0))
                    : BorderRadius.only(
                        topRight: Radius.circular(30.0),
                        bottomLeft: Radius.circular(30.0),
                        bottomRight: Radius.circular(30.0)),
                elevation: 5.0,
                color: isMine ? Colors.lightBlueAccent : Colors.white,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: SizeConfig.blockSizeHorizontal * 70),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: image,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
