import 'package:ap_me/FriendsPage.dart';

import 'ApMeUtils.dart';
import 'AppParameters.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'MainPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  String formMessage = "";
  bool isLoading = false;
  @override
  void initState() {
    userNameController.text = AppParameters.currentUser;
    passwordController.text = AppParameters.currentPassword;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.green[100],
      body: Center(
        child: Container(
          width: 300,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Material(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  elevation: 5.0,
                  color: Colors.grey[200],
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: userNameController,
                    decoration: InputDecoration(hintText: "نام کاربری"),
                    onChanged: (value) {
                      AppParameters.currentUser = value.toLowerCase();
                    },
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
                    controller: passwordController,                                    
                    obscureText: true,
                    decoration: InputDecoration(hintText: "رمز عبور"),
                    onChanged: (value) {
                      AppParameters.currentPassword = value;
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Visibility(
                  child: CircularProgressIndicator(),
                  visible: isLoading,
                ),
                Visibility(
                  visible: !isLoading,
                  child: Padding(
                    padding: EdgeInsets.only(left: 50, right: 50),
                    child: Material(
                      elevation: 20,
                      borderRadius: BorderRadius.circular(40),
                      color: Colors.red[400],
                      child: InkWell(
                        onTap: doLogin,
                        child: Container(
                          height: 50,
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
                  ),
                ),
                Text(formMessage,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 15,
                    )),
              ]),
        ),
      ),
    );
  }

 void doLogin() async {
    setState(() {
      isLoading = true;
      formMessage = "...";
    });
    List<String> result = await Future.any([
      ApMeUtils.getUserInfo(),
    ]);
    setState(() {
      isLoading = false;    
    if (result.length > 1)
    {
      AppParameters.firstName=result[1];
      AppParameters.lastName =result[2];
      AppParameters.prefix = result[3] == "True"? "آقای" : "خانم" ;
      formMessage = AppParameters.prefix + " " + AppParameters.firstName + " " + AppParameters.lastName + " خوش آمدید";
     
     Future.delayed(const Duration(seconds: 1),(){ Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => FriendsPage()));
    });
    }
    else {              
        if (result[0] == "-1") formMessage = "نام کاربری یا گذرواژه درست نیست";
        if (result[0] == "-2") formMessage = "دسترسی به اینترنت را چک کنید";
      }});
    }
  }

