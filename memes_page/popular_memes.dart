import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';
import 'memes_page.dart';

class popular_memes_page extends StatelessWidget {
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
  ScrollController controller = ScrollController();
  bool closeTopContainer = false;
  double topContainer = 0;

  List<Widget> itemsData = [];

  void getPostsData() async{
    final result = await Firestore.instance.collection('Memes').where("views", isGreaterThan: 10).getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    List<Widget> listItems = [];
    documents.forEach((data) {
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
                    /*new Center(
                      child: Image.asset("assets/Darth_Vader.jpg"),
                    ),*/
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
                "Popular Memes",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 35),
              ),

              Expanded(
                  child: ListView.builder(
                      controller: controller,
                      itemCount: itemsData.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return itemsData[index];
                      }
                      )
              ),
            ],
          ),
        ),
      ),
    );
  }
}