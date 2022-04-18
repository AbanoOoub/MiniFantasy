import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:minifantasy/Screens/Home.dart';
import 'package:minifantasy/models/player.dart';

import '../widgets.dart';

class BuyNewPLayers extends StatefulWidget {
  const BuyNewPLayers({Key? key, required this.selectedSellPLayers})
      : super(key: key);
  final List<Player> selectedSellPLayers;

  @override
  _BuyNewPLayersState createState() => _BuyNewPLayersState();
}

class _BuyNewPLayersState extends State<BuyNewPLayers> {
  double money = 0;
  int playingNum = 0;
  DatabaseReference _dbRef = FirebaseDatabase.instance.reference();
  List<Player> players = [];

  List<Player> ownedPlayers = [];
  List<Player> selectedNewPlayers = [];
  bool isSellGK = false;
  bool isSelectGK = false;
  bool isValidTeam = false;
  User? user = FirebaseAuth.instance.currentUser;

  void _initMoney() async {
    double val = 0;

    CollectionReference userRef =
        FirebaseFirestore.instance.collection('users');
    var userRes = await userRef.get();
    userRes.docs.forEach((element) {
      if (element.id == user!.uid) {
        val += double.parse(element['bank'].toString());
      }
    });

    widget.selectedSellPLayers.forEach((element) {
      val += element.price;
    });

    setState(() {
      money = val;
    });
  }

  void _checkSellGK() {
    widget.selectedSellPLayers.forEach((element) {
      if (element.position == 'GK')
        setState(() {
          isSellGK = true;
        });
    });
  }

  void _getPlayersToList() {
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

  void _getOwnedPlayers() async {
    CollectionReference userRef =
        FirebaseFirestore.instance.collection('users');

    var userRes = await userRef.get();
    userRes.docs.forEach((element) async {
      if (element.id == user!.uid) {
        CollectionReference teamRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('Team');

        var res = await teamRef.get();
        res.docs.forEach((element) {
          String name = element['playerName'];
          int price = element['price'];
          String img = element['img'];
          String position = element['position'];
          int score = element['playerScore'];
          bool captain = element['isCaptain'];
          bool isPlaying = element['playing'];
          setState(() {
            ownedPlayers.add(Player(
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
      }
    });
  }

  void _saveExtraMoneyToBank() async {
    CollectionReference userRef =
        FirebaseFirestore.instance.collection('users');
    var userRes = await userRef.get();
    userRes.docs.forEach((element) async {
      if (element.id == user!.uid) {
        await userRef.doc(element.id).update({
          'bank': money,
        });
      }
    });
  }

  void _saveNewPlayers(List<Player> selectedNewPlayers) {
    CollectionReference userRef =
        FirebaseFirestore.instance.collection('users');

    playingNum = 0;

    ownedPlayers.forEach((element) {
      if (element.isPlaying) {
        playingNum++;
      }
    });

    selectedNewPlayers.forEach((element) {
      if (playingNum < 4) {
        playingNum++;
        userRef
            .doc(user!.uid)
            .collection('Team')
            .add({
              'playerName': element.name,
              'position': element.position,
              'playerScore': element.score,
              'img': element.img,
              'price': element.price,
              'isCaptain': element.captain,
              'playing': true,
            })
            .then((value) => print("Player Added"))
            .catchError((error) => print("Failed to add player: $error"));
      } else {
        userRef
            .doc(user!.uid)
            .collection('Team')
            .add({
              'playerName': element.name,
              'position': element.position,
              'playerScore': element.score,
              'img': element.img,
              'price': element.price,
              'isCaptain': element.captain,
              'playing': false,
            })
            .then((value) => print("Player Added"))
            .catchError((error) => print("Failed to add player: $error"));
      }
    });
  }

  void _checkValidTeam(List<Player> owned) async {
    int teamNum = 0;
    bool hasGK = false;
    bool newPlayers = true;

    owned.forEach((element) {
      if (element.position == "GK") {
        teamNum++;
        hasGK = true;
      } else {
        teamNum++;
      }
    });

    owned.forEach((element) {
      selectedNewPlayers.forEach((ele) {
        if (ele.name == element.name) {
          newPlayers = false;
        }
      });
    });
    selectedNewPlayers.forEach((element) {
      if (element.position == "GK") {
        teamNum++;
        hasGK = true;
      } else {
        teamNum++;
      }
    });

    if (teamNum == 5 && hasGK && newPlayers) {
      setState(() {
        isValidTeam = true;
      });
    } else {
      setState(() {
        isValidTeam = false;
      });
    }
    print("teamNum= $teamNum");
    print("hasGK= $hasGK");
    print("newPlayers= $newPlayers");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initMoney();
    _checkSellGK();
    _getPlayersToList();
    _getOwnedPlayers();
  }

  @override
  Widget build(BuildContext context) {
    bool shouldPop = false;
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Fluttertoast.showToast(msg: 'You should buy new players');
        return shouldPop;
      },
      child: Stack(
        children: [
          Image.asset(
            "images/bg/bg3.png",
            height: size.height,
            width: size.width,
            fit: BoxFit.cover,
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Color(0xff6E9449),
                          content: Container(
                            height: size.width / 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                defaultText(
                                    '- If you sell a reserve player then you will buy reserve player',
                                    14),
                                defaultText(
                                    '- If you sell a playing player/s then you will buy playing player/s',
                                    14),
                                defaultText(
                                    '- If you sell both then last player that you bought will be a reserve player',
                                    14),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            new TextButton(
                              child: defaultText('Got it', 14),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                )
              ],
              automaticallyImplyLeading: false,
              title: defaultText('Buy New Players', 25),
              backgroundColor: Color(0xff6E9449),
            ),
            body: Center(
              child: Column(
                children: [
                  SizedBox(height: size.width / 10),
                  defaultText('Choose great Team to win !', 18),
                  SizedBox(height: size.width / 25),
                  defaultText('\$$money M', 30),
                  SizedBox(height: size.width / 20),
                  Expanded(
                    flex: 2,
                    child: ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (BuildContext context, int index) {
                        return defaultPlayerPrice(
                            height: size.width / 3,
                            img: players[index].img,
                            playerName: players[index].name,
                            playerPrice: players[index].price,
                            playerPosition: players[index].position,
                            onPressed: () {
                              setState(() {
                                if (money >= players[index].price &&
                                    !players[index].isSelected) {
                                  // select
                                  if (players[index].position == "GK") {
                                    if (isSellGK) {
                                      isSelectGK = true;
                                      selectedNewPlayers.insert(
                                          0, players[index]);
                                      players[index].isSelected =
                                          !players[index].isSelected;
                                      money -= players[index].price;
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: 'You already bought a GK');
                                    }
                                  } else {
                                    selectedNewPlayers.add(players[index]);
                                    players[index].isSelected =
                                        !players[index].isSelected;
                                    money -= players[index].price;
                                  }
                                } else if (players[index].isSelected) {
                                  //unselect
                                  if (players[index].position == "GK") {
                                    isSelectGK = false;
                                  }
                                  players[index].isSelected =
                                      !players[index].isSelected;
                                  money += players[index].price;
                                  selectedNewPlayers.remove(players[index]);
                                } else {
                                  Fluttertoast.showToast(
                                      msg: 'You don\'t have enough money');
                                }
                              });
                            },
                            icon: players[index].isSelected
                                ? Icon(Icons.check_circle, color: Colors.white)
                                : Icon(Icons.check_circle_outline,
                                    color: Colors.white));
                      },
                    ),
                  ),
                  SizedBox(height: size.width / 20),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: defaultBottom(
                        width: size.width / 2,
                        text: 'Finish',
                        onPressed: () {
                          print("================================");
                          setState(() {
                            shouldPop = !shouldPop;
                          });

                          _checkValidTeam(ownedPlayers);
                          if (isValidTeam) {
                            print("============valid===============");
                            _saveNewPlayers(selectedNewPlayers);
                            _saveExtraMoneyToBank();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()));
                          } else {
                            print("============NotValid===============");
                            Fluttertoast.showToast(
                                msg:
                                    'Your team must contains 4 different players and a GK');
                          }
                          print(selectedNewPlayers.length);
                        }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
