import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:minifantasy/Screens/addscores.dart';
import 'package:minifantasy/Screens/signin.dart';
import 'package:minifantasy/widgets.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

void _resetGameWeeks() {
  final database = FirebaseDatabase.instance.reference();
  database.child('gameWeeks').once().then((snap) async {
    await database.child('gameWeeks').update({"week": 1});
  });
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff6E9449),
      appBar: AppBar(
        title: defaultText('Admin', 18),
        backgroundColor: Color(0xff6E9449),
        elevation: 5,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: defaultBottom(
                width: size.width / 2,
                text: 'Add Scores',
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => AddScoresPage()));
                }),
          ),
          SizedBox(height: size.width / 5),
          Center(
            child: defaultBottom(
                width: size.width / 2,
                text: 'Reset',
                onPressed: () async {
                  CollectionReference userRef =
                      FirebaseFirestore.instance.collection("users");

                  var userRes = await userRef.get();
                  userRes.docs.forEach((element) async {
                    CollectionReference teamRef = FirebaseFirestore.instance
                        .collection("users")
                        .doc(element.id)
                        .collection('Team');

                    var teamRes = await teamRef.get();
                    for (int i = 0; i < teamRes.docs.length; i++) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(element.id)
                          .collection('Team')
                          .doc(teamRes.docs.elementAt(i).id)
                          .delete();
                    }
                    userRef.doc(element.id).delete();
                  });

                  _resetGameWeeks();
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SignInPage()));
                }),
          ),
        ],
      ),
    );
  }
}
