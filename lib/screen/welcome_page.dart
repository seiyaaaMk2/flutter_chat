import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_chat/screen/home_page.dart';
import 'package:flutter_chat/screen/register_page.dart';
import 'package:flutter_chat/screen/signin_page.dart';
import 'package:flutter_signin_button/button_builder.dart';

class WelcomePage extends StatelessWidget {
  static const String id = 'welcome_page';
  final String title = 'Welcome';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  WelcomePage({Key? key}) : super(key: key) {
    _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
    _firebaseMessaging.getToken().then((String? token) {
      assert(token != null);
      // tokenの中にFcmTokenが入ってる
      print("Push Messaging token: $token");
      // firestoreへtokenの更新を行う

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: SignInButtonBuilder(
              icon: Icons.person_add,
              backgroundColor: Colors.indigo,
              text: 'Registration',
              onPressed: () => Navigator.pushNamed(context, RegisterPage.id),
            ),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
          ),
          Container(
            child: SignInButtonBuilder(
              icon: Icons.verified_user,
              backgroundColor: Colors.orange,
              text: 'Sign In',
              onPressed: () => Navigator.pushNamed(context, SignInPage.id),
            ),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
          ),
          Container(
            child: ElevatedButton(
              onPressed: (){
                Navigator.pushNamed(context, HomePage.id);
              },
              child: Text(
                  "ログインなしでホーム画面へ(検証用)"
              ),
            ),
          )
        ],
      ),
    );
  }
}
