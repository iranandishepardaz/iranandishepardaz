//import 'package:ap_me/LoginPage.dart';
//import 'package:ap_me/MainPage.dart';
import 'package:ap_me/AppDatabase.dart';
import 'package:ap_me/AppParameters.dart';
import 'package:ap_me/AppSettings.dart';
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
//this can be done on the splash screen(while waiting)
  await AppDatabase.initDatabase();
  try {
    await AppSettings.readCurrentSetings();
  } catch (e) {
    AppSettings.resetToDefaultSetings();
  }
  runApp(new ApMesApplication());
}

//  void main() => runApp(new ApMesApplication());
/*
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
*/

class ApMesApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _resetTimer('down'),
      onPointerMove: (_) => _resetTimer('move'),
      onPointerUp: (_) => _resetTimer('up'),
      onPointerSignal: (_) => _resetTimer('Signal'),
      child: MaterialApp(
        theme: new ThemeData(
            primarySwatch: Colors.grey, scaffoldBackgroundColor: Colors.grey),
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}

void _resetTimer(String userAction) {
  print(userAction);
  if (userAction == "down") {
    AppParameters.lastUserActivity = DateTime.now();
  }
}
