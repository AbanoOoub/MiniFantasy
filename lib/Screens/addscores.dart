import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:minifantasy/Screens/Home.dart';
import 'package:minifantasy/models/player.dart';
import 'package:minifantasy/widgets.dart';

class AddScoresPage extends StatefulWidget {
  const AddScoresPage({Key? key}) : super(key: key);

  @override
  _AddScoresPageState createState() => _AddScoresPageState();
}

class _AddScoresPageState extends State<AddScoresPage> {
  DatabaseReference _dbRef = FirebaseDatabase.instance.reference();
  int _gameWeek = 0;
  List<Player> players = [];

  void _updateGameWeeks() {
    final database = FirebaseDatabase.instance.reference();
    database.child('gameWeeks').once().then((snap) async {
      _gameWeek = snap.value['week'];
      await database.child('gameWeeks').update({"week": _gameWeek + 1});
    });
  }

  void _getPLayers() {
    final response = _dbRef.child('allplayers');
    response.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        setState(() {
          players.add(Player(
              name: values["name"],
              price: values["price"],
              position: values["position"],
              img: values["img"],
              score: values["score"],
              isSelected: false,
              captain: values["captain"],
              isPlaying: values["playing"]));
        });
      });
    });
  }

  void _updateScoresToPLayers() async {
    List usersList = [];

    CollectionReference userRef =
        FirebaseFirestore.instance.collection('users');

    var userRes = await userRef.get();
    userRes.docs.forEach((element) {
      usersList.add(element.id);
    });

    for (int i = 0; i < usersList.length; i++) {
      //users
      CollectionReference teamRef = FirebaseFirestore.instance
          .collection('users')
          .doc(usersList[i])
          .collection('Team');

      var res = await teamRef.get();
      res.docs.forEach((element) {
        for (int j = 0; j < players.length; j++) {
          int newScore = 0;
          if (element['playing'] == true &&
              players[j].name == element['playerName']) {
            if (element['isCaptain']) {
              newScore = element['playerScore'] + (players[j].score * 2);
            } else
              newScore = element['playerScore'] + players[j].score;

            FirebaseFirestore.instance
                .collection('users')
                .doc(usersList[i])
                .collection('Team')
                .doc(element.id)
                .update({
              'playerScore': newScore,
            });
            break;
          }
        }
      });
    }
  }

  void _updateSwitching() async {
    CollectionReference userRef =
        FirebaseFirestore.instance.collection('users');

    var userRes = await userRef.get();
    List usersList = [];
    userRes.docs.forEach((element) {
      usersList.add(element.id);
    });

    for (int i = 0; i < usersList.length; i++) {
      //users
      if (_gameWeek == 4 || _gameWeek == 8) {
        // delay by 1 ( i checked the gameWeeks before increasing)
        //every 4 weeks (gawla 3 months)
        await userRef.doc(usersList[i]).update({
          'isSwitched': false,
        });
      }
    }
  }

  void _updateUsersTotalScores() async {
    int totalScore = 0;
    Map<String, int> map = new Map();

    CollectionReference userRef =
        FirebaseFirestore.instance.collection("users");

    var userRes = await userRef.get();
    userRes.docs.forEach((element) {
      map[element.id] = int.parse(element['totalScore'].toString());
    });

    map.forEach((key, val) async {
      CollectionReference teamRef = FirebaseFirestore.instance
          .collection('users')
          .doc(key)
          .collection('Team');

      var res = await teamRef.get();
      int teamScore = 0;
      res.docs.forEach((element) {
        if (element['playing']) {
          for (int i = 0; i < players.length; i++) {
            if (element['playerName'] == players[i].name) {
              if (element['isCaptain'])
                teamScore += (players[i].score * 2);
              else
                teamScore += players[i].score;

              break;
            }
          }
        }
      });

      totalScore = val + teamScore;

      await userRef.doc(key).update({
        'totalScore': totalScore,
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPLayers();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    List<TextEditingController> _controllers = [
      new TextEditingController(),
      new TextEditingController(),
      new TextEditingController(),
      new TextEditingController(),
      new TextEditingController(),
      new TextEditingController(),
      new TextEditingController(),
      new TextEditingController(),
      new TextEditingController(),
      new TextEditingController(),
      new TextEditingController(),
      new TextEditingController(),
      new TextEditingController(),
      new TextEditingController(),
      new TextEditingController(),
      new TextEditingController()
    ];

    return Scaffold(
      backgroundColor: Color(0xff6E9449),
      appBar: AppBar(
        title: defaultText('Admin', 18),
        backgroundColor: Color(0xff6E9449),
        elevation: 5,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (BuildContext context, int index) {
                  return defaultPlayerAddScore(
                    context: context,
                    height: size.width / 3,
                    img: players[index].img,
                    playerName: players[index].name,
                    scoreController: _controllers[index],
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: defaultBottom(
                width: size.width / 2,
                text: 'Add',
                onPressed: () {
                  for (int i = 0; i < _controllers.length; i++) {
                    if (_controllers[i].text.isNotEmpty) {
                      int score = int.parse(_controllers[i].text.toString());
                      players[i].score = score;
                    } else {
                      players[i].score = 0;
                    }
                  }
                  _updateScoresToPLayers();
                  _updateGameWeeks();
                  _updateSwitching();
                  _updateUsersTotalScores();

                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomePage()));
                }),
          ),
        ],
      ),
    );
  }
}
