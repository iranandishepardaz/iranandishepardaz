import 'package:ap_me/ApMeMessages.dart';
import 'package:ap_me/ApcoMessageBox.dart';
import 'package:ap_me/ApcoUtils.dart';
import 'package:ap_me/ChatPage.dart';
import 'package:ap_me/PersianDateUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'AppParameters.dart';
import 'AppSettings.dart';
import 'TempMessages.dart';

class MessageBubble extends StatefulWidget {
  final ApMeMessage currentMessage;
  final GlobalKey keyToScroll;
  final ChatPageState parent;
  final int bubbleId;
  final VoidCallback function;
  const MessageBubble(this.currentMessage, this.parent, this.keyToScroll,
      this.bubbleId, this.function)
      : super();

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
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
              child: Image(image: NetworkImage(widget.currentMessage.fullUrl)),
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
            color: widget.currentMessage.deleted > 0
                ? Colors.grey
                : widget.currentMessage.fromId == AppParameters.currentUser
                    ? (widget.currentMessage.uploaded > 0
                        ? AppSettings.sentMessageBackColor
                        : Colors.red)
                    : AppSettings.receivedMessageBackColor,
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                child: GestureDetector(
                  onTap: () {
                    if (widget.currentMessage.deleted == 0 &&
                        widget.currentMessage.fromId ==
                            AppParameters.currentUser)
                      widget.parent.editMessage(widget.bubbleId);
                  },
                  onDoubleTap: () {
                    Clipboard.setData(
                        ClipboardData(text: widget.currentMessage.messageBody));
                    //widget.parent.showSnackMessage("در حافظه موقت کپی شد");
                    ApcoUtils.showSnackMessage("در حافظه موقت کپی شد", context);
                  },
                  // Start List multi-select mode on long press
                  onLongPress: () {
                    /* ApcoMessageBox().showMessageToEdit(widget.currentMessage,
                        widget.currentMessage.fullUrl, this.context);
                    */
                    //widget.currentMessage.isEditting = true;
                    // debugPrint('onLongPress ' +
                    //     widget.currentMessage.messageId.toString());
                    if (AppParameters.currentUser == "akbar")
                      widget.parent.editMessage(widget.bubbleId);
                    //  setState(() {});
                  },
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      widget.currentMessage.deleted > 0
                          ? "پیام حذف شده"
                          : widget.currentMessage.messageBody.length > 0
                              ? widget.currentMessage.messageBody
                              : "پیام حذف شده",
                      style: TextStyle(
                          fontSize: AppSettings.messageBodyFontSize,
                          color: widget.currentMessage.fromId !=
                                  AppParameters.currentUser
                              ? AppSettings.receivedMessageForeColor
                              : widget.currentMessage.deliveredAt > 0 ||
                                      (!AppParameters.canSeeLastSeen)
                                  ? AppSettings.sentDeliveredMessageForeColor
                                  : AppSettings.sentMessageForeColor),
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
