import 'dart:async';

import 'package:ap_me/ApMeMessages.dart';
import 'package:ap_me/AppSettings.dart';
import 'package:flutter/material.dart';

import 'AppParameters.dart';

class ApcoMessageBox {
  final messageBodyTextController = TextEditingController();
  final txtPasswordController = TextEditingController();
  final txtformMessageController = TextEditingController();
  static ApMeMessage currentMessage = ApMeMessage();
  static BuildContext currentContext;
  String contentText = "شروع";
  showMessage(
      ApMeMessage current_Message, String imageAddress, BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          currentMessage = current_Message;
          messageBodyTextController.text = currentMessage.messageBody;
          currentContext = context;
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                  width: 2.0, color: AppSettings.titlesForegroundColor),
            ),
            elevation: 16,
            backgroundColor: AppSettings.titlesBackgroundColor,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    imageAddress.length > 0
                        ? Image.network(imageAddress)
                        : Center(),
                    Material(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      elevation: 5.0,
                      color: Colors.grey[200],
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: messageBodyTextController,
                        decoration: InputDecoration(hintText: ""),
                        //onChanged: (value) {
                        //  AppParameters.currentUser = value.toLowerCase();
                        //},
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Material(
                          elevation: 20,
                          borderRadius: BorderRadius.circular(40),
                          color: Colors.red[400],
                          child: InkWell(
                            onTap: () async {
                              //Do Somthing
                            },
                            child: Container(
                              height: 50,
                              width: 150,
                              child: Center(
                                child: Text(
                                  "ورود",
                                  style: TextStyle(
                                      fontFamily: "Vazir",
                                      color: Colors.white,
                                      fontSize: 25),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(txtformMessageController.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppSettings.titlesForegroundColor,
                                fontSize: AppSettings.messageBodyFontSize,
                              )),
                        ]),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<bool> showMessageToEdit(
      ApMeMessage message, String imageAddress, BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          currentMessage = message;
          messageBodyTextController.text = currentMessage.messageBody;
          currentContext = context;
          return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                    width: 2.0, color: AppSettings.titlesForegroundColor),
              ),
              elevation: 16,
              backgroundColor: AppSettings.formsBackgroundColor,
              child: Column(
                children: [
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
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                    decoration: InputDecoration(
                                      hintText: 'پیام خود را بنویسید',
                                      hintStyle: TextStyle(
                                          color:
                                              AppSettings.sentMessageForeColor,
                                          fontSize:
                                              AppSettings.messageBodyFontSize),
                                      contentPadding: EdgeInsets.all(2),
                                    ),
                                    maxLines: null,
                                    controller: messageBodyTextController,
                                    onChanged: (value) {
                                      // textToSend = value;
                                    },
                                  ),
                                )),

                            //it will add to attach file
                          ],
                        )),
                  ),
                  /*     Expanded(
                    flex: 4,
                    child: TextField(
                      style: AppSettings.messageEditStyle,
                      maxLines: null,
                      expands: true,
                      controller: messageBodyTextController,
                    ),
                  ),
                  Expanded(
                      flex: 4,
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextField(
                          style: TextStyle(
                              color: AppSettings.titlesForegroundColor,
                              fontSize: AppSettings.messageBodyFontSize),
                          cursorColor: AppSettings.titlesForegroundColor,
                          cursorHeight: AppSettings.messageBodyFontSize * 2,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'پیام خود را بنویسید',
                            hintStyle: TextStyle(
                                color: AppParameters.sentMessageForeColor,
                                fontSize: AppSettings.messageBodyFontSize),
                            contentPadding: EdgeInsets.all(2),
                          ),
                          maxLines: null,
                          controller: messageBodyTextController,
                          onChanged: (value) {
                            // textToSend = value;
                          },
                        ),
                      )),
               */
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () async {
                                bool done = await editTextMessage();
                                if (done) {
                                  return true;
                                  //Navigator.pop(currentContext);
                                } else {}
                              },
                              icon: Icon(Icons.check)),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.delete),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.copy),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.cancel),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )

              /* ListView(
                children: [
                  TextField(
                     maxLines: null,
                    minLines: null,
                    expands: true,
                    controller: txtUserNameController,
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.delete),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.copy),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.forward),
                      ),
                    ],
                  )
                ],
              )*/
              );
        });
  }

  double _inputHeight = (5.5 * AppSettings.messageBodyFontSize);

  Future<double> _adjustMessageBodyTextField() async {
    int count = messageBodyTextController.text.split('\n').length;
    if (count < 6) {
      //var newHeight = count == 0 ? 40.0 : 40.0 + (count * _lineHeight);
      var newHeight = (count + 1) * 2 * AppSettings.messageBodyFontSize;
      // setState(() {
      _inputHeight = newHeight;
      //});
    }
    return _inputHeight;
  }

  Future<bool> editTextMessage() async {
    //  if (txtUserNameController.text.length == 0) return deleteTextMessage();
    currentMessage.messageBody = messageBodyTextController.text;
    ApMeMessage editedMessage = await ApMeMessages.editMessage(currentMessage);
    if (editedMessage != null) {
      await editedMessage.update();
      return true;
    } else {
      return false;
    }
  }
}
