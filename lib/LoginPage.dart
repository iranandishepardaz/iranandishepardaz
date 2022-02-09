import 'package:ap_me/AppSettings.dart';
import 'package:ap_me/FriendsPage.dart';
import 'package:flutter/services.dart';

import 'ApMeUtils.dart';
import 'AppParameters.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get_version/get_version.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final txtUserNameController = TextEditingController();
  final txtPasswordController = TextEditingController();
  String formMessage = "...";
  bool isLoading = false;

  bool _canCheckBiometric = false;
  List<BiometricType> _availableBiometrics = [];
  String _autherized = "Not Autherized";
  LocalAuthentication auth = LocalAuthentication();

  Future<void> _checkBiometrics() async {
    bool canCheckBiometric = false;
    try {
      canCheckBiometric = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print("Error: $e");
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometric = canCheckBiometric;
    });
  }

  Future<void> _getAvailableBiometric() async {
    List<BiometricType> availableBiometrics = [];
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  void _getVer() async {
    try {
      formMessage = await GetVersion.projectVersion;
      formMessage = "Version : " + formMessage;
    } on PlatformException {
      formMessage = 'Failed to get platform version.';
    }
    //setState(() {});
  }

  Future<void> _authenticate() async {
    bool authenticated = false;

    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: "حسگر را لمس کنید",
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
    _autherized = authenticated ? "Autherized success" : "Failed to Autherize";

    print(_autherized);
    if (authenticated) {
      txtUserNameController.text = AppParameters.lastLoggedUser;
      txtPasswordController.text = await AppParameters.getlastLoggedPassword();
      doLogin();
    }
  }

  @override
  void initState() {
    txtUserNameController.text = AppParameters.lastLoggedUser;
    _checkBiometrics();
    _getAvailableBiometric();
    _getVer();
    //passwordController.text = AppParameters.currentPassword;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      backgroundColor: AppParameters.formsBackgroundColor,
      body: Center(
        child: isPortrait
            ? Container(
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
                                width: 150,
                                child: Center(
                                  child: Text(
                                    "ورود",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: "Vazir",
                                      color: Colors.white,
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        child: IconButton(
                            iconSize: 70,
                            onPressed: _authenticate,
                            color: Colors.blue,
                            icon: Icon(Icons.fingerprint_outlined)),
                        visible: _canCheckBiometric,
                      ),
                      Text(formMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppParameters.formsForegroundColor,
                            fontSize: AppParameters.messageFontSize,
                          )),
                    ]),
              )
            : Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 4,
                              child: Material(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                                elevation: 5.0,
                                color: Colors.grey[200],
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  controller: txtUserNameController,
                                  decoration:
                                      InputDecoration(hintText: "نام کاربری"),
                                  //      onChanged: (value) {
                                  //        AppParameters.currentUser =
                                  //            value.toLowerCase();
                                  //      },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Material(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                                elevation: 5.0,
                                color: Colors.grey[200],
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  cursorColor: Colors.grey,
                                  controller: txtPasswordController,
                                  obscureText: true,
                                  decoration:
                                      InputDecoration(hintText: "رمز عبور"),
                                  //      onChanged: (value) {
                                  //        AppParameters.currentPassword = value;
                                  //      },
                                ),
                              ),
                            ),
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                              ),
                            ),
                            Text(formMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppParameters.formsForegroundColor,
                                  fontSize: AppParameters.messageFontSize,
                                )),
                          ]),
                    ]),
              ),
      ),
    );
  }

  void doLogin() async {
    AppParameters.pausedSeconds = 0;
    setState(() {
      isLoading = true;
      AppParameters.currentUser =
          txtUserNameController.text.toLowerCase().trimLeft().trimRight();
      AppParameters.currentPassword = txtPasswordController.text;
      txtPasswordController.text = "";
      formMessage = "...";
    });
    List<String> result = await Future.any([
      ApMeUtils.getUserInfo(),
    ]);
    setState(() {
      isLoading = false;
      if (result.length > 1) {
        AppParameters.firstName = result[1];
        AppParameters.lastName = result[2];
        AppParameters.prefix = result[3] == "True" ? "آقای" : "خانم";
        formMessage = AppParameters.prefix +
            " " +
            AppParameters.firstName +
            " " +
            AppParameters.lastName +
            " خوش آمدید";
        Future.delayed(const Duration(seconds: 1), () async {
          AppSetting(
                  settingName: "lastUser",
                  settingValue: AppParameters.currentUser)
              .insert();

          AppSetting(
                  settingName: "lastLoggedPassword",
                  settingValue: AppParameters.currentPassword)
              .insert();

          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => FriendsPage()));
          formMessage = "نام کاربری و گذرواژه خود را وارد کنید";
        });
      } else {
        if (result[0] == "-1") formMessage = "نام کاربری یا گذرواژه درست نیست";
        if (result[0] == "-2") formMessage = "دسترسی به اینترنت را چک کنید";
        if (result[0] == "-3")
          formMessage = "نام کاربری و رمز عبور باید از 4 حرف بیشتر باشد";
        /*  Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => LifecycleWatcher()));
        });*/
      }
    });
  }
}
