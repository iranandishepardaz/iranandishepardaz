import 'dart:async';

import 'package:ap_me/ChatHeader.dart';
import 'package:ap_me/FileUploader.dart';
import 'package:ap_me/FriendsPage.dart';
import 'package:ap_me/MessageBubble.dart';
import 'package:ap_me/TempMessages.dart';

import 'ApMeUtils.dart';
import 'AppParameters.dart';
import 'package:flutter/material.dart';
import 'ApMeMessages.dart';

class ChatPage extends StatefulWidget {
  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  String textToSend = "";
//  List<MessageBubble> messageBubbles = [];
  List<ApMeMessage> messages = [];
  List<TempMessage> tempMessages = [];
  final messageBodyTextController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    getMessages(false);
    _startRefreshTimer();
    super.initState();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new FlatButton(
               // onPressed: () => Navigator.of(context).pop(false),
               onPressed: goBackToFriendsPage,
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<bool> _onWillPopSimple() async {
      goBackToFriendsPage();
       return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPopSimple,
      child: Scaffold(
          appBar: ChatHeader().chatBar([
            IconButton(
                icon: Icon(Icons.arrow_back_ios),
                color: Colors.white,
                onPressed: () {
                  goBackToFriendsPage();
                }),
            IconButton(
              color: Colors.white,
              onPressed: () {
                getMessages(true);
              },
              icon: Icon(Icons.cloud_download),
            )
          ], isLoading),
          body: SafeArea(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  reverse: true,
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  children: messages == null
                      ? Text("No Message")
                      : List.generate(messages.length, (int index) {
                          return new MessageBubble(
                              messages[messages.length - index - 1], this);
                        }),
                ),
              ),
              /*
              tempMessages.length > 0
                  ? Expanded(
                      child: ListView(
                        reverse: true,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 20.0),
                        children: List.generate(tempMessages.length, (int index) {
                          return getTempMessagesAsPadding(index);
                        }),
                      ),
                    )
                  : Text("No TempMessage"),
                  */
              Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    border: Border(
                        top: BorderSide(color: Colors.grey[350]),
                        left: BorderSide(color: Colors.grey[350])),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: TextField(
                        controller: messageBodyTextController,
                        onChanged: (value) {
                          textToSend = value;
                        },
                      )),
                      FlatButton(
                          onPressed: () {
                            sendTextMessage();
                          },
                          child: Icon(Icons.send)),
                          FlatButton(
                          onPressed: () {
                            sendFileMessage();
                          },
                          child: Icon(Icons.attach_file))
                    ],
                  )),
              //SizedBox(height: 3,),
            ],
          ))),
    );
  }

  void _startTimer() {
    Timer.periodic(AppParameters.refreshPeriod, (timer) async {
      timer.cancel();
      print(DateTime.now().toString() + " Chat page web Refreshing...");
      await getMessages(true);
    });
  }

  void _startRefreshTimer() {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (AppParameters.chatPageNeedsRefresh)
        setState(() {
          AppParameters.chatPageNeedsRefresh = false;
          print(DateTime.now().toString() + "Refreshing from outside ...");
        });
    });
  }

  void sendTextMessage() async {
    if (textToSend.length == 0) return;
    ApMeMessage sentMessage = await ApMeMessages.sendTextMessage(textToSend);
    textToSend = "";
    messageBodyTextController.clear();

    if (sentMessage != null)
      messages.add(sentMessage);
    else {
      TempMessage tempMessage = new TempMessage(
        messageId: 0,
        fromId: AppParameters.currentUser,
        toId: AppParameters.currentFriend,
        messageBody: textToSend,
        sentAt: 0,
        deliveredAt: 0,
        seenAt: 0,
        messageType: 0,
        url: "",
        deleted: 0,
        uploaded: 0,
      );
      tempMessages.add(tempMessage);
    }
    getMessages(false);
  }

  void goBackToFriendsPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => FriendsPage()));
  }
void sendFileMessage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => FileUploader()));
  
}

  Future<void> getMessages(bool fromWeb) async {
    isLoading = true;
    setState(() {});
    messages = await ApMeMessages.getLocalFriendMessages();
    if (messages.length == 0 || fromWeb) {
      await ApMeMessages.getWebNewMessages(true);
      messages = await ApMeMessages.getLocalFriendMessages();
    }
    tempMessages = await TempMessages.getLocalFriendMessages();
    for (int i = 0; i < tempMessages.length; i++) {
      messages.add(new ApMeMessage.fromTempMessage(tempMessages[i]));
    }
    setState(() {
      isLoading = false;
      print(DateTime.now().toString() + " Chat page refresh done.");
    });
    _startTimer();
  }

/*
  void getMessagesFromServer() async {
    messages =
        await ApMeUtils.getUserLastMessages(AppParameters.currentFriend);
    setState(() {
      messageBubbles.clear();
    });
    for (int i = messages.length - 1; i > 1; i--) {
      setState(() {
        messageBubbles.add(MessageBubble(
          messageBody: messages[i].messageBody,
          sentAt: messages[i].sentAtTime.toString(),
          fromId: messages[i].fromId,
        ));
      });
    }
    setState(() {});
  }
*/

  void resendMessages() async {
    for (int i = 0; i < tempMessages.length; i++) await tempMessages[i].send();
    setState(() {});
  }
}
