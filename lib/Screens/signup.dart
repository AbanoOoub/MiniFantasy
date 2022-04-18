import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../widgets.dart';
import 'buyplayers.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _teamNameController = new TextEditingController();
  final _emailController = new TextEditingController();
  final _passwordController = new TextEditingController();
  final _confirmPasswordController = new TextEditingController();

  CollectionReference userRef = FirebaseFirestore.instance.collection('users');

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
          'bank': money,
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Image.asset(
          "images/bg/bg2.png",
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
                    defaultText('Sign up to start your journey', 18),
                    SizedBox(height: size.height / 25),
                    defaultFormField(
                      context: context,
                      controller: _teamNameController,
                      type: TextInputType.text,
                      prefix: Icons.groups,
                      label: 'Team Name',
                    ),
                    SizedBox(height: size.height / 50),
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
                        controller: _passwordController,
                        type: TextInputType.text,
                        label: 'Password',
                        prefix: Icons.lock),
                    SizedBox(height: size.height / 50),
                    defaultFormField(
                        context: context,
                        isPassword: true,
                        controller: _confirmPasswordController,
                        type: TextInputType.text,
                        label: 'Confirm Password',
                        prefix: Icons.password),
                    SizedBox(height: size.height / 20),
                    defaultBottom(
                        width: size.width - 100,
                        text: 'Sign Up',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (_emailController.text.contains('@')) {
                              if (_confirmPasswordController.text ==
                                  _passwordController.text) {
                                try {
                                  UserCredential userCredential =
                                      await FirebaseAuth
                                          .instance
                                          .createUserWithEmailAndPassword(
                                              email: _emailController.text,
                                              password:
                                                  _passwordController.text);

                                  if (userCredential.user != null) {
                                    _addUser(
                                      teamName: _teamNameController.text,
                                      totalScore: 0,
                                      isSwitched: false,
                                      money: 0,
                                    );

                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BuyPLayersPage()));
                                  }
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'weak-password') {
                                    Fluttertoast.showToast(
                                        msg: "Please write strong password!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        fontSize: 14.0);
                                  } else if (e.code == 'email-already-in-use') {
                                    Fluttertoast.showToast(
                                        msg:
                                            "The account already exists for that email!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        fontSize: 14.0);
                                  }
                                } catch (e) {
                                  print(e);
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Password Must Matches!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    fontSize: 14.0);
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Enter Correct Mail!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  fontSize: 14.0);
                            }
                          }
                        }),
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
