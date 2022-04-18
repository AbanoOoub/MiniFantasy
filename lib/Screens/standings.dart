import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:minifantasy/Screens/see_other_team.dart';
import 'package:minifantasy/models/player.dart';

import '../widgets.dart';

class StandingsPage extends StatefulWidget {
  const StandingsPage({Key? key}) : super(key: key);

  @override
  _StandingsPageState createState() => _StandingsPageState();
}

class _StandingsPageState extends State<StandingsPage> {
  int _gameWeek = 0;
  DatabaseReference _database = FirebaseDatabase.instance.reference();
  List<Player> ownedPlayers = [];

  List<String> teamsName = [];
  List<int> teamsScore = [];
  List currTeam = [];
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _getGameWeek();
    _getUsersStandings();
  }

  void _getGameWeek() {
    _database.child('gameWeeks').once().then((snapshot) {
      setState(() {
        _gameWeek = snapshot.value['week'];
      });
    });
  }

  void _getUsersStandings() async {
    await FirebaseFirestore.instance
        .collection('users')
        .orderBy('totalScore', descending: true)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() {
          teamsName.add(element.data()['teamName']);
          teamsScore.add(element.data()['totalScore']);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Center(
      child: Column(
        children: [
          SizedBox(height: size.width / 20),
          defaultText('Do your best to win!', 20),
          SizedBox(height: size.width / 25),
          defaultText('GameWeek- ${_gameWeek != 16 ? _gameWeek : "last"}', 14),
          SizedBox(height: size.width / 20),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              height: size.height,
              child: teamsName.length != 0
                  ? ListView.builder(
                      itemCount: teamsName.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          child: defaultUserStanding(
                            height: size.width / 3,
                            teamName: teamsName[index],
                            userScore: teamsScore[index].toString(),
                            imgStanding: index < 3
                                ? 'images/standing/${index + 1}.png'
                                : 'images/standing/00.png',
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ShowOtherTeamPage(
                                        teamName: teamsName[index])));
                          },
                        );
                      })
                  : Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
