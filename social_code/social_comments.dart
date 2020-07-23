import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class comments_social extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: comments_social_code(),
    );
  }
}

class comments_social_code extends StatefulWidget {
  @override
  _comments_social_codeState createState() => _comments_social_codeState();
}

class _comments_social_codeState extends State<comments_social_code> {
  final items = List<String>.generate(10000, (i) => "Item $i");
  Widget commentBox() {
    return Container(
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.all(10.0),
      decoration:BoxDecoration(
        border: Border.all(color: Colors.grey),
      ), //       <--- BoxDecoration here
      child: Text(
        "Man, what a loser! LOL",
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Color(0xFF4C4B4B),
      appBar: new AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      bottomNavigationBar: BottomAppBar(
        child: new TextFormField(
          decoration: new InputDecoration(
            labelText: "   Add a Comment",
            fillColor: Colors.black,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(5.0),
        children: <Widget>[
          new Text("Comments", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 40),textAlign: TextAlign.center,),
          SizedBox(height: 55.0,),
          commentBox()
        ],
      )
    );
  }
}

