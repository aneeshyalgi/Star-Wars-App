import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:get/get.dart";
import 'package:flutter_login/flutter_login.dart';
import 'main_app.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'createAccountSetup.dart';
import 'dart:async';

class LoginScreen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  Duration get loginTime => Duration(seconds: 2);

  @override
  Widget build(BuildContext context) {
    Future<String> _authUser(LoginData data) async{
      print('Name: ${data.name}, Password: ${data.password}');
      return Future.delayed(loginTime).then((_) async {
        FirebaseAuth.instance.signInWithEmailAndPassword(email: data.name, password: data.password)
            .then((signedInUser){Navigator.of(context).pop();Navigator.of(context).push(MaterialPageRoute(builder: (context) => main_app()));})
            .catchError((e){
              print(e);
              showDialog(context: context, builder: (BuildContext context){
                return AlertDialog(title: new Text("Authentication Error!", style: TextStyle(color: Colors.red),), content:new Text("The account you entered does not exist. Check what you have typed. \nTap anyware to dismiss.", style: TextStyle(color: Colors.red)),);});Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen1()));});
        return null;
      });
    }

    Future<String> _SignUp(LoginData data) async{
      print('Name: ${data.name}, Password: ${data.password}');
      return Future.delayed(loginTime).then((_) async {
        if((data.password).length < 7){
          return "Password must be greater than 7 characters";
        }
        FirebaseAuth.instance.createUserWithEmailAndPassword(email: data.name, password: data.password)
            .then((signedInUser){
              Firestore.instance.collection("Users").document(data.name).setData({"email": data.name}).then((signedInUser){Navigator.of(context).pop();Navigator.of(context).push(MaterialPageRoute(builder: (context) => continueAccountSetup()));}).catchError((e){print(e);});
            })
            .catchError((e){print(e); showDialog(context: context, builder: (BuildContext context){return AlertDialog(title:new Text("Authentication Error!", style: TextStyle(color: Colors.red),), content: new Text("The email you entered has already been taken. \nTap anyware to dismiss.", style: TextStyle(color: Colors.red)),);});Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen1()));});
        return null;
      });

    }

    Future<String> _recoverPassword(String name){
      print('Name: $name');
      return Future.delayed(loginTime).then((_)async {
        FirebaseAuth.instance.sendPasswordResetEmail(email: name);
        return null;
      });
    }
    return FlutterLogin(
      title: 'Star Wars App',
      //logo: 'assets/StarWarsLOGO.png',
      onLogin: _authUser,
      onSignup: _SignUp,
      onSubmitAnimationCompleted: () {

      },
      onRecoverPassword: _recoverPassword,
      messages: LoginMessages(
        recoverPasswordDescription:
        'We will send you an email to recover your password. If the email you entered does not exist in our database, then you will not get an email.',
        recoverPasswordSuccess: 'Password rescued successfully',
        signupButton: 'CREATE ACCOUNT',
      ),
      theme: LoginTheme(
        titleStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: "Quicksand",
          color: Colors.red.withOpacity(0.9),
            shadows: [
              Shadow( // bottomLeft
                  offset: Offset(-2.5, -2.5),
                  color: Colors.black
              ),
              Shadow( // bottomRightmain_app.dart
                  offset: Offset(2.5, -2.5),
                  color: Colors.black
              ),
              Shadow( // topRight
                  offset: Offset(2.5, 2.5),
                  color: Colors.black
              ),
              Shadow( // topLeft
                  offset: Offset(-2.5, 2.5),
                  color: Colors.black
              ),
            ]
        ),
        inputTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.red.withOpacity(0.3),
        ),
        buttonTheme: LoginButtonTheme(
          splashColor: Colors.red,
          elevation: 5.0,
          highlightElevation: 6.0,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.red.withOpacity(0.3))
          ),
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          //shape: CircleBorder(side: BorderSide(color: Colors.green)),
          // shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(55.0)),
        ),
        accentColor: Colors.red,
      ),
    );
  }
}