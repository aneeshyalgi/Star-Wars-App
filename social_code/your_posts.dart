import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
const user_post_data = [];
class yourPosts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: your_posts(),
    );
  }
}

String _title;
String _content;

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

class your_posts extends StatefulWidget {
  @override
  your_postsState createState() => your_postsState();
}

class your_postsState extends State<your_posts> {
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
    final result = await Firestore.instance.collection('Social_Posts').where("userEmail", isEqualTo: "${user?.email}").getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    print(documents.length);
    List<Widget> listItems = [];
    documents.forEach((data) {
      listItems.add(
          GestureDetector(
            onTap: (){
              _title = data["postTitle"];
              _content= data["postContent"];
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
                "Your Posts",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 35),
              ),
              const SizedBox(
                height: 20,
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
      ),
    );
  }
}