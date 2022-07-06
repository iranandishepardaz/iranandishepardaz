import 'AP_Utils.dart';
import 'AppDatabase.dart';
import 'ShortMessages.dart';
import 'ShortMessagesPage.dart';
import 'GetPhoto.dart';
import 'Switchboard.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:telephony/telephony.dart';

class Switchboard extends StatefulWidget {
  const Switchboard({Key? key}) : super(key: key);

  @override
  _SwitchboardState createState() => _SwitchboardState();
}

class _SwitchboardState extends State<Switchboard> {
  String _message = "";
  final telephony = Telephony.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akbar Test Application'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            OutlinedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                ),
                onPressed: () async {
                  AP_DialogBox.showDialogBox(this.context, saveSampleMessage);
                },
                child: Text('Save Sample Message')),
            OutlinedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                ),
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (contexti) => ShortMessagesPage()));
                },
                child: Text('Open Messages')),
            OutlinedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0))),
                ),
                onPressed: () async {
                  await telephony.sendSms(
                      to: "989131180199", message: "سلام آزمایش فرستادن پیامک");
                },
                child: Text('Send Message')),
            Center(child: Text("Latest received SMS: $_message")),
          ],
        ),
      ),
    );
  }

  Future<int> saveSampleMessage() async {
    ShortMessage tmpMessage = ShortMessage(
        address: "0913118",
        sentAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        messageBody: "It is Sample",
        kind: 1,
        uploaded: 0);
    return await tmpMessage.insert();
  }
}
