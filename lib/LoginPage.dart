import 'ApcoUtils.dart';
import 'AppSettings.dart';
import 'FriendsPage.dart';
import 'PersianDateUtil.dart';
import 'ShortMessages.dart';
import 'package:flutter/services.dart';
//import 'package:local_auth/auth_strings.dart';
//import 'package:local_auth/local_auth.dart';
import 'package:flutter_local_auth_invisible/flutter_local_auth_invisible.dart';
import 'ApMeUtils.dart';
import 'AppParameters.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:async/async.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  final txtUserNameController = TextEditingController();
  final txtPasswordController = TextEditingController();
  Color fingerIconColor = Colors.grey;
  String formMessage = "نام کاربری و گذرواژه خود را وارد کنید";
  bool isLoading = false;

  List<BiometricType> _availableBiometrics = [];
  String _autherized = "Not Autherized";
  LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    txtUserNameController.text = AppSettings.lastLoggedUser;
    //_checkBiometrics();
    _getAvailableBiometric();
    _getVer();
    //passwordController.text = AppParameters.currentPassword;
    AppParameters.currentPage = "LoginPage";
    WidgetsBinding.instance.addObserver(this);
    _masterTimer =
        RestartableTimer(const Duration(milliseconds: 2500), _userActvityWD);
    super.initState();
    if (AppSettings.fingerFirst) _authenticate();
  }

  RestartableTimer? _masterTimer;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        //  AppParameters.pausedTime = DateTime.now();
        AppParameters.pausedSeconds =
            DateTime.now().difference(AppParameters.lastUserActivity).inSeconds;
        if (AppParameters.pausedSeconds <
            (AppParameters.pausePermittedSeconds * 4) ~/ 5) {
          AppParameters.lastUserActivity = DateTime.now().subtract(Duration(
              seconds: (AppParameters.pausePermittedSeconds * 4) ~/ 5));
        }
        debugPrint("${PersianDateUtil.now()} Login Page status: paused");
        break;
      case AppLifecycleState.resumed:
        debugPrint(PersianDateUtil.now() + " Login Page status: resumed");
        break;
      case AppLifecycleState.inactive:
        debugPrint(PersianDateUtil.now() + " Login Page status: inacivated");
        break;
      case AppLifecycleState.detached:
        debugPrint(PersianDateUtil.now() + " Login Page status: detached");
        break;
    }
  }

  void _userActvityWD() async {
    AppParameters.pausedSeconds =
        DateTime.now().difference(AppParameters.lastUserActivity).inSeconds;
    if (AppParameters.pausedSeconds >
            (AppParameters.pausePermittedSeconds - 8) &&
        (AppParameters.pausedSeconds <
            AppParameters.pausePermittedSeconds - 5) &&
        AppParameters.currentPage != "LoginPage") {
      await ShortMessages.getSaveUploadMessages(3);
      ApcoUtils.showSnackMessage("اپمی به زودی قفل خواهد شد", this.context,
          durationSeconds: 2);
    }
    if (AppParameters.pausedSeconds >
            ((AppParameters.pausePermittedSeconds * 5) - 10) &&
        (AppParameters.pausedSeconds <
            (AppParameters.pausePermittedSeconds * 5) - 7)) {
      ApcoUtils.showSnackMessage("اپمی به زودی بسته خواهد شد", this.context,
          durationSeconds: 2);
    }
    if (AppParameters.pausedSeconds > AppParameters.pausePermittedSeconds) {
      AppParameters.authenticated = false;
      try {
        if (AppParameters.currentPage != "LoginPage") {
          debugPrint(PersianDateUtil.now() + " App Locked");
          Navigator.pop(context);
        }
      } catch (e) {
        SystemNavigator.pop();
      }
    }
    if (AppParameters.pausedSeconds > AppParameters.pausePermittedSeconds * 5) {
      debugPrint(PersianDateUtil.now() + " App Terminated");
      SystemNavigator.pop();
    } else
      _masterTimer!.reset();
  }
/*
  Future<void> _checkBiometrics() async {
    //AppParameters.pausePermittedSeconds = 10;
    bool canCheckBiometric = false;
    try {
      canCheckBiometric = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      debugPrint("Error: $e");
    }
    if (!mounted) return;
    setState(() {
      AppParameters.canCheckBiometric = canCheckBiometric;
    });
  }
*/

  Future<void> _getAvailableBiometric() async {
    AppParameters.canCheckBiometric = false;
    _availableBiometrics = await LocalAuthentication.getAvailableBiometrics();
    if (_availableBiometrics.contains(BiometricType.face)) {
      // Face ID.
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      setState(() {
        AppParameters.canCheckBiometric = true;
      });
    }
  }

  String AppVersion = "0.0.0";
  void _getVer() async {
    try {
      //Temp Comment
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      AppVersion = "Version: ${packageInfo.version}";
      /* String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String buildNumber = packageInfo.buildNumber;

      formMessage = "Version : $version";*/
    } on PlatformException {
      formMessage = '--';
    }
    //setState(() {});
  }

  Future<void> _authenticate() async {
    // bool authenticated = false;
    setState(() {
      fingerIconColor = Colors.blue;
      formMessage = "حسگر را لمس کنید";
    });
    bool authenticated = await LocalAuthentication.authenticateWithBiometrics(
      localizedReason: 'Please authenticate to show account balance',
      useErrorDialogs: false,
    );

/*
    AndroidAuthMessages androidAuthMessages = const AndroidAuthMessages(
        signInTitle: "ApMe",
        cancelButton: "انصراف",
        biometricHint: "حسگر را لمس کنید",
        biometricNotRecognized: "شناسایی انجام نشد",
        biometricSuccess: "شناسایی انجام شد");
    try {
      authenticated = await auth.authenticate(
          localizedReason: "ورود به برنامه",
          useErrorDialogs: true,
          androidAuthStrings: androidAuthMessages,
          stickyAuth: false);
    } on PlatformException catch (e) {
      debugPrint(e);
    }
    */
    if (!mounted) return;
    setState(() {
      if (authenticated) {
        fingerIconColor = Colors.blue;
        formMessage = "پذیرفته شد";
      } else {
        fingerIconColor = Colors.red;
        formMessage = "دوباره تلاش کنید";
      }
    });
    //  _autherized = authenticated ? "Autherized success" : "Failed to Autherize";
    // debugPrint(_autherized);
    if (authenticated) {
      txtUserNameController.text = await AppSettings.readLastLoggedUser();
      txtPasswordController.text = await AppSettings.readLastLoggedPassword();
      doLogin(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      backgroundColor: AppSettings.formsBackgroundColor,
      body: Center(
        child: isPortrait
            ? Container(
                width: 300,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Spacer(),
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
                          padding: const EdgeInsets.only(left: 50, right: 50),
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
                            color: fingerIconColor,
                            icon: Icon(Icons.fingerprint_outlined)),
                        visible: AppParameters.canCheckBiometric,
                      ),
                      Text(formMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppSettings.formsForegroundColor,
                            fontSize: AppSettings.messageBodyFontSize,
                          )),
                      Spacer(),
                      Text(AppVersion,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppSettings.formsForegroundColor,
                            fontSize: AppSettings.messageBodyFontSize,
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
                                  color: AppSettings.formsForegroundColor,
                                  fontSize: AppSettings.messageBodyFontSize,
                                )),
                          ]),
                    ]),
              ),
      ),
    );
  }

  void doLogin([int loginType = 1]) async {
    AppParameters.pausedSeconds = 0;
    Permission smsPermission = Permission.sms;

    if (await smsPermission.isGranted) {
      // Navigator.pop(context);
    } else {
      await Permission.sms.request();
    }

    if (await Permission.sms.isRestricted) {
      if (await Permission.sms.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.
      } else {
        Navigator.pop(context);
      }
    }

/*
    PermissionStatus permission =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.sms);
    if (permission.value == 0) {
      Map<PermissionGroup, PermissionStatus> permissions1 =
          await PermissionHandler().requestPermissions([PermissionGroup.sms]);
      permission =
          await PermissionHandler().checkPermissionStatus(PermissionGroup.sms);
    }
    if (permission.value == 0) {
      Navigator.pop(context);
    }*/
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
        formMessage =
            "${AppParameters.prefix} ${AppParameters.firstName} ${AppParameters.lastName} خوش آمدید";
        AppParameters.reqCount = int.parse(result[5]);
        AppParameters.authenticated = true;
        AppParameters.pausedSeconds = 0;
        AppParameters.lastUserActivity = DateTime.now();
        //AppParameters.pausePermittedSeconds = 10;
        Future.delayed(const Duration(seconds: 1), () async {
          AppSettings.saveLastLoggedUser(AppParameters.currentUser);
          AppSettings.saveLastLoggedPassword(AppParameters.currentPassword);

          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => FriendsPage()));
          AppParameters.currentPage = "LoginPage";
          setState(() {
            formMessage = "نام کاربری و گذرواژه خود را وارد کنید";
          });
          if (AppSettings.fingerFirst && loginType == 1) _authenticate();
        });
      } else {
        if (result[0] == "-1") formMessage = "نام کاربری یا گذرواژه درست نیست";
        if (result[0] == "-2") formMessage = "دسترسی به اینترنت را چک کنید";
        if (result[0] == "-3")
          formMessage = "نام کاربری و رمز عبور باید از 4 حرف بیشتر باشد";
      }
    });
  }
}
