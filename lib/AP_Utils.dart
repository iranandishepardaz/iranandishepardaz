import 'package:flutter/material.dart';
//import 'AppParameters.dart';
//import 'AppSettings.dart';

class AP_DialogBox {
  static final txtUserNameController = TextEditingController();
  static final txtPasswordController = TextEditingController();
  static final txtformMessageController = TextEditingController();
  String contentText = "شروع";

  static showDialogBox(BuildContext theContext, Function todoFunction) {
    txtformMessageController.text = "اطمینان دارید؟";
    showDialog(
        context: theContext,
        builder: (theContext) {
          txtUserNameController.text = ""; // AppParameters.currentUser;
          return StatefulBuilder(builder: (theContext, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(width: 4.0, color: Colors.white),
              ),
              elevation: 16,
              backgroundColor: Colors.lightBlue,
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Material(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        elevation: 5.0,
                        color: Colors.grey[200],
                        child: TextField(
                          textAlign: TextAlign.center,
                          controller: txtUserNameController,
                          decoration: InputDecoration(hintText: "نام کاربری"),
                          //onChanged: (value) {
                          //  AppParameters.currentUser = value.toLowerCase();
                          //},
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Material(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        elevation: 5.0,
                        color: Colors.grey[200],
                        child: TextField(
                          textAlign: TextAlign.center,
                          cursorColor: Colors.grey,
                          controller: txtPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(hintText: "رمز عبور"),
                          //onChanged: (value) {
                          //  AppParameters.currentPassword = value;
                          //},
                        ),
                      ),
                      const SizedBox(
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
                                if (true) {
                                  await todoFunction();
                                  Navigator.of(theContext).pop();
                                }
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
                                  color: Colors.yellow,
                                  fontSize: 14,
                                )),
                          ]),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }
}
