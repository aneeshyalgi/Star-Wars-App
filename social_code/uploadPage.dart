import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:app/login_page.dart';
import 'package:app/main_app.dart';

class upload extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: uploadCode(),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    );
  }
}  

class uploadCode extends StatefulWidget {
  @override
  _uploadCodeState createState() => _uploadCodeState();
}

class _uploadCodeState extends State<uploadCode> {

  final postTitle = TextEditingController();
  final postContent = TextEditingController();

  @override
  void dispose() {
    postTitle.dispose();
    postContent.dispose();
    super.dispose();
  }
  FirebaseUser user;
  Future <void> getUserData() async{
    FirebaseUser userData = await FirebaseAuth.instance.currentUser();
    setState(() {
      user = userData;
      print(userData.email);
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Color(0xFF4C4B4B),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: <Widget>[
          const SizedBox(
            height: 60,
          ),
          new Text("Create new Post", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 40),textAlign: TextAlign.center,),
          SizedBox(height: 55.0,),
          new TextFormField(
            controller: postTitle,
            decoration: new InputDecoration(
              labelText: "Enter Post Title",
              fillColor: Colors.white,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(25.0),
                borderSide: new BorderSide(

                ),
              ),
            ),
            validator: (val) {
              if(val.length==0) {
                return "Email cannot be empty";
              }else{
                return null;
              }
            },
          ),
          SizedBox(height: 20.0,),
          new TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: postContent,
            decoration: new InputDecoration(
              labelText: "Enter Content",
              fillColor: Colors.white,
              contentPadding: new EdgeInsets.symmetric(vertical: 100.0, horizontal: 10.0),
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(25.0),
                borderSide: new BorderSide(

                ),
              ),
            ),
            validator: (val) {
              if(val.length==0) {
                return "Email cannot be empty";
              }else{
                return null;
              }
            },
          ),
          SizedBox(height: 20.0,),
          RaisedButton(
            color: Colors.red,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.red)
            ),

            child: Text('Submit data', style: TextStyle(color: Colors.black, fontSize: 20),),
            onPressed: () {
              if((postContent.text).length <= 20){
                Scaffold.of(context).showSnackBar(SnackBar(content: Text('Error! Your post content is too less.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),), backgroundColor: Colors.red,));
              }
              if((postTitle.text).length <= 5){
                Scaffold.of(context).showSnackBar(SnackBar(content: Text('Error! Your post title is too short.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),), backgroundColor: Colors.red,));
              }
              else{
                FocusScope.of(context).unfocus();
                Firestore.instance.collection("Social_Posts")
                    .document()
                    .setData({"postTitle" : postTitle.text, "postContent" : postContent.text, "userEmail" : "${user?.email}", "views" : 0, "likes" : 0, "dislikes" : 0, "comments": []})
                    .then((signedInUser){
                  Scaffold.of(context).showSnackBar(SnackBar(content: Text('Post Successfully Uploaded! ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),), backgroundColor: Colors.green,));
                  print("done");
                }).catchError(((e){print(e);}));
              }
              return null;
            },
          )
        ],
      ),
    );
  }
}

