import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ap_me/ApcoMessageBox.dart';
import 'package:ap_me/ChatHeader.dart';
import 'package:ap_me/MessageBubble.dart';
import 'package:ap_me/MessageEditor.dart';
import 'package:ap_me/TempMessages.dart';
import 'package:flutter/foundation.dart';
import 'AppParameters.dart';
import 'package:flutter/material.dart';
import 'ApMeMessages.dart';
import 'AppSettings.dart';
import 'OptionsDrawer.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  String textToSend = "";

//  List<MessageBubble> messageBubbles = [];
  Timer tmrChatPageDataRefresher;
  final dataKey = new GlobalKey();
  final ScrollController _scrollController = ScrollController();
  List<ApMeMessage> allMessages = [];
  int messagesToShowCount = 35;
  List<MessageBubble> allMessageBubbles;
  List<TempMessage> tempMessages = [];
  final messageBodyTextController = TextEditingController();
  ApMeMessage currentMessage;
  int currentBubbleId = -1;
  bool isLoading = false;
  bool isEditing = false;
  bool canSendImage =
      false; // AppParameters.currentUser == 'akbar' || AppParameters.currentUser == 'sepehr';

  @override
  void initState() {
    super.initState();
    //getMessages(false);
    //_startRefreshTimer();
    allMessages = [];
    generateBubbles();
    _startTimer();
    WidgetsBinding.instance.addObserver(this);
    messageBodyTextController.addListener(_adjustMessageBodyTextField);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        AppParameters.pausedTime = DateTime.now();
        break;
      case AppLifecycleState.resumed:
        AppParameters.pausedSeconds =
            DateTime.now().difference(AppParameters.pausedTime).inSeconds;
        if (AppParameters.pausedSeconds > AppParameters.pausePermittedSeconds) {
          Navigator.of(context).pop();
        } else {
          isLoading = false;
          _startTimer();
        }
        break;
      case AppLifecycleState.inactive:
        tmrChatPageDataRefresher.cancel();
        break;
      case AppLifecycleState.detached:
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit the App'),
            actions: <Widget>[
              new TextButton(
                // onPressed: () => Navigator.of(context).pop(false),
                onPressed: goBackToFriendsPage,
                child: new Text('No'),
              ),
              new TextButton(
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
    if (AppParameters.pausedSeconds > AppParameters.pausePermittedSeconds) {
      Navigator.of(context).pop();
    }
    return WillPopScope(
      onWillPop: _onWillPopSimple,
      child: RefreshIndicator(
          onRefresh: () {
            print(DateTime.now().toString() + "Refresh by pull ...");
            getUnsynced();
            return Future.delayed(Duration(seconds: 2), () {});
          },
          child: Scaffold(
            appBar: ChatHeader().chatBar([
              IconButton(
                  icon: Icon(Icons.arrow_back_ios,
                      color: AppParameters.titlesForegroundColor),
                  onPressed: () {
                    goBackToFriendsPage();
                  }),
              IconButton(
                color: AppParameters.titlesForegroundColor,
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: Duration(seconds: 2),
                    curve: Curves.fastOutSlowIn,
                  );
                  // _scrollController.animateTo(
                  //   _scrollController.position.minScrollExtent,
                  //   duration: Duration(seconds: 2),
                  //   curve: Curves.fastOutSlowIn,
                  //);
                },
                icon: Icon(Icons.arrow_downward_sharp),
              ),
              IconButton(
                color: AppParameters.titlesForegroundColor,
                onPressed: () {
                  // getMessages(true);
                  getUnsynced();
                },
                icon: Icon(Icons.cloud_download),
              ),
            ], isLoading, this.context),
            body: SafeArea(
                child: Container(
              color: AppParameters.formsBackgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppParameters.currentUser == 'akbar'
                      ? Expanded(
                          flex: 2,
                          child: IconButton(
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              int timeLimit = 0;
                              print("load more messages from web");
                              //must first gret local messages
                              timeLimit = allMessages.length > 0
                                  ? allMessages[0].sentAt
                                  : 0;
                              List<ApMeMessage> tmpMessages = await ApMeMessages
                                  .getPartnerMessagesBeforeFromWeb(
                                      messagesToShowCount, false, timeLimit);
                              for (int i = 0; i < tempMessages.length; i++) {
                                allMessages.add(tmpMessages[i]);
                              }
                              setState(() {
                                isLoading = false;
                              });
                            },
                            icon: Icon(Icons.download),
                            color: AppParameters.formsForegroundColor,
                          ),
                        )
                      : Expanded(flex: 1, child: Text("...")),
                  Expanded(
                      flex: 20,
                      child:
                          /*SingleChildScrollView(
                        child: Column(
                          //  reverse: false,
                          // padding: EdgeInsets.symmetric(
                          //     horizontal: 10.0, vertical: 20.0),
                          children:
                              (allMessages == null || allMessages.length == 0)
                                  ? [Text("No message yet! Send first one")]
                                  : allMessageBubbles, // generateBubbles(),
                        ),
                      ),
*/
                          NotificationListener<ScrollUpdateNotification>(
                        child: ListView(
                          controller: _scrollController,
                          reverse: true,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 20.0),
                          children: (allMessages == null ||
                                  allMessages.length == 0)
                              ? [
                                  IconButton(
                                    onPressed: () async {
                                      await ApMeMessages
                                          .getPartnerMessagesBeforeFromWeb(
                                              messagesToShowCount, false, 0);
                                    },
                                    icon: Icon(Icons.download),
                                    color: AppParameters.formsForegroundColor,
                                  ),
                                  Center(
                                    child: Text(
                                      "هنوز پیامی فرستاده نشده\n\r اولین پیام را بفرستید",
                                      style: TextStyle(
                                          color: AppParameters
                                              .formsForegroundColor,
                                          fontSize:
                                              AppSettings.messageBodyFontSize),
                                    ),
                                  )
                                ]
                              : allMessageBubbles, // generateBubbles(),
                        ),
                        onNotification: (notification) {
                          //How many pixels scrolled from pervious frame
                          print("Scroll Delta:" +
                              notification.scrollDelta.toString());

                          //List scroll position
                          print("Scroll Pixels:" +
                              notification.metrics.pixels.toString());
                          if (notification.metrics.pixels < 1) {
                            messagesToShowCount += 20;
                          }
                          return true;
                        },
                      )),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        height: _inputHeight,
                        decoration: BoxDecoration(
                          color: AppParameters.titlesBackgroundColor,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          border: Border(
                              top: BorderSide(
                                  color: AppParameters.formsForegroundColor),
                              bottom: BorderSide(
                                  color: AppParameters.formsForegroundColor),
                              left: BorderSide(
                                  color: AppParameters.formsForegroundColor),
                              right: BorderSide(
                                  color: AppParameters.formsForegroundColor)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                flex: 80,
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: TextField(
                                    style: TextStyle(
                                        color:
                                            AppParameters.titlesForegroundColor,
                                        fontSize:
                                            AppSettings.messageBodyFontSize),
                                    cursorColor:
                                        AppParameters.titlesForegroundColor,
                                    cursorHeight:
                                        AppSettings.messageBodyFontSize * 2,
                                    textAlign: TextAlign.right,
                                    decoration: InputDecoration(
                                      hintText: 'پیام خود را بنویسید',
                                      hintStyle: TextStyle(
                                          color: AppParameters
                                              .sentMessageForeColor,
                                          fontSize:
                                              AppSettings.messageBodyFontSize),
                                      contentPadding: EdgeInsets.all(2),
                                    ),
                                    maxLines: null,
                                    controller: messageBodyTextController,
                                    onChanged: (value) {
                                      textToSend = value;
                                    },
                                  ),
                                )),

                            //it will add to attach file
                            Visibility(
                              visible: canSendImage,
                              child: Expanded(
                                  flex: 10,
                                  child: TextButton(
                                      onPressed: () {
                                        sendFileMessage();
                                      },
                                      child: Icon(Icons.attach_file))),
                            ),
//
                            Expanded(
                                flex: 10,
                                child: TextButton(
                                    onPressed: () {
                                      sendTextMessage();
                                      _scrollController.animateTo(
                                        0,
                                        duration: Duration(seconds: 2),
                                        curve: Curves.fastOutSlowIn,
                                      );
                                    },
                                    child: Icon(
                                      Icons.send,
                                      color:
                                          AppParameters.titlesForegroundColor,
                                    ))),
                          ],
                        )),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            )),
            endDrawer: OptionsDrawer.SideDrawer(this),
          )),
    );
  }

  callback(parameter) {
    setState(() {
      messageBodyTextController.text = parameter;
    });
  }

  double _inputHeight = (3 * AppSettings.messageBodyFontSize);

  void _adjustMessageBodyTextField() async {
    int count = messageBodyTextController.text.split('\n').length;
    if (count < 6) {
      //var newHeight = count == 0 ? 40.0 : 40.0 + (count * _lineHeight);
      var newHeight = (count + 1) * 2 * AppSettings.messageBodyFontSize;
      setState(() {
        _inputHeight = newHeight;
      });
    }
  }

  editMessage(int bubbleID) async {
    currentMessage = allMessageBubbles[bubbleID].currentMessage;
    //currentMessage = new ApMeMessage();
    //currentMessage.messageId = tmp.messageId;
    //currentMessage.messageBody = tmpMessage.messageBody;

    //await ApcoMessageBox().showMessageToEdit(currentMessage, currentMessage.fullUrl, this.context);
    ResultEnums result = ResultEnums.Unknown;

    await MessageEditor()
        .messageEditor(currentMessage, this.context)
        .then((value) async {
      String strValue = value.toString();
      strValue = strValue.substring(
          strValue.indexOf("'") + 1, strValue.lastIndexOf("'"));
      result = strValue.toResultEnm();
      print("Dialog result:" + value.toString());
      switch (result) {
        case ResultEnums.OK_Editted:
          setState(() {
            generateBubbles();
            strValue = "ویرایش شد";
          });
          break;
        case ResultEnums.Error_Editting:
          setState(() {
            generateBubbles();
            strValue = "پیام قابل ویرایش نیست";
          });
          break;
        case ResultEnums.OK_Deletted:
          setState(() {
            generateBubbles();
            strValue = "پیام حذف شد!";
          });
          break;
        case ResultEnums.OK_MarkedDeleted:
          setState(() {
            generateBubbles();
            strValue = "پیام حذف شد!";
          });
          break;
        case ResultEnums.Error_Deletting:
          strValue = "پیام قابل حذف نیست";
          break;
        case ResultEnums.Copied_to_Clipboard:
          strValue = "پیام در حافظه موقت ذخیره شد!";
          break;
        default:
          strValue = "";
          break;
      }
      if (strValue.length > 0)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppParameters.titlesBackgroundColor,
          content: Container(
            child: Text(
              strValue,
              style: TextStyle(
                color: AppParameters.formsForegroundColor,
              ),
            ),
          ),
          duration: Duration(seconds: 2),
        ));
      /*if (value.toString() == "OK Editted") {
        setState(() {
          result = "ویرایش شد";
          generateBubbles();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result),
            duration: Duration(seconds: 3),
          ));
        });
      }
      if (value.toString() == "Error editting") {
        result = "پیام قابل ویرایش نیست";
      }
      if (value.toString() == "OK Deleted") {
        setState(() {
          generateBubbles();
        });
        result = "حذف شد";
      }
      if (value.toString() == "Error deleting") {
        result = "پیام قابل حذف نیست";
      }
      if (value.toString() == "Copied to clipboard") {
        result = "پیام کپی شد";
      }
        setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result),
          duration: Duration(seconds: 3),
        ));
      });*/
    });

    /*if (editted. )
      setState(() {
        generateBubbles();
      });*/
  }

  /*
  editMessage(int bubbleID) {
    setState(() {
      currentBubbleId = bubbleID;
      //currentMessage = new ApMeMessage();
      //currentMessage.messageId = tmp.messageId;
      //currentMessage.messageBody = tmpMessage.messageBody;
      setState(() {
        messageBodyTextController.text =
            allMessageBubbles[currentBubbleId].currentMessage.messageBody;
      });
      isEditing = true;
    });
  }
  */

  void _startTimer() {
    tmrChatPageDataRefresher =
        Timer.periodic(AppParameters.friendsRefreshPeriod, (timer) async {
      if (isLoading) {
        print(
            DateTime.now().toString() + "The Chat page Refreshing cancelled.");
      } else {
        print(DateTime.now().toString() + "The Chat page Refreshing...");
        getUnsynced();
      }
      //await getMessages(true);
      //messages = await ApMeMessages.getLocalFriendMessages();
    });
  }

  Future<void> getUnsynced() async {
    isLoading = true;
    setState(() {});
    //int currentMessagesCount = allMessages.length;
    await ApMeMessages.getUnsyncedMessagesFromWeb();
    //if (unsynedMessages.length > 0) {
    allMessages =
        await ApMeMessages.getLocalFriendMessages(messagesToShowCount);
    /* for (int i = 0; i < unsynedMessages.length; i++) {
        messages.add(unsynedMessages[i]);
      }*/
    // }

    isLoading = false;
    setState(() {
      //if (currentMessagesCount < allMessages.length)
      generateBubbles();
      print(DateTime.now().toString() + " Chat page Refreshed.");
    });
  }

  bool moreWebMessagesAvailable = true;

  bool moreLocalMessagesAvailable = true;

  Future<void> getMoreWebMessages(int count, int upperTimeLimit) async {
    isLoading = true;
    setState(() {});
    List<ApMeMessage> tmpMessages =
        await ApMeMessages.getPartnerMessagesBeforeFromWeb(
            count, false, upperTimeLimit);
    moreWebMessagesAvailable = tmpMessages.length == count;
    allMessages =
        await ApMeMessages.getLocalFriendMessages(messagesToShowCount);
    isLoading = false;
    setState(() {
      //if (currentMessagesCount < allMessages.length)
      generateBubbles();
      print(DateTime.now().toString() + " More messages got from web.");
    });
  }

  Future<void> getMoreLocalMessages(int count, int upperTimeLimit) async {
    isLoading = true;
    setState(() {});
    List<ApMeMessage> tmpMessages =
        await ApMeMessages.getPartnerMessagesBeforeFromWeb(
            count, false, upperTimeLimit);
    moreWebMessagesAvailable = tmpMessages.length == count;
    allMessages =
        await ApMeMessages.getLocalFriendMessages(messagesToShowCount);
    isLoading = false;
    setState(() {
      //if (currentMessagesCount < allMessages.length)
      generateBubbles();
      print(DateTime.now().toString() + " More messages got from web.");
    });
  }

  Future<void> getMessages(bool fromWeb) async {
    isLoading = true;
    setState(() {});
    //messages = await ApMeMessages.getLocalFriendMessages();
    if (allMessages.length == 0 || fromWeb) {
      await ApMeMessages.getWebNewMessages(true);
    } else {}
    allMessages =
        await ApMeMessages.getLocalFriendMessages(messagesToShowCount);
    tempMessages = await TempMessages.getLocalFriendMessages();
    for (int i = 0; i < tempMessages.length; i++) {
      allMessages.add(new ApMeMessage.fromTempMessage(tempMessages[i]));
    }
    //await ApMeMessages.getWebUnsyncedMessages();
    setState(() {
      isLoading = false;
      print(DateTime.now().toString() + " Chat page refresh done.");
    });
    //_startTimer();
  }

  /*void _startRefreshTimer() {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (AppParameters.chatPageNeedsRefresh)
        setState(() {
          AppParameters.chatPageNeedsRefresh = false;
          print(DateTime.now().toString() + "Refreshing from outside ...");
        });
    });
  }
*/

  final SnackBar snackBar = SnackBar(
    content: const Text("Init"),
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );

  Future<void> generateBubbles() async {
    allMessages =
        await ApMeMessages.getLocalFriendMessages(messagesToShowCount);
    allMessageBubbles = List.generate(allMessages.length, (int index) {
      return new MessageBubble(allMessages[index], this, dataKey, index, () {});
    });
    setState(() {});

    //return allMessageBubbles;
  }

  Future<bool> editTextMessage() async {
    isEditing = false;
    if (textToSend.length == 0) return await deleteTextMessage();
    isLoading = true;
    String tmpText = textToSend;
    textToSend = "";
    currentMessage = allMessageBubbles[currentBubbleId].currentMessage;
    currentMessage.messageBody = tmpText;
    ApMeMessage editedMessage = await ApMeMessages.editMessage(currentMessage);
    messageBodyTextController.clear();

    if (editedMessage != null) {
      setState(() {
        allMessageBubbles[currentBubbleId].currentMessage.update();
        showSnackMessage("ویرایش شد");
        generateBubbles();
        //allMessageBubbles[currentBubbleId].currentMessage.messageBody =
        //    editedMessage.messageBody;
        //allMessageBubbles[currentBubbleId].function();
      });

      //this._showToast(context);
    } else {
      showSnackMessage("پیام قابل ویرایش نیست!");
    }
    isLoading = false;
    return true;
  }

  void showSnackMessage(String messageToShow) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(messageToShow),
      duration: Duration(seconds: 1),
    ));
    setState(() {});
  }

  Future<bool> deleteTextMessage() async {
    isLoading = true;
    isEditing = false;
    textToSend = "";
    currentMessage = allMessageBubbles[currentBubbleId].currentMessage;
    ApMeMessage deletedMessage =
        await ApMeMessages.deleteMessage(currentMessage);
    messageBodyTextController.clear();

    if (deletedMessage != null) {
      allMessageBubbles[currentBubbleId].currentMessage.delete();
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("حذف شد!"),
          duration: Duration(seconds: 3),
        ));
      });

      //this._showToast(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("قابل حذف نیست!"),
        duration: Duration(seconds: 3),
      ));
    }
    isLoading = false;
    return true;
  }

  Future<bool> sendTextMessage() async {
    if (textToSend.length == 0) return await deleteTextMessage();
    if (isEditing) return editTextMessage();
    String tmpText = textToSend;
    textToSend = "";
    isLoading = true;
    ApMeMessage sentMessage = await ApMeMessages.sendTextMessage(tmpText);
    // messageBodyTextController.text = ""; //.clear();

    if (sentMessage != null) {
      allMessages.add(sentMessage);
      await getUnsynced();
      generateBubbles();
    } else {
      TempMessage tempMessage = new TempMessage(
        messageId: 0,
        fromId: AppParameters.currentUser,
        toId: AppParameters.currentFriendId,
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
      _scrollController.animateTo(
        0,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
      // messageBodyTextController.text = "";
    }
    isLoading = false;
    setState(() {
      // getMessages(false);
      messageBodyTextController.text = "";
    });
    return true;
  }

  Future<File> file;

  void sendFileMessage() async {
    //if (textToSend.length == 0) return deleteTextMessage();
    //if (isEditing) return editTextMessage();

    String tmpText = textToSend;
    textToSend = "";
    isLoading = true;
    if (tmpText == "") tmpText = "عکس";
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    String fileType = file.path.split('.').last;
    String base64Image = base64Encode(file.readAsBytesSync());
    ApMeMessage sentMessage =
        await ApMeMessages.sendFileMessage(tmpText, fileType, base64Image);
    // messageBodyTextController.text = ""; //.clear();

    if (sentMessage != null) {
      allMessages.add(sentMessage);
      await getUnsynced();
      generateBubbles();
    } else {
      TempMessage tempMessage = new TempMessage(
        messageId: 0,
        fromId: AppParameters.currentUser,
        toId: AppParameters.currentFriendId,
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
      _scrollController.animateTo(
        0,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
      // messageBodyTextController.text = "";
    }
    isLoading = false;
    setState(() {
      // getMessages(false);
      //messageBodyTextController.text = "";
    });
  }

  void goBackToFriendsPage() {
    Navigator.of(context).pop();
  }

  /*void sendFileMessage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => UploadFile()));
  }
*/
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
