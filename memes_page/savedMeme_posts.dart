import 'package:flutter/material.dart';
const user_post_data = [
  {
    "image":"https://media.giphy.com/media/xUNd9E5s0m0MtX7yYo/giphy.gif",
  },
];
class saved_meme_posts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: memePage(),
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

  void getPostsData() {
    List<dynamic> responseList = user_post_data;
    List<Widget> listItems = [];
    responseList.forEach((post) {
      listItems.add(
          GestureDetector(
            onTap: (){print(post["image"]);},
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
                    Image.network(
                      "${post["image"]}",
                      height: 10000,
                      width: 300,
                      fit: BoxFit.fitWidth,
                      filterQuality: FilterQuality.high,
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
                "Liked Posts",
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