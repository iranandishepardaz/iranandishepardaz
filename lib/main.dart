//import 'package:ap_me/LoginPage.dart';
//import 'package:ap_me/MainPage.dart';
import 'package:ap_me/Login.dart';
import 'package:ap_me/SplashScreen.dart';
import 'package:flutter/material.dart';
/*
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: true,
    home: Login(),
  ));
}
*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
//  await AppParameters.initialize();
  runApp(new ApMesApplication());
}

//  void main() => runApp(new ApMesApplication());

class ApMesApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
            primarySwatch: Colors.grey, scaffoldBackgroundColor: Colors.grey),
        home: SplashScreen());
  }
}
