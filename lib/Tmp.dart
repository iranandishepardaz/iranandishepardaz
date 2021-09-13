import 'dart:core';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class Tmp extends StatefulWidget {
  @override
  _TmpState createState() => _TmpState();
}

class _TmpState extends State<Tmp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    /*try {
      platformVersion = await FlutterSmsInbox.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }*/

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  var txt = TextEditingController();
  @override
  Widget build(BuildContext context) {
    getMessages(0);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: Column(
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            Text('Running  on: $_platformVersion\n'),
            TextField(
              controller: txt,
              maxLines: 15,
            ),
            RaisedButton(
                child: Text("Refresh"),
                onPressed: () {
                  getMessages(10);
                }),
          ],
        )),
      ),
    );
  }

  Future<List<SmsMessage>> getMessages(int count) async {
    SmsQuery query = new SmsQuery();
    List<SmsMessage> messages = await query.getAllSms;
    txt.text = "";
    if (count == 0 || count > messages.length) count = count = messages.length;
    for (int i = 0; i < count; i++) {
      txt.text += "Add:" +
          messages[i].address +
          "\n" +
          messages[i].dateSent.toString() +
          "\n" +
          messages[i].date.toString() +
          "\nBody:" +
          messages[i].body +
          "\n__________________\n\n";
    }
    return messages;
  }

  /* Future<List<SmsMessage>> getMessagesFrom(String partner, int count) async {
    SmsQuery query = new SmsQuery();
   List<SmsMessage> messages = await query.querySms({
 //     address: partner,
 //   });

    txt.text = "";
    if (count == 0 || count > messages.length) count = count = messages.length;
    for (int i = 0; i < count; i++) {
      txt.text += "Add:" +
          messages[i].address +
          "\n" +
          messages[i].dateSent.toString() +
          "\n" +
          messages[i].date.toString() +
          "\nBody:" +
          messages[i].body +
          "\n__________________\n\n";
    }
    return messages;
  }*/
}
