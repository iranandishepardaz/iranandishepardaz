import 'SplashScreen.dart';

import 'AppDatabase.dart';
import 'AppParameters.dart';

import 'AP_Utils.dart';
import 'AppSettings.dart';
import 'ShortMessages.dart';
import 'ShortMessagesPage.dart';
import 'GetPhoto.dart';
import 'Switchboard.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:telephony/telephony.dart';

onBackgroundMessage(SmsMessage message) {
  String messageToShow = "onBackgroundMessage called";

  saveMessage(message);
  messageToShow += "\n\n";
  messageToShow += message.address ?? "Error reading message address.";
  messageToShow += message.body ?? "Error reading message body.";
  debugPrint(messageToShow);
}

Future<int> saveMessage(SmsMessage message) async {
  ShortMessage tmpMessage = ShortMessage.fromSmsMessage(message);
  /*ShortMessage tmpMessage = ShortMessage(
      address: message.address!,
      sentAt: (message.date!) ~/
          1000, // DateTime.now().millisecondsSinceEpoch ~/ 1000,
      messageBody: message.body!,
      kind: message.type == SmsType.MESSAGE_TYPE_OUTBOX
          ? 0
          : message.type == SmsType.MESSAGE_TYPE_INBOX
              ? 1
              : message.type == SmsType.MESSAGE_TYPE_DRAFT
                  ? 2
                  : 9,
      uploaded: 0);*/
  await AppDatabase.initDatabase();
  AppParameters.currentUser = await AppSettings.readLastLoggedUser();
  AppParameters.currentPassword = await AppSettings.readLastLoggedPassword();
  await tmpMessage.insert();
  return await tmpMessage.upload();
}

void main() async {
  await init();
  runApp(MyApp());
}

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
//  await AppParameters.initialize();
//this can be done on the splash screen(while waiting)
  await AppDatabase.initDatabase();
  try {
    await AppSettings.readCurrentSetings();
  } catch (e) {
    AppSettings.resetToDefaultSetings();
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = "";
  final telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body!;
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

    final bool result = await telephony.requestPhoneAndSmsPermissions ?? false;

    if (result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _resetTimer('down'),
      onPointerMove: (_) => _resetTimer('move'),
      onPointerUp: (_) => _resetTimer('up'),
      onPointerSignal: (_) => _resetTimer('Signal'),
      child: MaterialApp(
        theme: ThemeData(
            primarySwatch: Colors.grey, scaffoldBackgroundColor: Colors.grey),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}

void _resetTimer(String userAction) {
  // debugPrint(userAction);
  if (userAction == "down") {
    AppParameters.lastUserActivity = DateTime.now();
  }
}
