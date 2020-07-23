import 'package:app/main_app.dart';
import 'package:flutter/material.dart';
import "login_page.dart";
import 'introduction_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
FirebaseAuth auth = FirebaseAuth.instance;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Widget _defaultHome = new Introduction_screen();
  if (await auth.currentUser() == null) {
  _defaultHome = new Introduction_screen();
  }
  else{
  _defaultHome = new main_app();
  }
  runApp(
      MaterialApp(
      home: _defaultHome,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
));
}
