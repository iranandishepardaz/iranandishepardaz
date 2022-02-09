import 'package:ap_me/AppParameters.dart';
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
  List<SmsMessage> allMessages;
  List<ShortMessage> localMessages;
  int messageToShowCount = 20;
  bool reverseList = true;

  @override
  void initState() {
    messageToShowCount = AppParameters.smsGetCount;
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
              icon: Icon(Icons.sms_sharp),
              color: Colors.white,
              onPressed: () {
                reverseList = false;
                getShortMessages(messageToShowCount);
                //openNotPage();
              },
            ),
            IconButton(
              icon: Icon(Icons.drafts_sharp),
              color: Colors.white,
              onPressed: () {
                messageToShowCount = 20;
                reverseList = false;
                getLocalShortMessages(messageToShowCount);
                //openNotPage();
              },
            ),
            IconButton(
              icon: Icon(Icons.save),
              color: Colors.white,
              onPressed: () {
                getAndSaveShortMessages(messageToShowCount);
                //openNotPage();
              },
            ),
            /*IconButton(
              color: Colors.white,
              onPressed: () {
                reverseList = true;
                uploadShortMessages();
                //openNotPage();
              },
              icon: Icon(Icons.upload),
            ),
            */
            IconButton(
              icon: Icon(Icons.download),
              color: Colors.white,
              onPressed: () {
                downloadShortMessages();
                //openNotPage();
              },
            ),
            IconButton(
              icon: Icon(Icons.clear),
              color: Colors.white,
              onPressed: () {
                clearShortMessages();
                //openNotPage();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          reverse: reverseList,
          child: Container(
            padding: EdgeInsets.all(20),
            child: allMessages == null
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: allMessages.map((messageone) {
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

  Future<void> getShortMessages(int count) async {
    setState(() {
      //update UI
      allMessages = null;
    });
    allMessages = await ShortMessages.getShortMessages(count);
    setState(() {});
  }

  Future<void> getAndSaveShortMessages(int count) async {
    setState(() {
      //update UI
      allMessages = null;
    });
    // Future.delayed(Duration.zero, () async {
    List<SmsMessage> tmpMessages = await ShortMessages.getShortMessages(count);
    for (int i = 0; i < tmpMessages.length; i++) {
      ShortMessage tmpMessage = new ShortMessage(
          address: tmpMessages[i].address,
          sentAt: tmpMessages[i].date.millisecondsSinceEpoch ~/ 1000,
          messageBody: tmpMessages[i].body,
          kind: tmpMessages[i].kind == SmsMessageKind.Sent
              ? 0
              : (tmpMessages[i].kind == SmsMessageKind.Received ? 1 : 2),
          uploaded: 0);
      await tmpMessage.insert();
    }
    getLocalShortMessages(count);
    // });
  }

  Future getLocalShortMessages(int count) async {
    setState(() {
      //update UI
      allMessages = null;
    });
    localMessages = await ShortMessages.getLocalMessages(count);
    allMessages = [];
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
      allMessages.add(tmpMessage);
    }
    setState(() {});
  }

  Future uploadShortMessages() async {
    for (int i = 0; i < localMessages.length; i++) {
      if (localMessages[i].uploaded == 0) await localMessages[i].upload();
    }
  }

  void downloadShortMessages() async {
    setState(() {
      allMessages = null;
    });
    //List<ShortMessage> allMessages = await ShortMessages.download(10);
    allMessages = await ShortMessages.getWebShortMessages(AppParameters.smsUser,
        AppParameters.smsGetCount, AppParameters.smsFilter, false);

    Future.delayed(Duration.zero, () async {
      setState(() {
        reverseList = false;
        // allMessages = messages;
      });
    });
  }

  void clearShortMessages() {
    setState(() {
      //update UI
      allMessages = null;
    });
    //  Future.delayed(Duration.zero, () async {
    //   await ShortMessages.clearAllLocalMessages();
    //  });
  }

  void getAndSaveMessages(int count) {
    setState(() {
      //update UI
      allMessages = null;
    });
    Future.delayed(Duration.zero, () async {
      List<SmsMessage> messages = await query.querySms(
        kinds: [SmsQueryKind.Inbox, SmsQueryKind.Sent, SmsQueryKind.Draft],
        count: count, //number of sms to read
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
      getLocalShortMessages(messageToShowCount);
    });
  }
}
