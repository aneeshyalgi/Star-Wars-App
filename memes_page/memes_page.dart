import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'popular_memes.dart';
import 'your_memes.dart';
import 'savedMeme_posts.dart';
import 'uploadMeme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

class memes_page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: memePage(),
    );
  }
}

String url;
String _items = "Loading...";
String _items_saved = "Loading...";
class viewImage extends StatefulWidget {
  @override
  _viewImageState createState() => _viewImageState();
}

class _viewImageState extends State<viewImage> {
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
              onPressed: () {
                Firestore.instance.collection("Memes")
                    .where("url", isEqualTo: url).getDocuments()
                    .then((event) {
                  Firestore.instance
                      .collection("Memes")
                      .document(event.documents[0].documentID)
                      .updateData({"likes" : FieldValue.increment(1),}).then((value){});
                });
              },
              tooltip: "Like",
            ),
            IconButton(
              icon: Icon(Icons.thumb_down, size: 30, color: Colors.red,),
              onPressed: () {
                Firestore.instance.collection("Memes")
                    .where("url", isEqualTo: url).getDocuments()
                    .then((event) {
                  Firestore.instance
                      .collection("Memes")
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
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(url),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 2,
          enableRotation: true,
          backgroundDecoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
          ),
          loadingChild: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class memePage extends StatefulWidget {
  @override
  memePageState createState() => memePageState();
}

class memePageState extends State<memePage> {
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
    final QuerySnapshot result = await Firestore.instance.collection('Memes').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    //popular meme document count
    final queryresult = await Firestore.instance.collection('Memes').where("views", isGreaterThan: 10).getDocuments();
    final List<DocumentSnapshot> querydocuments = queryresult.documents;
    print((querydocuments.length).toString());
    var len = (querydocuments.length).toString();
    _items = len + " Items";
    //your meme document count
    final result_your = await Firestore.instance.collection('Memes').where("userEmail", isEqualTo: "${user?.email}").getDocuments();
    final List<DocumentSnapshot> documents_your = result_your.documents;
    print(documents_your.length);
    var len_your = (documents_your.length).toString();
    _items_saved = len_your + " Items";
    documents.forEach((data) async{
      listItems.add(
          GestureDetector(
            onTap: (){
              url = data["url"];
              Firestore.instance.collection("Memes")
                  .where("url", isEqualTo: url).getDocuments()
                  .then((event) {
                Firestore.instance
                    .collection("Memes")
                    .document(event.documents[0].documentID)
                    .updateData({"views" : FieldValue.increment(1),}).then((value){});
              });
              Navigator.push(context, MaterialPageRoute(builder: (context) => viewImage()));
            },
            child: Container(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.1, vertical: 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        "${data["url"]}",
                        height: 10000,
                        width: 300,
                        fit: BoxFit.fitWidth,
                        filterQuality: FilterQuality.high,
                        loadingBuilder: (BuildContext context, Widget child,ImageChunkEvent loadingProgress){
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null ?
                              loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
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
                "Memes",
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
                        return itemsData[index];
                      })),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => uploadMeme()
                )
            );
          },
          child: Icon(Icons.cloud_upload),
          backgroundColor: Colors.red,
          tooltip: "Upload Meme",
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
                    MaterialPageRoute(builder: (context) => popular_memes_page()),
                  );
                },
                child: Container(
                  width: 150,
                  margin: EdgeInsets.only(right: 20),
                  height: categoryHeight,
                  decoration: BoxDecoration(
                      color: Colors.purple.shade600,
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
                          "Popular Memes",
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
                    MaterialPageRoute(builder: (context) => your_memes()),
                  );
                },
                child: Container(
                  width: 150,
                  margin: EdgeInsets.only(right: 20),
                  height: categoryHeight,
                  decoration: BoxDecoration(
                      color: Colors.green.shade600,
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
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Your Posts",
                            style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "$_items_saved",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              /*new GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => saved_meme_posts()),
                  );
                },
                child: Container(
                  width: 150,
                  margin: EdgeInsets.only(right: 20),
                  height: categoryHeight,
                  decoration: BoxDecoration(
                      color: Colors.deepPurple,
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
                          "Liked Posts",
                          style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold,),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "20 Items",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}