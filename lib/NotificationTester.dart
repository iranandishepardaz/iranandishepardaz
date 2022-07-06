import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future _showNotification() async {
  var androidSpec = new AndroidNotificationDetails(
      'EDApps', 'FlutterTutorials', 'Learn And Run Quizzes',
      playSound: true, importance: Importance.max, priority: Priority.high);

  var iosSpec = new IOSNotificationDetails(presentSound: false);

  var platformChannelSpecifics =
      new NotificationDetails(android: androidSpec, iOS: iosSpec);

  await flutterLocalNotificationsPlugin.show(
    0,
    'ApMe',
    'شما پیام تازه دارید',
    platformChannelSpecifics,
    payload: 'No_Sound',
  );
}

class NotificationTester extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<NotificationTester> {
  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("Notification Clicked"),
          content: Text("Opened From Notification!"),
        );
      },
    );
  }

  @override
  initState() {
    super.initState();

    var androidSpec = new AndroidInitializationSettings('@mipmap/ic_launcher');

    var iosSpec = new IOSInitializationSettings();

    var initializationSettings =
        new InitializationSettings(android: androidSpec, iOS: iosSpec);

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Notification With Default Sound'),
          ),
          body: Center(
            child: ElevatedButton(
              onPressed: _showNotification,
              child: new Text('Notification Without Sound'),
            ),
          )),
    );
  }
}
