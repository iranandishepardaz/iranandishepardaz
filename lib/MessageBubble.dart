import 'package:ap_me/ApMeMessages.dart';
import 'package:ap_me/ChatPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ApMeUtils.dart';
import 'AppParameters.dart';
import 'TempMessages.dart';

// ignore: must_be_immutable
class MessageBubble extends StatelessWidget {
  ApMeMessage currentMessage;
  ChatPageState parent;

  MessageBubble(ApMeMessage theMessage, this.parent) {
    currentMessage = theMessage;
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: currentMessage.fromId == AppParameters.currentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          //  Column(
          //   children: [
          Text(
            currentMessage.uploaded > 0
                ? MesUtil.formatDateTime(currentMessage.getSentAtTime(), 1)
                : "Does not sent!",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Visibility(
            visible: currentMessage.messageType == 1,
            child: Container(
              child: Image(
                  image: NetworkImage(AppParameters.mainSiteURL +
                      "/images/" +
                      currentMessage.fromId +
                      "/" +
                      currentMessage.url)),
              width: 200,
              height: 200,
            ),
          ),
          Material(
            borderRadius: currentMessage.fromId == AppParameters.currentUser
                ? BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0))
                : BorderRadius.only(
                    topRight: Radius.circular(15.0),
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0)),
            elevation: 5.0,
            color: currentMessage.fromId == AppParameters.currentUser
                ? (currentMessage.uploaded > 0
                    ? Colors.lightBlueAccent
                    : Colors.red)
                : Colors.black,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
              child: Text(
                currentMessage.messageBody,
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
            ),
          ),

          Visibility(
            visible: currentMessage.uploaded == 0 &&
                currentMessage.fromId == AppParameters.currentUser,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () async {
                      TempMessage tempMessage =
                          new TempMessage.fromApMeMessage(currentMessage);
                      await tempMessage.send();
                      this.parent.getMessages(true);
                    }),
                IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      TempMessage tempMessage =
                          new TempMessage.fromApMeMessage(currentMessage);
                      await tempMessage.delete();
                      this.parent.getMessages(false);
                    }),
              ],
            ),
          ),
        ],
        //),
        // ],
      ),
    );
  }
}
