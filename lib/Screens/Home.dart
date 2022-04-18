import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minifantasy/Screens/playersinteam.dart';
import 'package:minifantasy/Screens/signin.dart';
import 'package:minifantasy/Screens/standings.dart';
import 'package:minifantasy/Screens/teamplay.dart';

import '../widgets.dart';
import 'admincode.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIdx = 0;

  List<Widget> screens = [
    StandingsPage(),
    TeamPlayPage(),
    PlayersInTeamPage(),
    AdminCodePage(),
  ];

  List<Widget> titles = [
    defaultText('Standings', 25),
    defaultText('Team View', 25),
    defaultText('Your Players', 25),
    defaultText('Admin', 25),
  ];

  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: titles[currentIdx],
        backgroundColor: Color(0xff6E9449),
        actions: [
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SignInPage()));
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Image.asset(
            "images/bg/bg4.png",
            height: size.height,
            width: size.width,
            fit: BoxFit.cover,
          ),
          screens[currentIdx],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Color(0xff1B3105),
        fixedColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xff6E9449),
        currentIndex: currentIdx,
        onTap: (index) {
          setState(() {
            currentIdx = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.align_vertical_bottom_outlined,
                  color: Colors.white),
              label: 'Standings'),
          BottomNavigationBarItem(
              icon: Icon(Icons.groups, color: Colors.white), label: 'Team'),
          BottomNavigationBarItem(
              icon: Icon(Icons.change_circle_outlined, color: Colors.white),
              label: 'Players'),
          BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined,
                  color: Colors.white),
              label: 'Admin'),
        ],
      ),
    );
  }
}
