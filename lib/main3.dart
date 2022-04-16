import 'package:ap_me/SplashScreen.dart';
import 'package:flutter/material.dart';

final Color darkBlue = Color.fromARGB(255, 18, 32, 47);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => print('down'), // best place to reset timer imo
      onPointerMove: (_) => print('move'),
      onPointerUp: (_) => print('up'),
      child: MaterialApp(
        theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: darkBlue),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: MyWidget(),
          ),
        ),
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SplashScreen()));
    return TextFormField(
      maxLength: 10,
      maxLengthEnforced: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Details',
      ),
    );
  }
}
