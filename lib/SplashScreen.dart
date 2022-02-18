import 'package:ap_me/AppDatabase.dart';
import 'package:ap_me/AppParameters.dart';
import 'package:ap_me/AppSettings.dart';
import 'package:ap_me/LoginPage.dart';
import 'package:ap_me/tempPage.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen() : super();

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 1), () {
      print("SplashScreen 1 seconds");
      initAndGo();
    });
    super.initState();
  }

  Orientation currentOrientation;

  void initAndGo() async {
    await AppDatabase.initDatabase();
    try {
      await AppSettings.readCurrentSetings();
    } catch (e) {
      AppSettings.resetToDefaultSetings();
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
    // context, MaterialPageRoute(builder: (context) => TempPage()));
  }

  @override
  Widget build(BuildContext context) {
    currentOrientation = MediaQuery.of(context).orientation;
    return Container(
        decoration: new BoxDecoration(color: AppSettings.formsBackgroundColor),
        child: FractionallySizedBox(
          widthFactor: currentOrientation == Orientation.portrait ? 0.7 : 0.4,
          // heightFactor: 0.7,
          child: Container(
              child: FittedBox(
                  child: Image.asset('assets/apmeLogo.png'),
                  fit: BoxFit.fitWidth
                  /* currentOrientation != Orientation.portrait
                ? BoxFit.fitWidth
                : BoxFit.fitHeight,*/
                  )),
        ));
  }
}
