//import 'package:ap_me/LoginPage.dart';
//import 'package:ap_me/MainPage.dart';
import 'package:flutter/material.dart';

import 'LoginPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(new ApMesApplication());
}

//  void main() => runApp(new ApMesApplication());

class ApMesApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(primarySwatch: Colors.lightGreen),
        home: LoginPage());
  }
}
