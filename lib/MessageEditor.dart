import 'ApcoUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'AdminPage.dart';
import 'ApMeMessages.dart';
import 'AppParameters.dart';
import 'AppSettings.dart';

class MessageEditor {
  final messageBodyTextController = TextEditingController();
  final txtformMessageController = TextEditingController();
  static ApMeMessage currentMessage = ApMeMessage();
  static late BuildContext currentContext;
  String contentText = "شروع";
  bool done = false;
  Key result = Key("Start");
  messageEditor(ApMeMessage message, BuildContext context) async {
    currentContext = context;
    currentMessage = message;
    await showDialog(
        builder: (currentContext) {
          messageBodyTextController.text = currentMessage.messageBody;
          return Dialog(
            key: result,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                  width: 2.0, color: AppSettings.titlesForegroundColor),
            ),
            elevation: 16,
            backgroundColor: AppSettings.formsBackgroundColor,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                    height: (currentMessage.fullUrl.length > 0
                                ? _inputHeight * 2.5
                                : _inputHeight) *
                            2 +
                        10 +
                        AppParameters.iconsSize * 1.5,
                    child: Column(
                      children: [
                        currentMessage.fullUrl.length > 0
                            ? Container(
                                height: _inputHeight * 1.5,
                                child: Image.network(currentMessage.fullUrl))
                            : Center(),
                        currentMessage.fullUrl.length > 0
                            ? SizedBox(
                                height: 5,
                              )
                            : Center(),
                        Container(
                            height: currentMessage.fullUrl.length > 0
                                ? _inputHeight
                                : _inputHeight * 2,
                            decoration: BoxDecoration(
                              color: AppSettings.sentMessageBackColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              border: Border.all(
                                  color: AppSettings.formsForegroundColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    flex: 70,
                                    child: Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: TextField(
                                        style: TextStyle(
                                            color: AppSettings
                                                .titlesForegroundColor,
                                            fontSize: AppSettings
                                                .messageBodyFontSize),
                                        cursorColor:
                                            AppSettings.titlesForegroundColor,
                                        cursorHeight:
                                            AppSettings.messageBodyFontSize * 2,
                                        textAlign: TextAlign.right,
                                        decoration: InputDecoration(
                                          hintText:
                                              'پیام خالی به معنای حذف پیام خواهد بود',
                                          hintStyle: TextStyle(
                                              color: AppSettings
                                                  .sentMessageForeColor,
                                              fontSize: AppSettings
                                                  .messageBodyFontSize),
                                          contentPadding: EdgeInsets.all(2),
                                        ),
                                        maxLines: null,
                                        controller: messageBodyTextController,
                                        onChanged: (value) {
                                          // textToSend = value;
                                        },
                                      ),
                                    )),
                              ],
                            )),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                            height: AppParameters.iconsSize * 1.5,
                            decoration: BoxDecoration(
                              color: AppSettings.receivedMessageBackColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              border: Border.all(
                                  color: AppSettings.formsForegroundColor),
                            ),
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 50,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AppParameters.currentUser == "akbar"
                                              ? IconButton(
                                                  onPressed: () async {
                                                    ResultEnums res =
                                                        await editDeliveredMessage();
                                                    result =
                                                        Key(res.toString());
                                                    Navigator.pop(
                                                        currentContext);
                                                  },
                                                  icon:
                                                      Icon(Icons.edit_outlined),
                                                  color: AppSettings
                                                      .sentDeliveredMessageForeColor,
                                                )
                                              : IconButton(
                                                  onPressed: () async {
                                                    ResultEnums res =
                                                        await editMessage();
                                                    result =
                                                        Key(res.toString());
                                                    Navigator.pop(
                                                        currentContext);
                                                  },
                                                  icon: Icon(Icons.check),
                                                  color: AppSettings
                                                      .sentDeliveredMessageForeColor,
                                                ),
                                          IconButton(
                                            onPressed: () async {
                                              ResultEnums res =
                                                  await deleteMessage();
                                              result = Key(res.toString());
                                              Navigator.pop(currentContext);
                                            },
                                            icon: Icon(Icons.delete),
                                            color: AppSettings
                                                .sentDeliveredMessageForeColor,
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(
                                                  text:
                                                      messageBodyTextController
                                                          .text));
                                              result = Key(ResultEnums
                                                      .Copied_to_Clipboard
                                                  .toString());
                                              Navigator.pop(currentContext);
                                            },
                                            icon: Icon(Icons.copy),
                                            color: AppSettings
                                                .sentDeliveredMessageForeColor,
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              result = Key(ResultEnums.Cancelled
                                                  .toString());
                                              Navigator.of(context).pop();
                                            },
                                            icon: Icon(Icons.undo),
                                            color: AppSettings
                                                .sentDeliveredMessageForeColor,
                                          ),
                                          /*
                                          IconButton(
                                            onPressed: () async {
                                              ResultEnums res =
                                                  await deleteDeliveredMessage();
                                              result = Key(res.toString());
                                              Navigator.pop(currentContext);
                                            },
                                            icon: Icon(Icons.delete_forever),
                                            color: AppParameters
                                                .formsForegroundColor,
                                          ),
                                          */
                                        ],
                                      ),
                                    ),
                                  ),
                                  //it will add to attach file
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),

                //Image.network(currentMessage.fullUrl),
              ),
            ),
          );
        },
        context: currentContext);
    return result;
  }

  double _inputHeight = (5.5 * AppSettings.messageBodyFontSize);

  Future<double> _messageBodyTextFieldHeight() async {
    int count = messageBodyTextController.text.split('\n').length;
    if (count < 6) {
      //var newHeight = count == 0 ? 40.0 : 40.0 + (count * _lineHeight);
      double newHeight =
          ((count + 1) * 2 * AppSettings.messageBodyFontSize) as double;
      // setState(() {
      _inputHeight = newHeight;
      //});
    }
    return _inputHeight;
  }

  Future<ResultEnums> editMessage() async {
    //  if (txtUserNameController.text.length == 0) return deleteTextMessage();
    if (currentMessage.messageBody == messageBodyTextController.text)
      return ResultEnums.Cancelled;
    currentMessage.messageBody = messageBodyTextController.text;
    if (currentMessage.messageBody.length == 0) return await deleteMessage();
    ApMeMessage? editedMessage = await ApMeMessages.editMessage(currentMessage);
    if (editedMessage != null) {
      await editedMessage.update();
      return ResultEnums.OK_Editted;
    } else {
      return ResultEnums.Error_Editting;
    }
  }

  Future<ResultEnums> editDeliveredMessage() async {
    //  if (txtUserNameController.text.length == 0) return deleteTextMessage();
    if (currentMessage.messageBody == messageBodyTextController.text)
      return ResultEnums.Cancelled;
    currentMessage.messageBody = messageBodyTextController.text;
    if (currentMessage.messageBody.length == 0) return await deleteMessage();
    ApMeMessage? editedMessage =
        await ApMeMessages.editDeliveredMessage(currentMessage);
    if (editedMessage != null) {
      await editedMessage.update();
      return ResultEnums.OK_Editted;
    } else {
      return ResultEnums.Error_Editting;
    }
  }

  Future<ResultEnums> deleteMessage() async {
    ResultEnums output = await ApcoUtils.apcoShowDialog(
        currentContext, "آیا از حذف این پیام اطمینان دارید؟",
        yesKeyText: "آری");
    if (output == ResultEnums.Yes) {
      ApMeMessage? messageToDelete =
          await ApMeMessages.deleteMessage(currentMessage);

      if (messageToDelete != null) {
        if (messageToDelete.deleted == 0) {
          await messageToDelete.delete();
          output = ResultEnums.OK_Deletted;
        } else {
          await messageToDelete.update();
          output = ResultEnums.OK_MarkedDeleted;
        }
      } else {
        output = ResultEnums.Error_Deletting;
      }
    } else if (output == ResultEnums.No) {
      output = ResultEnums.Cancelled;
    }
    return output;
  }

  Future<ResultEnums> deleteMessage1() async {
    ResultEnums output = ResultEnums.Unknown;
    AlertDialog dialog = AlertDialog(
      backgroundColor: AppSettings.titlesBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
            width: 2.0, color: AppSettings.sentDeliveredMessageForeColor),
      ),
      elevation: 16,
      title: Text(
        "از حذف این پیام اطمینان دارید؟",
        textAlign: TextAlign.center,
        style: TextStyle(
            color: AppSettings.titlesForegroundColor,
            backgroundColor: AppSettings.titlesBackgroundColor,
            fontSize: AppSettings.messageBodyFontSize * 1.2),
      ),
      content: Container(
        height: 70,
        child: Container(
          color: AppSettings.titlesBackgroundColor,
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: AppSettings.formsForegroundColor),
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Material(
                  elevation: 20,
                  borderRadius: BorderRadius.circular(40),
                  color: AppSettings.formsBackgroundColor,
                  child: InkWell(
                    onTap: () async {
                      Navigator.of(currentContext).pop();
                    },
                    child: Container(
                      height: 50,
                      width: 80,
                      child: Center(
                        child: Text(
                          "بلی",
                          style: TextStyle(
                              fontFamily: "Vazir",
                              color: AppSettings.formsForegroundColor,
                              fontSize: AppSettings.messageBodyFontSize * 1.2),
                        ),
                      ),
                    ),
                  ),
                ),
                Material(
                  elevation: 20,
                  borderRadius: BorderRadius.circular(40),
                  color: AppSettings.formsBackgroundColor,
                  child: InkWell(
                    onTap: () async {
                      Navigator.of(currentContext).pop();
                    },
                    child: Container(
                      height: 50,
                      width: 80,
                      child: Center(
                        child: Text(
                          "خیر",
                          style: TextStyle(
                              fontFamily: "Vazir",
                              color: AppSettings.formsForegroundColor,
                              fontSize: AppSettings.messageBodyFontSize * 1.2),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_forever),
                  color: AppSettings.formsForegroundColor,
                  onPressed: () async {
                    ApMeMessage? messageToDelete =
                        await ApMeMessages.deleteMessage(currentMessage);

                    if (messageToDelete != null) {
                      if (messageToDelete.deleted == 0) {
                        await messageToDelete.delete();
                        output = ResultEnums.OK_Deletted;
                      } else {
                        await messageToDelete.update();
                        output = ResultEnums.OK_MarkedDeleted;
                      }
                    } else {
                      output = ResultEnums.Error_Deletting;
                    }
                    Navigator.of(currentContext).pop();
                  },
                ),
                IconButton(
                  onPressed: () {
                    output = ResultEnums.Cancelled;
                    Navigator.of(currentContext).pop();
                  },
                  icon: Icon(
                    Icons.undo,
                    color: AppSettings.formsForegroundColor,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
    await showDialog(
        context: currentContext,
        barrierDismissible: false,
        builder: (_) => dialog);
    return output;
  }

  Future<ResultEnums> deleteDeliveredMessage() async {
    ApMeMessage? messageToDelete =
        await ApMeMessages.deleteDeliveredMessage(currentMessage);
    if (messageToDelete != null) {
      await messageToDelete.delete();
      return ResultEnums.OK_Deletted;
    } else {
      return ResultEnums.Error_Deletting;
    }
  }
}
