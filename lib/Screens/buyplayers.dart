import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:minifantasy/Screens/Home.dart';
import 'package:minifantasy/models/player.dart';
import 'package:minifantasy/widgets.dart';

class BuyPLayersPage extends StatefulWidget {
  const BuyPLayersPage({Key? key}) : super(key: key);

  @override
  _BuyPLayersPageState createState() => _BuyPLayersPageState();
}

class _BuyPLayersPageState extends State<BuyPLayersPage> {
  double money = 100.0;
  bool isSelectGK = false;

  List<Player> players = [];

  List<Player> selectedPlayers = [];

  DatabaseReference _dbRef = FirebaseDatabase.instance.reference();

  void getPlayersToList() {
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPlayersToList();
  }

  CollectionReference userRef = FirebaseFirestore.instance.collection('users');
  User? user = FirebaseAuth.instance.currentUser;

  void addPlayerToTeam(
      {required String playerName,
      required String position,
      required int score,
      required String img,
      required int price,
      required bool isCaptain,
      required bool playing}) {
    userRef
        .doc(user!.uid)
        .collection('Team')
        .add({
          'playerName': playerName,
          'position': position,
          'playerScore': score,
          'img': img,
          'price': price,
          'isCaptain': isCaptain,
          'playing': playing,
        })
        .then((value) => print("Player Added"))
        .catchError((error) => print("Failed to add player: $error"));
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

  @override
  Widget build(BuildContext context) {
    bool shouldPop = false;
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Fluttertoast.showToast(msg: "You should buy your players");
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
              automaticallyImplyLeading: false,
              title: defaultText('Buy Players', 25),
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
                                  if (selectedPlayers.length == 3) {
                                    Fluttertoast.showToast(
                                        msg:
                                            'Next player will be a reserve player');
                                  }

                                  if (players[index].position == "GK") {
                                    if (isSelectGK == false) {
                                      isSelectGK = true;
                                      selectedPlayers.insert(0, players[index]);
                                      players[index].isSelected =
                                          !players[index].isSelected;
                                      money -= players[index].price;
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: 'You already bought a GK');
                                    }
                                  } else {
                                    selectedPlayers.add(players[index]);
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
                                  selectedPlayers.remove(players[index]);
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
                        text: 'Start',
                        onPressed: () {
                          bool validTeam = false;
                          if (selectedPlayers.length == 5) {
                            for (int i = 0; i < selectedPlayers.length; i++) {
                              if (selectedPlayers[i].position == "GK") {
                                validTeam = true;
                                break;
                              }
                            }
                            if (!validTeam) {
                              // not valid
                              Fluttertoast.showToast(
                                  msg: "You must choose GK!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  fontSize: 14.0);
                            } else {
                              //valid
                              //4 players must playing team
                              for (int i = 0; i < selectedPlayers.length; i++) {
                                if (i < 4) {
                                  selectedPlayers[i].isPlaying = true;
                                }
                                addPlayerToTeam(
                                  playerName: selectedPlayers[i].name,
                                  score: selectedPlayers[i].score,
                                  img: selectedPlayers[i].img,
                                  position: selectedPlayers[i].position,
                                  price: selectedPlayers[i].price,
                                  isCaptain: selectedPlayers[i].captain,
                                  playing: selectedPlayers[i].isPlaying,
                                );
                              }
                              _saveExtraMoneyToBank();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()));
                            }
                          } else {
                            Fluttertoast.showToast(
                                msg: "You must choose 5 players!",
                                toastLength: Toast.LENGTH_SHORT,
                                fontSize: 14.0);
                          }
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
