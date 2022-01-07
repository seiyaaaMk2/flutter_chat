import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import './screen/welcome_page.dart';
import './screen/signin_page.dart';
import './screen/register_page.dart';
import './screen/home_page.dart';
import './screen/enter_room_page.dart';
import './screen/chat_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ChatApp',
      initialRoute: WelcomePage.id,
      routes: {
        WelcomePage.id: (context) => WelcomePage(),
        RegisterPage.id: (context) => RegisterPage(),
        SignInPage.id: (context) => SignInPage(),
        HomePage.id: (context) => HomePage(),
        EnterRoomPage.id: (context) => EnterRoomPage(),
        ChatPage.id: (context) => ChatPage(),
      },
    );
  }
}
