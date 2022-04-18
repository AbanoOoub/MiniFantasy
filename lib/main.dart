import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:minifantasy/Screens/Home.dart';
import 'package:minifantasy/widgets.dart';
import 'Screens/signin.dart';

bool isLogin = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    isLogin = true;
  } else {
    isLogin = false;
  }
  runApp(MiniFantasy());
}

class MiniFantasy extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: _fbApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return defaultText('You have something Wrong', 20);
          } else if (snapshot.hasData) {
            return isLogin ? HomePage() : Splash();
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AnimatedSplashScreen(
        duration: 3000,
        splash: Image.asset('images/splash_logo.png'),
        nextScreen: SignInPage(),
        splashTransition: SplashTransition.scaleTransition,
        splashIconSize: size.width > 350 ? 350 : 200,
        backgroundColor: Color(0xff6E9449));
  }
}
