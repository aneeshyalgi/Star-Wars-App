import 'package:flutter/material.dart';
import 'popular_feedback.dart';
import 'your_feedback.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'uploadFeedback.dart';
class feedback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: feedbackPage(),
    );
  }
}

String _title;
String _content;
String _items = "Loading...";
String _items_your = "Loading...";

class viewPost extends StatefulWidget {
  @override
  _viewPostState createState() => _viewPostState();
}

class _viewPostState extends State<viewPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.thumb_up, size: 30, color: Colors.red,),
              onPressed: (){
                Firestore.instance.collection("Feedback")
                    .where("postTitle", isEqualTo: _title)
                    .where("postContent", isEqualTo: _content).getDocuments()
                    .then((event) {
                  Firestore.instance
                      .collection("Feedback")
                      .document(event.documents[0].documentID)
                      .updateData({"likes" : FieldValue.increment(1),}).then((value){});
                });
              },
              tooltip: "Like",
            ),
            IconButton(
              icon: Icon(Icons.thumb_down, size: 30, color: Colors.red,),
              onPressed: (){
                Firestore.instance.collection("Feedback")
                    .where("postTitle", isEqualTo: _title)
                    .where("postContent", isEqualTo: _content).getDocuments()
                    .then((event) {
                  Firestore.instance
                      .collection("Feedback")
                      .document(event.documents[0].documentID)
                      .updateData({"dislikes" : FieldValue.increment(1),}).then((value){});
                });
              },
              tooltip: "Dislike",
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFF4C4B4B),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomPadding: false,
      body: Container(
        padding: const EdgeInsets.all(20.0),
        alignment: Alignment.center,
        child: ListView(
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            new Text(
              _title,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 40,
            ),
            new Text(
              _content,
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class feedbackPage extends StatefulWidget {
  @override
  feedbackPageState createState() => feedbackPageState();
}

class feedbackPageState extends State<feedbackPage> {
  final CategoriesScroller categoriesScroller = CategoriesScroller();
  ScrollController controller = ScrollController();
  bool closeTopContainer = false;
  double topContainer = 0;

  List<Widget> itemsData = [];
  FirebaseUser user;

  void getPostsData() async{
    FirebaseUser userData = await FirebaseAuth.instance.currentUser();
    setState(() {
      user = userData;
      //print(userData.email);
    });
    print("${user?.email}");
    List<Widget> listItems = [];
    final QuerySnapshot result = await Firestore.instance.collection('Feedback').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    // popular feedback document count
    final QuerySnapshot queryresult = await Firestore.instance.collection('Feedback').where("views", isGreaterThan: 10).getDocuments();
    final List<DocumentSnapshot> querydocuments = queryresult.documents;
    print(querydocuments.length);
    var len = (querydocuments.length).toString();
    _items = len + " Items";
    //your feedback document count
    final result_your = await Firestore.instance.collection('Feedback').where("userEmail", isEqualTo: "${user?.email}").getDocuments();
    final List<DocumentSnapshot> documents_your = result_your.documents;
    print(documents_your.length);
    var len_your = (documents_your.length).toString();
    _items_your = len_your + " Items";
    documents.forEach((data) {
      listItems.add(
          GestureDetector(
            onTap: (){
              _title = data["postTitle"];
              _content= data["postContent"];
              Firestore.instance.collection("Feedback")
                  .where("postTitle", isEqualTo: _title)
                  .where("postContent", isEqualTo: _content).getDocuments()
                  .then((event) {
                Firestore.instance
                    .collection("Feedback")
                    .document(event.documents[0].documentID)
                    .updateData({"views" : FieldValue.increment(1),}).then((value){});
              });
              Navigator.push(context, MaterialPageRoute(builder: (context) => viewPost()));
            },
            child: Container(
              height: 150,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0)), color: Colors.black38, boxShadow: [
                BoxShadow(color: Colors.black12.withAlpha(100), blurRadius: 10.0),
              ]),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 300,
                          child: Text(
                            data["postTitle"],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          data["userEmail"],
                          style: const TextStyle(fontSize: 15, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Views: " + data["views"].toString(),
                          style: const TextStyle(fontSize: 15, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Likes: " + data["likes"].toString(),
                          style: const TextStyle(fontSize: 15, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                    /*Image.asset(
                  "assets/images/${post["image"]}",
                  height: double.infinity,
                )*/
                  ],
                ),
              ),),
          )
      );
    });
    setState(() {
      itemsData = listItems;
    });
  }

  @override
  void initState() {
    super.initState();
    getPostsData();
    controller.addListener(() {

      double value = controller.offset/119;

      setState(() {
        topContainer = value;
        closeTopContainer = controller.offset > 50;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height*0.30;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFF4C4B4B),
        body: Container(
          height: size.height,
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 50,
              ),
              Text(
                "Feedback",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 45),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              ),
              const SizedBox(
                height: 10,
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: closeTopContainer?0:1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: size.width,
                  alignment: Alignment.topCenter,
                  height: closeTopContainer?0:categoryHeight,
                  child: categoriesScroller,
                ),
              ),
              Expanded(
                  child: ListView.builder(
                      controller: controller,
                      itemCount: itemsData.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        double scale = 1.0;
                        if (topContainer > 0.7) {
                          scale = index + 0.5 - topContainer;
                          if (scale < 0) {
                            scale = 0;
                          } else if (scale > 1) {
                            scale = 1;
                          }
                        }
                        return Opacity(
                          opacity: scale,
                          child: Transform(
                            transform:  Matrix4.identity()..scale(scale,scale),
                            alignment: Alignment.bottomCenter,
                            child: Align(
                              heightFactor: 0.7,
                              alignment: Alignment.topCenter,
                              child: itemsData[index],
                            ),
                          ),
                        );
                      })),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => feedbackUpload()
                )
            );
          },
          child: Icon(Icons.send),
          backgroundColor: Colors.red,
          tooltip: "Send Feedback",
        ),
      ),
    );
  }
}

class CategoriesScroller extends StatelessWidget {
  const CategoriesScroller();

  @override
  Widget build(BuildContext context) {
    final double categoryHeight = MediaQuery.of(context).size.height * 0.30 - 50;
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: FittedBox(
          fit: BoxFit.fill,
          alignment: Alignment.topCenter,
          child: Row(
            children: <Widget>[
              new GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => popularFeedback()),
                  );
                },
                child: Container(
                  width: 150,
                  margin: EdgeInsets.only(right: 20),
                  height: categoryHeight,
                  decoration: BoxDecoration(
                    color: Colors.indigoAccent,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withAlpha(100),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Popular Feedback",
                          style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "$_items",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              new GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => yourFeedback()),
                  );
                },
                child: Container(
                  width: 150,
                  margin: EdgeInsets.only(right: 20),
                  height: categoryHeight,
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withAlpha(100),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Your \nFeedback",
                          style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "$_items_your",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}