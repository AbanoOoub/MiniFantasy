import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:minifantasy/Screens/buyplayers.dart';
import 'package:minifantasy/Screens/reset_password.dart';
import 'package:minifantasy/Screens/signup.dart';

import '../widgets.dart';
import 'Home.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passController = new TextEditingController();

  CollectionReference userRef = FirebaseFirestore.instance.collection("users");

  TextEditingController _teamNameController = new TextEditingController();

  void _addUser(
      {required String teamName,
      required int totalScore,
      required bool isSwitched,
      required int money}) {
    User? user = FirebaseAuth.instance.currentUser;

    userRef
        .doc(user!.uid)
        .set({
          'teamName': teamName,
          'totalScore': totalScore,
          'isSwitched': isSwitched,
          'bank': 0,
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Stack(
      children: <Widget>[
        Image.asset(
          "images/bg/bg1.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset('images/logo.png'),
                    defaultText('Sign in to get started', 18),
                    SizedBox(height: size.height / 25),
                    defaultFormField(
                      context: context,
                      controller: _emailController,
                      type: TextInputType.emailAddress,
                      prefix: Icons.email,
                      label: 'Email',
                    ),
                    SizedBox(height: size.height / 50),
                    defaultFormField(
                        context: context,
                        isPassword: true,
                        controller: _passController,
                        type: TextInputType.text,
                        label: 'Password',
                        prefix: Icons.lock),
                    Padding(
                      padding: const EdgeInsets.only(right: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ResetPasswordPage()));
                              },
                              child: defaultText('Forget Password!', 14)),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height / 35),
                    defaultBottom(
                        width: size.width - 100,
                        text: 'Sign In',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              UserCredential userCredential = await FirebaseAuth
                                  .instance
                                  .signInWithEmailAndPassword(
                                      email: _emailController.text,
                                      password: _passController.text);

                              if (userCredential.user != null) {
                                bool found = false;
                                var userRes = await userRef.get();
                                if (userRes.size != 0) {
                                  userRes.docs.forEach((element) async {
                                    if (userCredential.user!.uid ==
                                        element.id) {
                                      found = true;
                                      CollectionReference teamRef =
                                          FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(userCredential.user!.uid)
                                              .collection('Team');
                                      var teamRes = await teamRef.get();

                                      if (teamRes.size != 0) {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomePage()));
                                      } else {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BuyPLayersPage()));
                                      }
                                    }
                                  });
                                  if (!found) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor: Color(0xff6E9449),
                                          content: defaultFormField(
                                              context: context,
                                              controller: _teamNameController,
                                              isPassword: false,
                                              type: TextInputType.text,
                                              label: 'TeamName',
                                              prefix: Icons.groups),
                                          actions: <Widget>[
                                            new TextButton(
                                              child: defaultText('Done', 14),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                _addUser(
                                                  teamName:
                                                      _teamNameController.text,
                                                  totalScore: 0,
                                                  isSwitched: false,
                                                  money: 0,
                                                );
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            BuyPLayersPage()));
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Color(0xff6E9449),
                                        content: defaultFormField(
                                            context: context,
                                            controller: _teamNameController,
                                            isPassword: false,
                                            type: TextInputType.text,
                                            label: 'TeamName',
                                            prefix: Icons.groups),
                                        actions: <Widget>[
                                          new TextButton(
                                            child: defaultText('Done', 14),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              _addUser(
                                                teamName:
                                                    _teamNameController.text,
                                                totalScore: 0,
                                                isSwitched: false,
                                                money: 0,
                                              );
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          BuyPLayersPage()));
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              }
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'user-not-found') {
                                Fluttertoast.showToast(
                                    msg: "No user found for that email!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    fontSize: 14.0);
                              } else if (e.code == 'wrong-password') {
                                Fluttertoast.showToast(
                                    msg:
                                        "Wrong password provided for that user!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    fontSize: 14.0);
                              }
                            }
                          }
                        }),
                    SizedBox(height: size.height / 10),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => SignUpPage()));
                        },
                        child: defaultText('Create an account!', 18)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
