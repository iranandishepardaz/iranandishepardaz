import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'ApcoUtils.dart';
import 'ChatPageAppBar.dart';
import 'FriendsPageDrawer.dart';
import 'MessageBubble.dart';
import 'MessageEditor.dart';
import 'PersianDateUtil.dart';
import 'TempMessages.dart';
import 'AppParameters.dart';
import 'package:flutter/material.dart';
import 'ApMeMessages.dart';
import 'AppSettings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:async/async.dart';

class ChatPage extends StatefulWidget {
  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  String textToSend = "";
  RestartableTimer? _refreshTimer;
  final dataKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  List<ApMeMessage> allMessages = [];
  int messagesToShowCount = 30;
  late List<MessageBubble> allMessageBubbles;
  List<TempMessage> tempMessages = [];
  final messageBodyTextController = TextEditingController();
  ApMeMessage? currentMessage;
  int currentBubbleId = -1;
  int charCount = 0;
  bool isLoading = false;
  bool isEditing = false;
  bool canSendImage = AppParameters.currentUser == 'sepehr';
  @override
  void initState() {
    super.initState();
    AppParameters.currentPage = "ChatPage";
    // WidgetsBinding.instance.addObserver(this);
    initialize();
  }

  void initialize() async {
    messageBodyTextController.addListener(_adjustMessageBodyTextField);
    _refreshTimer =
        RestartableTimer(AppParameters.chatRefreshPeriod, refreshMessages);
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels == 0) {
          //  getUnsynced();
          debugPrint('Grid scroll at top');
        } else {
          debugPrint('Grid scroll at bottom');
          debugPrint("${PersianDateUtil.now()} Refresh by pull ...");
          _scrollController.animateTo(
            0,
            duration: const Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
          );
          messagesToShowCount += 20;
          getUnsynced();
        }
      }
    });
    refreshMessages();
  }

  Future<bool> _onWillPopSimple() async {
    backToFriendsPage();
    return false;
  }

  void backToFriendsPage() {
    try {
      _refreshTimer!.cancel();
    } catch (exp) {}
    try {
      Navigator.of(context).pop();
    } catch (exp) {}
  }

  @override
  Widget build(BuildContext context) {
    //check what if I delete these 3 lines!!
    /*if (!AppParameters.authenticated) {
      backToFriendsPage();
    }*/
    return WillPopScope(
      onWillPop: _onWillPopSimple,
      child: RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          onRefresh: () {
            debugPrint(PersianDateUtil.now() + " Refresh by pull ...");
            //   getUnsynced();
            return Future.delayed(Duration(seconds: 2), () {});
          },
          child: Scaffold(
            appBar: ChatAppBar(this).appBar(),
            body: SafeArea(
                child: Container(
              color: AppSettings.formsBackgroundColor,
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
                              debugPrint("load more messages from web");
                              //must first gret local messages
                              timeLimit = allMessages.isNotEmpty
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
                            color: AppSettings.formsForegroundColor,
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 20.0),
                          children: allMessages.isEmpty
                              ? [
                                  IconButton(
                                    onPressed: () async {
                                      await ApMeMessages
                                          .getPartnerMessagesBeforeFromWeb(
                                              messagesToShowCount, false, 0);
                                    },
                                    icon: const Icon(Icons.download),
                                    color: AppSettings.formsForegroundColor,
                                  ),
                                  Center(
                                    child: Text(
                                      "هنوز پیامی فرستاده نشده\n\r اولین پیام را بفرستید",
                                      style: TextStyle(
                                          color:
                                              AppSettings.formsForegroundColor,
                                          fontSize:
                                              AppSettings.messageBodyFontSize),
                                    ),
                                  )
                                ]
                              : allMessageBubbles, // generateBubbles(),
                        ),
                        onNotification: (notification) {
                          //How many pixels scrolled from pervious frame
                          debugPrint("Scroll Delta:" +
                              notification.scrollDelta.toString());

                          //List scroll position
                          debugPrint("Scroll Pixels:" +
                              notification.metrics.pixels.toString());
                          if (notification.metrics.pixels > 50) {
                            //    messagesToShowCount += 20;
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
                          color: AppSettings.titlesBackgroundColor,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          border: Border(
                              top: BorderSide(
                                  color: AppSettings.formsForegroundColor),
                              bottom: BorderSide(
                                  color: AppSettings.formsForegroundColor),
                              left: BorderSide(
                                  color: AppSettings.formsForegroundColor),
                              right: BorderSide(
                                  color: AppSettings.formsForegroundColor)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 80,
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: TextField(
                                    style: TextStyle(
                                        color:
                                            AppSettings.titlesForegroundColor,
                                        fontSize:
                                            AppSettings.messageBodyFontSize),
                                    cursorColor:
                                        AppSettings.titlesForegroundColor,
                                    cursorHeight:
                                        AppSettings.messageBodyFontSize * 2,
                                    textAlign: TextAlign.right,
                                    onTap: () {
                                      //this is for solving a buges in edit the last character
                                      if (messageBodyTextController.text
                                              .substring(
                                                  messageBodyTextController
                                                          .text.length -
                                                      1) !=
                                          " ") {
                                        messageBodyTextController.text += " ";
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: '',
                                      hintStyle: TextStyle(
                                          color: AppSettings
                                              .disabledForegroundColor,
                                          fontSize:
                                              AppSettings.messageBodyFontSize),
                                      contentPadding: EdgeInsets.all(4),
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
                                      child: Icon(Icons.attach_file,
                                          color: AppSettings
                                              .titlesForegroundColor))),
                            ),
                            Expanded(
                                flex: 10,
                                child: TextButton(
                                    onPressed: () {
                                      if (AppParameters.networkOK) {
                                        sendTextMessage();
                                        _scrollController.animateTo(
                                          0,
                                          duration: Duration(seconds: 2),
                                          curve: Curves.fastOutSlowIn,
                                        );
                                      } else
                                        ApcoUtils.showSnackMessage(
                                            "ارتباط با سرور برقرار نیست شبکه را چک کنید",
                                            context);
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.send,
                                          color: AppParameters.networkOK
                                              ? AppSettings
                                                  .titlesForegroundColor
                                              : Colors.red,
                                        ),
                                        Visibility(
                                          visible: charCount > 100,
                                          child: Text(
                                            charCount.toString(),
                                            style: TextStyle(
                                                fontSize: AppSettings
                                                    .messageDateFontSize,
                                                color: AppSettings
                                                    .titlesForegroundColor),
                                          ),
                                        ),
                                      ],
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
            endDrawer: FriendsPageDrawer.sideDrawer(this),
          )),
    );
  }

  callback(parameter) {
    setState(() {
      messageBodyTextController.text = parameter;
    });
  }

  double _inputHeight = (4 * AppSettings.messageBodyFontSize) as double;

  void _adjustMessageBodyTextField() async {
    AppParameters.lastUserActivity = DateTime.now();
    int lines = messageBodyTextController.text.split('\n').length;
    charCount = messageBodyTextController.text.length;
    int charlines = charCount ~/ 60;
    if (lines == 1) lines++;
    lines += charlines + 1;

    if (lines > 6) lines = 6;
    //var newHeight = count == 0 ? 40.0 : 40.0 + (count * _lineHeight);
    double newHeight = (lines * AppSettings.messageBodyFontSize +
        (AppSettings.messageBodyFontSize * 0.75)) as double;
    if (_inputHeight != newHeight || charCount > 100)
      setState(() {
        _inputHeight = newHeight;
      });
  }

  editMessage(int bubbleID) async {
    currentMessage = allMessageBubbles[bubbleID].currentMessage;
    //currentMessage = new ApMeMessage();
    //currentMessage.messageId = tmp.messageId;
    //currentMessage.messageBody = tmpMessage.messageBody;

    //await ApcoMessageBox().showMessageToEdit(currentMessage, currentMessage.fullUrl, this.context);
    ResultEnums result = ResultEnums.Unknown;

    await MessageEditor()
        .messageEditor(currentMessage!, this.context)
        .then((value) async {
      String strValue = value.toString();
      strValue = strValue.substring(
          strValue.indexOf("'") + 1, strValue.lastIndexOf("'"));
      result = strValue.toResultEnm();
      debugPrint("Dialog result:" + value.toString());
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
      if (strValue.length > 0) ApcoUtils.showSnackMessage(strValue, context);
    });

    /*if (editted. )
      setState(() {
        generateBubbles();
      });*/
  }

  void refreshMessages() async {
    if (AppParameters.currentPage != "ChatPage") {
      _refreshTimer!.cancel();
      debugPrint(PersianDateUtil.now() + " Chat page Refreshing terminated.");
    } else {
      if (isLoading) {
        debugPrint(PersianDateUtil.now() + " Chat page Refreshing cancelled.");
      } else {
        await getUnsynced();
      }
      _refreshTimer!.reset();
    }
  }

  Future<void> getUnsynced() async {
    isLoading = true;
    debugPrint(PersianDateUtil.now() + " Chat page Refreshing...");
    setState(() {});
    await ApMeMessages.getUnsyncedMessagesFromWeb();
    allMessages =
        await ApMeMessages.getLocalFriendMessages(messagesToShowCount);
    await generateBubbles();
    setState(() {
      debugPrint(PersianDateUtil.now() + " Chat page Refreshed.");
    });
    _refreshTimer!.reset();
    setState(() {
      isLoading = false;
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
      debugPrint(PersianDateUtil.now() + " More messages got from web.");
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
      debugPrint(PersianDateUtil.now() + " More messages got from web.");
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
      debugPrint(PersianDateUtil.now() + " Chat page refresh done.");
    });
    //_startTimer();
  }

  Future<void> generateBubbles() async {
    allMessages =
        await ApMeMessages.getLocalFriendMessages(messagesToShowCount);
    allMessageBubbles = List.generate(allMessages.length, (int index) {
      return MessageBubble(allMessages[index], this, dataKey, index, () {});
    });
    setState(() {});

    //return allMessageBubbles;
  }

  Future<bool> editTextMessage() async {
    isEditing = false;
    if (textToSend.isEmpty) return await deleteTextMessage();
    isLoading = true;
    String tmpText = textToSend;
    textToSend = "";
    currentMessage = allMessageBubbles[currentBubbleId].currentMessage;
    currentMessage!.messageBody = tmpText;
    ApMeMessage? editedMessage =
        await ApMeMessages.editMessage(currentMessage!);
    messageBodyTextController.clear();

    if (editedMessage != null) {
      setState(() {
        allMessageBubbles[currentBubbleId].currentMessage.update();
        ApcoUtils.showSnackMessage("ویرایش شد", context);
        generateBubbles();
        //allMessageBubbles[currentBubbleId].currentMessage.messageBody =
        //    editedMessage.messageBody;
        //allMessageBubbles[currentBubbleId].function();
      });

      //this._showToast(context);
    } else {
      ApcoUtils.showSnackMessage("پیام قابل ویرایش نیست!", context);
    }
    isLoading = false;
    return true;
  }

  Future<bool> deleteTextMessage() async {
    isLoading = true;
    isEditing = false;
    textToSend = "";
    currentMessage = allMessageBubbles[currentBubbleId].currentMessage;
    ApMeMessage? deletedMessage =
        await ApMeMessages.deleteMessage(currentMessage!);
    messageBodyTextController.clear();

    if (deletedMessage != null) {
      allMessageBubbles[currentBubbleId].currentMessage.delete();
      ApcoUtils.showSnackMessage("حذف شد!", context);
    } else {
      ApcoUtils.showSnackMessage("قابل حذف نیست!", context);
    }
    isLoading = false;
    return true;
  }

  Future<bool> sendTextMessage() async {
    if (textToSend.length == 0) return await deleteTextMessage();
    if (isEditing) return editTextMessage();
    bool messageSent = false;
    String tmpText = textToSend;
    textToSend = "";
    isLoading = true;
    ApMeMessage? sentMessage = await ApMeMessages.sendTextMessage(tmpText);
    // messageBodyTextController.text = ""; //.clear();

    if (sentMessage != null) {
      allMessages.add(sentMessage);
      await getUnsynced();
      generateBubbles();
      messageSent = true;
    } else {
      textToSend = tmpText;
      //messageBodyTextController.text = tmpText;
      String strMes = "پیام فرستاده نشد ";
      if (charCount > 800) strMes = "پیام طولانی است آنرا تقسیم بندی کنید";
      ApcoUtils.showSnackMessage(strMes, context);

/*
// Save To TempMessages to send later

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
      );*/
      // messageBodyTextController.text = "";
    }
    isLoading = false;
    if (messageSent)
      setState(() {
        // getMessages(false);
        messageBodyTextController.text = "";
      });
    return true;
  }

  //late final file;

  void sendFileMessage() async {
    //if (textToSend.length == 0) return deleteTextMessage();
    //if (isEditing) return editTextMessage();

    String tmpText = textToSend;
    textToSend = "";
    isLoading = true;
    if (tmpText == "") tmpText = "عکس";
    File _image;
    final picker = ImagePicker();
    final PickedFile? pickedFile =
        await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
    final File file = File(pickedFile!.path);
    String fileType = file.path.split('.').last;
    String base64Image = base64Encode(file.readAsBytesSync());
    ApMeMessage? sentMessage =
        await ApMeMessages.sendFileMessage(tmpText, fileType, base64Image);
    /*
    final picker = ImagePicker();
    final file = await picker.getImage(source: ImageSource.gallery);
    String fileType = file!.path.split('.').last;
    String base64Image = base64Encode(file.readAsBytesSync());
    ApMeMessage? sentMessage =
        await ApMeMessages.sendFileMessage(tmpText, fileType, base64Image);
    // messageBodyTextController.text = ""; //.clear();
*/
    if (sentMessage != null) {
      allMessages.add(sentMessage);
      await getUnsynced();
      await generateBubbles();
    } else {
      TempMessage tempMessage = TempMessage(
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

  void scrollToLastMessage() {
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
