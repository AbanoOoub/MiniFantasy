import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:minifantasy/models/player.dart';

import '../widgets.dart';

class TeamPlayPage extends StatefulWidget {
  const TeamPlayPage({Key? key}) : super(key: key);

  @override
  _TeamPlayPageState createState() => _TeamPlayPageState();
}

class _TeamPlayPageState extends State<TeamPlayPage> {
  List<Player> playingTeam = [];

  User? user = FirebaseAuth.instance.currentUser;

  bool isValidToChange = false;

  void _getPlayers() async {
    Player? notPlaying;
    List<Player> playingPlayers = [];

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
        if (!isPlaying) {
          notPlaying = Player(
              name: name,
              price: price,
              position: position,
              img: img,
              score: score,
              isSelected: false,
              captain: captain,
              isPlaying: isPlaying);
        } else {
          if (position == "GK") {
            playingPlayers.insert(
                0,
                Player(
                    name: name,
                    price: price,
                    position: position,
                    img: img,
                    score: score,
                    isSelected: false,
                    captain: captain,
                    isPlaying: isPlaying));
          } else {
            playingPlayers.add(Player(
                name: name,
                price: price,
                position: position,
                img: img,
                score: score,
                isSelected: false,
                captain: captain,
                isPlaying: isPlaying));
          }
        }
      });
    });
    setState(() {
      playingTeam.addAll(playingPlayers);
      playingTeam.add(notPlaying!);
    });
  }

  bool _checkCaptainIsExist() {
    for (int i = 0; i < playingTeam.length; i++) {
      if (playingTeam[i].captain == true) {
        return true;
      }
    }
    return false;
  }

  void _isValidChangingCap() {
    DateTime date = DateTime.now();
    String dateFormat = DateFormat('EEEE').format(date);
    if (dateFormat != "Wednesday") {
      isValidToChange = true;
    }
  }

  void addCaptain(Player player) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("Team")
        .get()
        .then((res) {
      res.docs.forEach((result) {
        if (player.name == result['playerName'].toString()) {
          FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .collection("Team")
              .doc(result.id)
              .update({"isCaptain": true});
        } else {
          FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .collection("Team")
              .doc(result.id)
              .update({"isCaptain": false});
        }
      });
    });
  }

  void _isSelectedCaptain() async {
    bool isSelected = false;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('Team')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        bool captain = element.data()['isCaptain'];
        if (captain) {
          isSelected = true;
        }
      });
    });

    if (!isSelected) {
      Fluttertoast.showToast(msg: "Tap on player to select a Captain");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPlayers();
    _isValidChangingCap();
    _isSelectedCaptain();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Image.asset(
          "images/stadium.png",
          height: size.height,
          width: size.width,
          fit: BoxFit.cover,
        ),
        playingTeam.length != 0
            ? Column(
                children: [
                  Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          playerCard(
                              playerName: playingTeam[0].name,
                              playerImg: playingTeam[0].img,
                              captain: playingTeam[0].captain,
                              score: playingTeam[0].score,
                              width: size.width / 3,
                              height: size.width / 3,
                              onTap: () {
                                if (_checkCaptainIsExist()) {
                                  if (!playingTeam[0].captain) {
                                    if (isValidToChange) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: Color(0xff6E9449),
                                            content: defaultText(
                                                '${playingTeam[0].name} will be a Captain!',
                                                18),
                                            actions: <Widget>[
                                              new TextButton(
                                                child: defaultText('Yes', 14),
                                                onPressed: () {
                                                  Navigator.of(context).pop();

                                                  setState(() {
                                                    playingTeam[0].captain =
                                                        !playingTeam[0].captain;
                                                    playingTeam[1].captain =
                                                        false;
                                                    playingTeam[2].captain =
                                                        false;
                                                    playingTeam[3].captain =
                                                        false;

                                                    addCaptain(playingTeam[0]);
                                                  });
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      Fluttertoast.showToast(
                                          msg:
                                              'You can\'t change captain right now');
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            '${playingTeam[0].name} is already a captain');
                                  }
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Color(0xff6E9449),
                                        content: defaultText(
                                            '${playingTeam[0].name} will be a Captain!',
                                            18),
                                        actions: <Widget>[
                                          new TextButton(
                                            child: defaultText('Yes', 14),
                                            onPressed: () {
                                              Navigator.of(context).pop();

                                              setState(() {
                                                playingTeam[0].captain =
                                                    !playingTeam[0].captain;
                                                playingTeam[1].captain = false;
                                                playingTeam[2].captain = false;
                                                playingTeam[3].captain = false;

                                                addCaptain(playingTeam[0]);
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              }),
                        ],
                      )),
                  Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          playerCard(
                              playerName: playingTeam[1].name,
                              playerImg: playingTeam[1].img,
                              score: playingTeam[1].score,
                              captain: playingTeam[1].captain,
                              width: size.width / 3,
                              height: size.width / 3,
                              onTap: () {
                                if (_checkCaptainIsExist()) {
                                  if (!playingTeam[1].captain) {
                                    if (isValidToChange) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: Color(0xff6E9449),
                                            content: defaultText(
                                                '${playingTeam[1].name} will be a Captain!',
                                                18),
                                            actions: <Widget>[
                                              new TextButton(
                                                child: defaultText('Yes', 14),
                                                onPressed: () {
                                                  Navigator.of(context).pop();

                                                  setState(() {
                                                    playingTeam[1].captain =
                                                        !playingTeam[1].captain;

                                                    playingTeam[0].captain =
                                                        false;
                                                    playingTeam[2].captain =
                                                        false;
                                                    playingTeam[3].captain =
                                                        false;

                                                    addCaptain(playingTeam[1]);
                                                  });
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      Fluttertoast.showToast(
                                          msg:
                                              'You can\'t change captain right now');
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            '${playingTeam[1].name} is already a captain');
                                  }
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Color(0xff6E9449),
                                        content: defaultText(
                                            '${playingTeam[1].name} will be a Captain!',
                                            18),
                                        actions: <Widget>[
                                          new TextButton(
                                            child: defaultText('Yes', 14),
                                            onPressed: () {
                                              Navigator.of(context).pop();

                                              setState(() {
                                                playingTeam[1].captain =
                                                    !playingTeam[1].captain;

                                                playingTeam[0].captain = false;
                                                playingTeam[2].captain = false;
                                                playingTeam[3].captain = false;

                                                addCaptain(playingTeam[1]);
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              }),
                          SizedBox(width: size.width / 4),
                          playerCard(
                              playerName: playingTeam[2].name,
                              playerImg: playingTeam[2].img,
                              captain: playingTeam[2].captain,
                              score: playingTeam[2].score,
                              width: size.width / 3,
                              height: size.width / 3,
                              onTap: () {
                                if (_checkCaptainIsExist()) {
                                  if (!playingTeam[2].captain) {
                                    if (isValidToChange) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: Color(0xff6E9449),
                                            content: defaultText(
                                                '${playingTeam[2].name} will be a Captain!',
                                                18),
                                            actions: <Widget>[
                                              new TextButton(
                                                child: defaultText('Yes', 14),
                                                onPressed: () {
                                                  Navigator.of(context).pop();

                                                  setState(() {
                                                    playingTeam[2].captain =
                                                        !playingTeam[2].captain;

                                                    playingTeam[0].captain =
                                                        false;
                                                    playingTeam[1].captain =
                                                        false;
                                                    playingTeam[3].captain =
                                                        false;

                                                    addCaptain(playingTeam[2]);
                                                  });
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      Fluttertoast.showToast(
                                          msg:
                                              'You can\'t change captain right now');
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            '${playingTeam[2].name} is already a captain');
                                  }
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Color(0xff6E9449),
                                        content: defaultText(
                                            '${playingTeam[2].name} will be a Captain!',
                                            18),
                                        actions: <Widget>[
                                          new TextButton(
                                            child: defaultText('Yes', 14),
                                            onPressed: () {
                                              Navigator.of(context).pop();

                                              setState(() {
                                                playingTeam[2].captain =
                                                    !playingTeam[2].captain;

                                                playingTeam[0].captain = false;
                                                playingTeam[1].captain = false;
                                                playingTeam[3].captain = false;

                                                addCaptain(playingTeam[2]);
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              }),
                        ],
                      )),
                  Expanded(
                      flex: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          playerCard(
                              playerName: playingTeam[3].name,
                              playerImg: playingTeam[3].img,
                              captain: playingTeam[3].captain,
                              score: playingTeam[3].score,
                              width: size.width / 3,
                              height: size.width / 3,
                              onTap: () {
                                if (_checkCaptainIsExist()) {
                                  if (!playingTeam[3].captain) {
                                    if (isValidToChange) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: Color(0xff6E9449),
                                            content: defaultText(
                                                '${playingTeam[3].name} will be a Captain!',
                                                18),
                                            actions: <Widget>[
                                              new TextButton(
                                                child: defaultText('Yes', 14),
                                                onPressed: () {
                                                  Navigator.of(context).pop();

                                                  setState(() {
                                                    playingTeam[3].captain =
                                                        !playingTeam[3].captain;

                                                    playingTeam[0].captain =
                                                        false;
                                                    playingTeam[1].captain =
                                                        false;
                                                    playingTeam[2].captain =
                                                        false;

                                                    addCaptain(playingTeam[3]);
                                                  });
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      Fluttertoast.showToast(
                                          msg:
                                              'You can\'t change captain right now');
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            '${playingTeam[3].name} already is a captain');
                                  }
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Color(0xff6E9449),
                                        content: defaultText(
                                            '${playingTeam[3].name} will be a Captain!',
                                            18),
                                        actions: <Widget>[
                                          new TextButton(
                                            child: defaultText('Yes', 14),
                                            onPressed: () {
                                              Navigator.of(context).pop();

                                              setState(() {
                                                playingTeam[3].captain =
                                                    !playingTeam[3].captain;

                                                playingTeam[0].captain = false;
                                                playingTeam[1].captain = false;
                                                playingTeam[2].captain = false;

                                                addCaptain(playingTeam[3]);
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              }),
                        ],
                      )),
                ],
              )
            : Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
