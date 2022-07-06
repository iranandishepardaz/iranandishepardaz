import 'AppSettings.dart';
import 'LoginPage.dart';
import 'PersianDateUtil.dart';

import 'AdminPage.dart';
import 'GetPhoto.dart';
import 'IsolateTester.dart';

import 'AppParameters.dart';
import 'LoginDialog.dart';
import 'ShortMessages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//import 'package:sms/sms.dart';
//import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class ShortMessagesPage extends StatefulWidget {
  @override
  _ShortMessagesPageState createState() => _ShortMessagesPageState();
}

class _ShortMessagesPageState extends State<ShortMessagesPage> {
  //SmsQuery query = new SmsQuery();
  //List<SmsMessage>? allMessages;
  List<ShortMessage> localMessages = [];
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
        backgroundColor: AppSettings.formsBackgroundColor,
        appBar: AppBar(
          title: Text("ApMe",
              style: TextStyle(color: AppSettings.titlesForegroundColor)),
          iconTheme: IconThemeData(
            color: AppSettings.titlesForegroundColor, //change your color here
          ),
          backgroundColor: AppSettings.titlesBackgroundColor,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.list),
              color: AppSettings.titlesForegroundColor,
              onPressed: () {
                reverseList = false;
                getShortMessages(messageToShowCount);
                //openNotPage();
              },
            ),
            IconButton(
              icon: const Icon(Icons.save_alt_outlined),
              color: AppSettings.titlesForegroundColor,
              onPressed: () async {
                getPhoneMessages();
              },
            ),
            IconButton(
              icon: const Icon(Icons.upload_rounded),
              color: AppSettings.titlesForegroundColor,
              onPressed: () async {
                HapticFeedback.vibrate();
                uploadShortMessages();
                // await Navigator.of(context).push(MaterialPageRoute(builder: (context) => GetPhotoPage(title: 'Test')));
                // HapticFeedback.heavyImpact();
              },
            ),
            /*IconButton(
              color:  AppSettings.titlesForegroundColor,
              onPressed: () {
                reverseList = true;
                uploadShortMessages();
                //openNotPage();
              },
              icon: Icon(Icons.upload),
            ),
            */
            IconButton(
              icon: const Icon(Icons.download),
              color: AppSettings.titlesForegroundColor,
              onPressed: () {
                downloadShortMessages();
              },
            ),
            /*   IconButton(
              icon: Icon(Icons.clear),
              color: Colors.white,
              onPressed: () {
                //clearShortMessages();
              },
            ),*/
          ],
        ),
        body: SingleChildScrollView(
          reverse: reverseList,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: localMessages.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: localMessages.map((messageone) {
                    //populating children to column using map
                    String type = messageone.kind == 0 ? 'Out' : 'In';
                    //messageone.sentAt = messageone.sentAt + 25;
                    // messageone.upload();
                    //"NONE"; //get the type of message i.e. inbox, sent, draft
                    /*if (messageone.kind == SmsMessageKind.Received) {
                      type = "Inbox";
                    } else if (messageone.kind == SmsMessageKind.Sent) {
                      type = "Outbox";
                    } else if (messageone.kind == SmsMessageKind.Draft) {
                      type = "Draft";
                    }*/
                    return Container(
                      child: Card(
                          color: type == 'Out'
                              ? AppSettings.sentMessageBackColor
                              : AppSettings.receivedMessageBackColor,
                          child: ListTile(
                              onLongPress: () async {
                                await messageone.delete();
                                await getShortMessages(100);
                                setState(() {});
                              },
                              leading: type == 'Out'
                                  ? Icon(
                                      Icons.arrow_back,
                                      color:
                                          AppSettings.receivedMessageForeColor,
                                    )
                                  : Icon(Icons.arrow_forward,
                                      color:
                                          AppSettings.receivedMessageForeColor),
                              title: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 10, top: 10),
                                  child: Text(
                                      "${messageone.address} ($type) ${messageone.uploaded == 0 ? '.' : '✔️'}")), // printing address
                              subtitle: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 10, top: 10),
                                  child: Text(
                                      "${PersianDateUtil.EpcoSectoShamsi_Full(messageone.sentAt)}\n${messageone.messageBody}")),
                              textColor: AppSettings
                                  .receivedMessageForeColor //pringint date time, and body
                              )),
                    );
                  }).toList()),
          ),
        ));
  }

  Future<void> getShortMessages(int count) async {
    setState(() {
      localMessages = [];
    });
    localMessages = await ShortMessages.getLocalShortMessages(count);
    setState(() {});
  }

  static void openAdminPage(BuildContext context) {
    if (AppParameters.currentUser == 'admin') {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => AdminPage()));
    } else {
      LoginDialog().showLoginDialog(context);
    }
    // .push(MaterialPageRoute(builder: (context) => Tmp()));
  }

  void downloadShortMessages() async {
    setState(() {
      localMessages = [];
    });
    //List<ShortMessage> allMessages = await ShortMessages.download(10);
    localMessages = await ShortMessages.getWebShortMessages(
        AppParameters.smsUser,
        AppParameters.smsGetCount,
        AppParameters.smsFilter,
        false);

    Future.delayed(Duration.zero, () async {
      setState(() {
        reverseList = false;
        // allMessages = messages;
      });
    });
  }

  void uploadShortMessages() async {
    setState(() {
      localMessages = [];
    });
    //List<ShortMessage> allMessages = await ShortMessages.download(10);
    localMessages =
        await ShortMessages.uploadShortMessages(AppParameters.smsGetCount);

    Future.delayed(Duration.zero, () async {
      setState(() {
        reverseList = false;
        // allMessages = messages;
      });
    });
  }

  void getPhoneMessages() async {
    setState(() {
      localMessages = [];
    });
    //List<ShortMessage> allMessages = await ShortMessages.download(10);
    localMessages = await ShortMessages.getPhoneShortMessages(
        AppParameters.smsGetCount, true);
    //localMessages.add( await ShortMessages.getOutboxShortMessages(AppParameters.smsGetCount));

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
      localMessages = [];
    });
    //  Future.delayed(Duration.zero, () async {
    //   await ShortMessages.clearAllLocalMessages();
    //  });
  }
}
