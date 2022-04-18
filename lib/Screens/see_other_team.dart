import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minifantasy/models/player.dart';
import 'package:minifantasy/widgets.dart';

class ShowOtherTeamPage extends StatefulWidget {
  const ShowOtherTeamPage({Key? key, required this.teamName}) : super(key: key);

  final String teamName;

  @override
  _ShowOtherTeamPageState createState() => _ShowOtherTeamPageState();
}

class _ShowOtherTeamPageState extends State<ShowOtherTeamPage> {
  List<Player> playingTeam = [];
  String? userID;

  void _getPlayers() async {
    CollectionReference userRef =
        FirebaseFirestore.instance.collection("users");

    var userRes = await userRef.get();
    userRes.docs.forEach((element) {
      if (widget.teamName == element['teamName']) {
        userID = element.id;
      }
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
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
          if (position == "GK") {
            playingTeam.insert(
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
            if (isPlaying) {
              playingTeam.add(Player(
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
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPlayers();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: defaultText(widget.teamName, 25),
        backgroundColor: Color(0xff6E9449),
      ),
      body: Stack(
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
                                onTap: () {}),
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
                                onTap: () {}),
                            SizedBox(width: size.width / 4),
                            playerCard(
                                playerName: playingTeam[2].name,
                                playerImg: playingTeam[2].img,
                                captain: playingTeam[2].captain,
                                score: playingTeam[2].score,
                                width: size.width / 3,
                                height: size.width / 3,
                                onTap: () {}),
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
                                onTap: () {}),
                          ],
                        )),
                  ],
                )
              : Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
