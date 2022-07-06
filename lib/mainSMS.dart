import 'package:ap_me/ShortMessagesPage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:telephony/telephony.dart';

import 'AppDatabase.dart';
import 'AppSettings.dart';
import 'ShortMessages.dart';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
  String _messageToShow = "onBackgroundMessage called";

  saveMessage(message);
  _messageToShow += "\n\n";
  _messageToShow += message.address ?? "Error reading message address.";
  _messageToShow += message.body ?? "Error reading message body.";
  debugPrint(_messageToShow);
}

Future<int> saveMessage(SmsMessage message) async {
  ShortMessage tmpMessage = ShortMessage(
      address: message.address,
      sentAt: (message.date), // DateTime.now().millisecondsSinceEpoch ~/ 1000,
      messageBody: message.body,
      kind: 1,
      uploaded: 0);
  return await tmpMessage.insert();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
//  await AppParameters.initialize();
//this can be done on the splash screen(while waiting)
  await AppDatabase.initDatabase();
  try {
    await AppSettings.readCurrentSetings();
  } catch (e) {
    AppSettings.resetToDefaultSetings();
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message;
  final telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body;
      saveMessage(message);
    });
  }

  onSendStatus(SendStatus status) {
    setState(() {
      _message = status == SendStatus.SENT ? "sent" : "delivered";
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool result = await telephony.requestPhoneAndSmsPermissions;

    if (result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ShortMessagesPage()
        /*     Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text("Latest received SMS: $_message")),
          TextButton(
              onPressed: () async {
                await telephony.openDialer('123456789');
              },
              child: Text('Open Dialer')),
          IconButton(
            icon: Icon(Icons.message_outlined),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ShortMessagesPage()));
            },
          )
        ],
      ),
    ) */
        );
  }
}
