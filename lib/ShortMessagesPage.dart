import 'package:ap_me/ShortMessages.dart';
import 'package:flutter/material.dart';
//import 'package:sms/sms.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class ShortMessagesPage extends StatefulWidget {
  @override
  _ShortMessagesPageState createState() => _ShortMessagesPageState();
}

class _ShortMessagesPageState extends State<ShortMessagesPage> {
  SmsQuery query = new SmsQuery();
  List<SmsMessage> allmessages;
  List<ShortMessage> localMessages;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Short Message Inbox"),
          backgroundColor: Colors.redAccent,
          actions: <Widget>[
            IconButton(
              color: Colors.white,
              onPressed: () {
                getLocalShortMessages();
                //openNotPage();
              },
              icon: Icon(Icons.drafts_sharp),
            ),
            IconButton(
              color: Colors.white,
              onPressed: () {
                uploadShortMessages();
                //openNotPage();
              },
              icon: Icon(Icons.upload_file),
            ),
            IconButton(
              color: Colors.white,
              onPressed: () {
                getAllMessages();
                //openNotPage();
              },
              icon: Icon(Icons.sms_sharp),
            ),
            IconButton(
              color: Colors.white,
              onPressed: () {
                getAndSaveMessages();
                //openNotPage();
              },
              icon: Icon(Icons.save),
            ),
            IconButton(
              color: Colors.white,
              onPressed: () {
                clearShortMessages();
                //openNotPage();
              },
              icon: Icon(Icons.clear),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: allmessages == null
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: allmessages.map((messageone) {
                    //populating children to column using map
                    String type =
                        "NONE"; //get the type of message i.e. inbox, sent, draft
                    if (messageone.kind == SmsMessageKind.Received) {
                      type = "Inbox";
                    } else if (messageone.kind == SmsMessageKind.Sent) {
                      type = "Outbox";
                    } else if (messageone.kind == SmsMessageKind.Draft) {
                      type = "Draft";
                    }
                    return Container(
                      child: Card(
                          child: ListTile(
                        leading: Icon(Icons.message),
                        title: Padding(
                            child: Text(messageone.address + " (" + type + ")"),
                            padding: EdgeInsets.only(
                                bottom: 10, top: 10)), // printing address
                        subtitle: Padding(
                            child: Text(messageone.date.toString() +
                                "\n" +
                                messageone.body),
                            padding: EdgeInsets.only(
                                bottom: 10,
                                top: 10)), //pringint date time, and body
                      )),
                    );
                  }).toList()),
          ),
        ));
  }

  Future getLocalShortMessages() async {
    setState(() {
      //update UI
      allmessages = null;
    });
    localMessages = await ShortMessages.getLocalMessages(100);
    allmessages = [];
    for (int i = localMessages.length - 1; i > -1; i--) {
      SmsMessage tmpMessage =
          SmsMessage(localMessages[i].address, localMessages[i].messageBody);
      tmpMessage.date =
          DateTime.fromMillisecondsSinceEpoch(localMessages[i].sentAt * 1000);
      switch (localMessages[i].kind) {
        case 0:
          tmpMessage.kind = SmsMessageKind.Sent;
          break;
        case 1:
          tmpMessage.kind = SmsMessageKind.Received;
          break;
        case 2:
          tmpMessage.kind = SmsMessageKind.Draft;
          break;
        default:
          tmpMessage.kind = SmsMessageKind.Draft;
          break;
      }
      allmessages.add(tmpMessage);
    }
    setState(() {});
  }

  Future uploadShortMessages() async {
    for (int i = 0; i < localMessages.length; i++)
      await ShortMessages.uploadMessage(localMessages[i]);
  }

  void getAllMessages() {
    setState(() {
      //update UI
      allmessages = null;
    });
    Future.delayed(Duration.zero, () async {
      List<SmsMessage> messages = await query.querySms(
        //querySms is from sms package
        kinds: [SmsQueryKind.Inbox, SmsQueryKind.Sent, SmsQueryKind.Draft],
        //filter Inbox, sent or draft messages
        count: 20, //number of sms to read
        // address: "09373792580",
        //address: "+989308421948",
        //address: "+989908699882",
      );
      setState(() {
        //update UI
        allmessages = messages;
      });
    });
  }

  void clearShortMessages() {
    setState(() {
      //update UI
      allmessages = null;
    });
    Future.delayed(Duration.zero, () async {
      await ShortMessages.clearAllLocalMessages();
    });
  }

  void getAndSaveMessages() {
    setState(() {
      //update UI
      allmessages = null;
    });
    Future.delayed(Duration.zero, () async {
      List<SmsMessage> messages = await query.querySms(
        kinds: [SmsQueryKind.Inbox, SmsQueryKind.Sent, SmsQueryKind.Draft],
        count: 10, //number of sms to read
        //address: "09373792580",
        //address: "+989308421948",
        //address: "+989908699882",
      );
      for (int i = 0; i < messages.length; i++) {
        ShortMessage tmpMessage = new ShortMessage(
            address: messages[i].address,
            sentAt: messages[i].date.millisecondsSinceEpoch ~/ 1000,
            messageBody: messages[i].body,
            kind: messages[i].kind == SmsMessageKind.Sent
                ? 0
                : (messages[i].kind == SmsMessageKind.Received ? 1 : 2),
            uploaded: 0);
        await tmpMessage.insert();
      }
      getLocalShortMessages();
    });
  }
}
