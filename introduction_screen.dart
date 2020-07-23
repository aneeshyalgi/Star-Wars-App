import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'login_page.dart';


class Introduction_screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Introduction screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      home: OnBoardingPage(),
    );
  }
}

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LoginScreen1()),
    );
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset('assets/$assetName.png', width: 300.0),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Color(0xFF4C4B4B),
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "",
          bodyWidget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Swipe to the ", style: bodyStyle),
              Icon(Icons.arrow_forward),
              Text(" to continue", style: bodyStyle),
            ],
          ),
          image: _buildImage('StarWarsLOGO'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Share Your Opinion",
          body:
          "Post your thoughts about Star Wars.",
          image: _buildImage('Darth_Vader2'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Share Memes",
          body:
          "You can share Star Wars memes to the world.",
          image: _buildImage('Darth_Maul'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "End of Introduction",
          body: "Click on the button below to continue.",
          footer: RaisedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => LoginScreen1(),
              )
              );
            },
            child: const Text(
              'Get Started',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            color: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          image: _buildImage('Kylo_Ren'),
          decoration: pageDecoration,
        ),
      ],
      onDone: (){
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => LoginScreen1(),
        )
        );
      },
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.red,
        activeColor: Colors.red,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text("This is the screen after Introduction")),
    );
  }
}
