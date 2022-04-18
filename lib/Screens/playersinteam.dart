import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:minifantasy/Screens/buy-sell-players.dart';
import 'package:minifantasy/models/player.dart';
import 'package:minifantasy/widgets.dart';

class PlayersInTeamPage extends StatefulWidget {
  const PlayersInTeamPage({Key? key}) : super(key: key);

  @override
  _PlayersInTeamPageState createState() => _PlayersInTeamPageState();
}

class _PlayersInTeamPageState extends State<PlayersInTeamPage> {
  List<Player> players = [];
  List<Player> selectedPLayers = [];
  List currTeam = [];
  List currTeamIDs = [];
  User? user = FirebaseAuth.instance.currentUser;

  bool isValidToChange = false;

  void _getPlayers() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('Team')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        String name = element.data()['playerName'];
        int price = element.data()['price'];
        String img = element.data()['img'];
        String position = element.data()['position'];
        int score = element.data()['playerScore'];
        bool captain = element.data()['isCaptain'];
        bool isPlaying = element.data()['playing'];
        setState(() {
          players.add(Player(
              name: name,
              price: price,
              position: position,
              img: img,
              score: score,
              isSelected: false,
              captain: captain,
              isPlaying: isPlaying));
        });
      });
    });
  }

  void _updateTeam() async {
    int totalScore = 0;
    bool isSwitched = false;

    CollectionReference userRef =
        FirebaseFirestore.instance.collection('users');

    CollectionReference teamRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('Team');

    var userRes = await userRef.get();
    userRes.docs.forEach((element) {
      if (element.id == user!.uid) {
        isSwitched = element['isSwitched'];
        totalScore = element['totalScore'];
      }
    });

    var res = await teamRef.get();
    res.docs.forEach((element) {
      setState(() {
        currTeam.add(element.data());
        currTeamIDs.add(element.id);
      });
    });

    for (int i = 0; i < currTeam.length; i++) {
      bool isPlayerSelected = false;
      for (int j = 0; j < selectedPLayers.length; j++) {
        if (currTeam[i]['playerName'] == selectedPLayers[j].name) {
          isPlayerSelected = true;
          if (currTeam[i]['playing'] == false) {
            //update in
            await teamRef.doc(currTeamIDs[i]).update({
              'playing': true,
            });
            if (!isSwitched) {
              await userRef.doc(user!.uid).update({
                'isSwitched': true,
              });
            } else {
              await userRef.doc(user!.uid).update({
                'totalScore': totalScore - 4,
              });
            }
          }
          break;
        }
      }
      if (!isPlayerSelected) {
        //update out
        teamRef.doc(currTeamIDs[i]).update({
          'playing': false,
          'isCaptain': false,
          'playerScore': 0,
        });
      }
    }
  }

  void isValidChangingPlayers() {
    DateTime date = DateTime.now();
    String dateFormat = DateFormat('EEEE').format(date);
    if (dateFormat != "Wednesday") {
      isValidToChange = true;
    }
  }

  void _removeSellPlayers() async {
    List usersList = [];

    CollectionReference userRef =
        FirebaseFirestore.instance.collection('users');

    var userRes = await userRef.get();
    userRes.docs.forEach((element) {
      usersList.add(element.id);
    });

    for (int i = 0; i < usersList.length; i++) {
      //users
      if (usersList[i] == user!.uid) {
        CollectionReference teamRef = FirebaseFirestore.instance
            .collection('users')
            .doc(usersList[i])
            .collection('Team');

        var res = await teamRef.get();
        res.docs.forEach((element) {
          for (int j = 0; j < selectedPLayers.length; j++) {
            if (selectedPLayers[j].name == element['playerName']) {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(usersList[i])
                  .collection('Team')
                  .doc(element.id)
                  .delete();
              break;
            }
          }
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPlayers();
    isValidChangingPlayers();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Image.asset(
          "images/bg/bg5.png",
          height: size.height,
          width: size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: players.length != 0
                      ? ListView.builder(
                          itemCount: players.length,
                          itemBuilder: (BuildContext context, int index) {
                            return defaultPlayerInTeam(
                                height: size.width / 3,
                                img: players[index].img,
                                playerName: players[index].name,
                                playerPosition: players[index].position,
                                onPressed: () {
                                  setState(() {
                                    players[index].isSelected =
                                        !players[index].isSelected;
                                    if (players[index].isSelected) {
                                      selectedPLayers.add(players[index]);
                                    } else if (!players[index].isSelected) {
                                      selectedPLayers.remove(players[index]);
                                    }
                                  });
                                },
                                icon: players[index].isSelected
                                    ? Icon(Icons.check_circle,
                                        color: Colors.white)
                                    : Icon(Icons.check_circle_outline,
                                        color: Colors.white));
                          },
                        )
                      : Center(child: CircularProgressIndicator()),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: isValidToChange
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            defaultBottom(
                                height: size.width / 9,
                                width: size.width / 2.5,
                                text: 'Change',
                                onPressed: () {
                                  bool validTeam = false;
                                  if (selectedPLayers.length == 4) {
                                    for (int i = 0;
                                        i < selectedPLayers.length;
                                        i++) {
                                      if (selectedPLayers[i].position == "GK") {
                                        validTeam = true;
                                        //update playing players
                                        _updateTeam();
                                        Fluttertoast.showToast(
                                            msg:
                                                "Your selection is added successfully",
                                            toastLength: Toast.LENGTH_SHORT,
                                            fontSize: 14.0);
                                        break;
                                      }
                                    }
                                    if (!validTeam) {
                                      Fluttertoast.showToast(
                                          msg: "You must choose GK!",
                                          toastLength: Toast.LENGTH_SHORT,
                                          fontSize: 14.0);
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "You must choose 4 players!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        fontSize: 14.0);
                                  }
                                }),
                            defaultBottom(
                                height: size.width / 9,
                                width: size.width / 2.5,
                                text: 'Sell',
                                onPressed: () {
                                  if (selectedPLayers.length >= 1) {
                                    // remove a player/s from Firebase
                                    _removeSellPlayers();
                                    Timer(Duration(seconds: 1), _run);
                                    //Navigator.pushReplacement(
                                    //    context,
                                    //    MaterialPageRoute(
                                    //        builder: (context) => BuyNewPLayers(
                                    //            selectedSellPLayers:
                                    //                selectedPLayers)));
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            "You must choose minimum 1 player!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        fontSize: 14.0);
                                  }
                                }),
                          ],
                        )
                      : Padding(
                          padding: EdgeInsets.all(8),
                          child: defaultText(
                              'You can\'t change or sell right now!', 18)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _run() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                BuyNewPLayers(selectedSellPLayers: selectedPLayers)));
  }
}
