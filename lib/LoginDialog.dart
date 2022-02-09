import 'package:flutter/material.dart';
import 'AdminPage.dart';
import 'AppParameters.dart';

class LoginDialog {
  showNetworkImage(String address, BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          txtUserNameController.text = AppParameters.currentUser;
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                  width: 2.0, color: AppParameters.titlesForegroundColor),
            ),
            elevation: 16,
            backgroundColor: AppParameters.titlesBackgroundColor,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.network(address),
              ),
            ),
          );
        });
  }

  final txtUserNameController = TextEditingController();
  final txtPasswordController = TextEditingController();
  final txtformMessageController = TextEditingController();
  String contentText = "شروع";

  showLoginDialog(BuildContext context) {
    txtformMessageController.text = "وارد حساب خود شوید";
    showDialog(
        context: context,
        builder: (context) {
          txtUserNameController.text = AppParameters.currentUser;
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                    width: 4.0, color: AppParameters.titlesForegroundColor),
              ),
              elevation: 16,
              backgroundColor: AppParameters.titlesBackgroundColor,
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
                                if (txtUserNameController.text == "admin" &&
                                    txtPasswordController.text == "470125") {
                                  await Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => AdminPage()));
                                  Navigator.of(context).pop();
                                } else {
                                  setState(() {
                                    txtformMessageController.text =
                                        "دوباره تلاش کنید";
                                    // txtUserNameController.text = "?";
                                  });
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
                                  color: AppParameters.titlesForegroundColor,
                                  fontSize: AppParameters.messageFontSize,
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
