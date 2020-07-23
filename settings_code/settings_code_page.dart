import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/login_page.dart';

class settings extends StatefulWidget {
  @override
  _settingsState createState() => _settingsState();
}

class _settingsState extends State<settings> {
  FirebaseUser user;
  Future <void> getUserData() async{
    FirebaseUser userData = await FirebaseAuth.instance.currentUser();
    setState(() {
      user = userData;
    });
  }
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    getUserData();
  }
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF4C4B4B),
      child: new Column(
        children: <Widget>[
          const SizedBox(
            height: 76,
          ),
          Text(
            "Settings",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 45),
          ),
          const SizedBox(
            height: 90,
          ),
          new ButtonTheme(
            minWidth: 150.0,
            height: 50.0,
            child: new RaisedButton(
              onPressed: (){
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen1()));
              },
              color: Colors.red,
              textColor: Colors.black,
              child: Column(
                children: <Widget>[
                  new Text("Logout", style: TextStyle(fontSize: 20, letterSpacing: 2),)
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          new ButtonTheme(
            minWidth: 150.0,
            height: 50.0,
            child: new RaisedButton(
              onPressed: (){
                print("${user?.email}");
                FirebaseAuth.instance.sendPasswordResetEmail(email: "${user?.email}").then((value) async {Scaffold.of(context).showSnackBar(SnackBar(content: Text('Email sent successfully! ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),), backgroundColor: Colors.green,));}).catchError((e){print(e); return SnackBar(content: Text('There was an error during the process of sending the email!'), backgroundColor: Colors.red,);});
              },
              color: Colors.red,
              textColor: Colors.black,
              child: Column(
                children: <Widget>[
                  new Text("Reset Password", style: TextStyle(fontSize: 20, letterSpacing: 2),)
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          new ButtonTheme(
            minWidth: 150.0,
            height: 50.0,
            child: new RaisedButton(
              onPressed: ()async {
                print("${user?.email}");
                bool result = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: myController,
                            decoration: new InputDecoration(
                              labelText: "Enter New Username",
                            ),
                        ),
                      ),
                      actions: <Widget>[
                        new FlatButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop(false);
                          },
                          child: Text('Cancel'),
                        ),
                        RaisedButton(
                          onPressed: () {
                            if ((myController.text).length <= 3){
                              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Error! Your new username is too short. ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),), backgroundColor: Colors.red,));
                            }
                            else{
                              Firestore.instance.collection("Users").document("${user?.email}")
                                  .updateData({ 'username': myController.text}).then((username) {Navigator.of(context, rootNavigator: true).pop(true);}).catchError((e){print(e);});
                            }
                            return null;
                          },
                          child: Text('Confirm'),
                          color: Colors.red,
                        ),
                      ],
                    );
                  },
                );
              },
              color: Colors.red,
              textColor: Colors.black,
              child: Column(
                children: <Widget>[
                  new Text("Change Username", style: TextStyle(fontSize: 20, letterSpacing: 2),)
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}
