/*import 'package:ap_me/ApMeMessages.dart';
import 'package:ap_me/ChatPage.dart';
import 'package:ap_me/PersianDateUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AppParameters.dart';
import 'TempMessages.dart';

class MessageBubbleFull extends StatefulWidget {
  final ApMeMessage currentMessage;
  final GlobalKey keyToScroll;
  final ChatPageState parent;
  final int bubbleId;
  final VoidCallback function;
  const MessageBubbleFull(this.currentMessage, this.parent, this.keyToScroll,
      this.bubbleId, this.function)
      : super();

  @override
  _MessageBubbleFullState createState() => _MessageBubbleFullState();
}

class _MessageBubbleFullState extends State<MessageBubbleFull> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            widget.currentMessage.fromId == AppParameters.currentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        children: [
          //  Column(
          //   children: [
          Text(
            widget.currentMessage.uploaded > 0
                ? PersianDateUtil.MItoSH_Full(widget.currentMessage
                    .getSentAtTime()) // + PersianDateUtil.MItoSH(widget.currentMessage.getSentAtTime())
                : "Does not sent!",
            style: TextStyle(
                fontSize: AppSettings.messageDateFontSize,
                color: AppSettings.formsForegroundColor),
          ),
          Visibility(
            visible: widget.currentMessage.messageType == 1,
            child: Container(
              child: Image(
                  image: NetworkImage(AppParameters.mainSiteURL +
                      "/images/" +
                      widget.currentMessage.fromId +
                      "/" +
                      widget.currentMessage.url)),
              width: 200,
              height: 200,
            ),
          ),
          Material(
            borderRadius:
                widget.currentMessage.fromId == AppParameters.currentUser
                    ? BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0))
                    : BorderRadius.only(
                        topRight: Radius.circular(15.0),
                        bottomLeft: Radius.circular(15.0),
                        bottomRight: Radius.circular(15.0)),
            elevation: widget.currentMessage.deliveredAt > 0 ? 12.0 : 0.0,
            color: widget.currentMessage.fromId == AppParameters.currentUser
                ? (widget.currentMessage.uploaded > 0
                    ? AppParameters.sentMessageBackColor
                    : Colors.red)
                : AppParameters.receivedMessageBackColor,
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                child: GestureDetector(
                  onTap: () {
                    debugPrint(
                        'onPress on bubble No: ' + widget.bubbleId.toString());
                  },
                  // Start List multi-select mode on long press
                  onLongPress: () {
                    widget.currentMessage.isEditting = true;
                    debugPrint('onLongPress ' +
                        widget.currentMessage.messageId.toString());
                    widget.parent.editMessage(widget.bubbleId);
                  },
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      widget.currentMessage.messageBody,
                      style: TextStyle(
                          fontSize: AppSettings.messageBodyFontSize,
                          color: widget.currentMessage.deliveredAt > 0 ||
                                  (!AppParameters.canSeeLastSeen)
                              ? AppParameters.sentDeliveredMessageForeColor
                              : AppParameters.sentMessageForeColor),
                    ),
                  ),
                )),
          ),

          Visibility(
            visible: widget.currentMessage.uploaded == 0 &&
                widget.currentMessage.fromId == AppParameters.currentUser,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () async {
                      TempMessage tempMessage = new TempMessage.fromApMeMessage(
                          widget.currentMessage);
                      await tempMessage.send();
                      widget.parent.getMessages(true);
                    }),
                IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      TempMessage tempMessage = new TempMessage.fromApMeMessage(
                          widget.currentMessage);
                      await tempMessage.delete();
                      widget.parent.getMessages(false);
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
*/