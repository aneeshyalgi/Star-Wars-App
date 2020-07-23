import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'social_code/social.dart' as social;
import 'package:app/memes_page/memes_page.dart' as memes;
import 'feedback_code/feedback_code_page.dart' as feedback;
import 'settings_code/settings_code_page.dart' as settings;

class main_app extends StatefulWidget {
  @override
  _main_appState createState() => _main_appState();
}

class _main_appState extends State<main_app> {

  int _currentIndex = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            new social.social(),
            new memes.memes_page(),
            new feedback.feedback(),
            new settings.settings(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
              title: Text('Social', style: TextStyle(fontSize: 17),),
              icon: Icon(Icons.people,),
              activeColor: Colors.red
          ),
          BottomNavyBarItem(
              title: Text('Memes', style: TextStyle(fontSize: 17),),
              icon: Icon(Icons.tag_faces),
              activeColor: Colors.red
          ),
          BottomNavyBarItem(
              title: Text('Feedback', style: TextStyle(fontSize: 17),),
              icon: Icon(Icons.feedback),
              activeColor: Colors.red
          ),
          BottomNavyBarItem(
              title: Text('Settings', style: TextStyle(fontSize: 17),),
              icon: Icon(Icons.settings),
              activeColor: Colors.red
          ),
        ],
      ),
    );
  }
}
