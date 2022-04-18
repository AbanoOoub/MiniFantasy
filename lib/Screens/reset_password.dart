import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:minifantasy/Screens/signin.dart';
import 'package:minifantasy/widgets.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _emailController = new TextEditingController();
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff6E9449),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              defaultFormField(
                  context: context,
                  controller: _emailController,
                  type: TextInputType.emailAddress,
                  label: 'Enter your mail',
                  prefix: Icons.email),
              SizedBox(height: 20),
              defaultBottom(
                  width: size.width / 2,
                  text: 'Reset Password',
                  onPressed: () async {
                    if (_emailController.text.isEmpty ||
                        !_emailController.text.contains('@')) {
                      Fluttertoast.showToast(
                          msg: 'Enter Your Correct Email First');
                    } else {
                      try {
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(
                                email: _emailController.text)
                            .then(
                              (value) => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignInPage())),
                            );
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          Fluttertoast.showToast(
                              msg: "No user found for that email!",
                              toastLength: Toast.LENGTH_SHORT,
                              fontSize: 14.0);
                        }
                      }
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
