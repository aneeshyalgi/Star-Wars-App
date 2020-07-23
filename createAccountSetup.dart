import 'package:flutter/material.dart';
import 'main_app.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class continueAccountSetup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime selectedDate = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
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
      backgroundColor: Color(0xFF4C4B4B),
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: ListView(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 60,
            ),
            new Text("Continue Account Setup", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 40),textAlign: TextAlign.center,),
            SizedBox(height: 55.0,),
            new TextFormField(
              controller: myController,
              decoration: new InputDecoration(
                labelText: "Enter Username",
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
            Text("${selectedDate.toLocal()}".split(' ')[0], style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),),
            RaisedButton(
              color: Colors.red,
              onPressed: () => _selectDate(context),
              child: Text('Select date of birth', style: TextStyle(color: Colors.black, fontSize: 15),),
            ),
            SizedBox(height: 40.0,),
            RaisedButton(
              color: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.red)
              ),

              child: Text('Submit data', style: TextStyle(color: Colors.black, fontSize: 20),),
              onPressed: () {
                if((myController.text).length <= 3){
                  return AlertDialog(
                    content: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: new Text("Your Username has to be more than 3 characters", style: TextStyle(fontSize: 20, color: Colors.red),),
                    ),
                  );
                }
                else {
                  Firestore.instance.collection("Users")
                      .document("${user?.email}")
                      .updateData({ 'username': myController.text, 'birthday': "${selectedDate.toLocal()}" })
                      .then((signedInUser){
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => main_app()
                            )
                        );
                      }).catchError(((e){print(e);}));
                }
                return null;
              },
            )
          ],
        ),
      ),
    );
  }
}