/*import 'dart:async';
import 'package:ap_me/AppSettings.dart';
import 'package:ap_me/AppSettingsPage.dart';
import 'package:ap_me/ShortMessages.dart';

import 'Friends.dart';
import 'MainPage.dart';
import 'NotificationTester.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'AppParameters.dart';
import 'ChatPage.dart';
import 'ApMeMessages.dart';
import 'PersianDateUtil.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with WidgetsBindingObserver {
  List<FriendModel> friendModels = [];
  List<Friend> _friends;
  bool isLoading = false;
  bool canSeeLastSeen = AppParameters.currentUser == "akbar" ||
      AppParameters.currentUser == "sohail";
  int _newMessagesCount = 0;
  bool blnTimerInitialized = false;
  Timer tmrFriendsDataRefresher;

  @override
  void initState() {
    _startTimer();
    WidgetsBinding.instance.addObserver(this);
    initNotif();

    ShortMessages.getSaveUploadMessages(150);
    AppSetting(
            settingName: "lastLoggedUser",
            settingValue: AppParameters.currentUser)
        .insert();
    super.initState();
    //_saveSMSTimer();
    //refreshFriendsLastSeenAndMessages();
    getFriendsAndLastMessages(false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        AppParameters.pausedTime = DateTime.now();
        debugPrint("FriendsPage status: paused");
        try {
          //blnTimerInitialized = false;
          tmrFriendsDataRefresher.cancel();
        } catch (Exception) {}
        break;
      case AppLifecycleState.resumed:
        debugPrint("FriendsPage status: resumed");

        AppParameters.pausedSeconds =
            DateTime.now().difference(AppParameters.pausedTime).inSeconds;
        if (AppParameters.pausedSeconds > AppParameters.pausePermittedSeconds) {
          backToLoginPage();
        } else {
          blnTimerInitialized = false;
          _startTimer();
        }
        break;
      case AppLifecycleState.inactive:
        debugPrint("FriendsPage status: inactive");
        try {
          tmrFriendsDataRefresher.cancel();
        } catch (Exception) {}
        break;
      case AppLifecycleState.detached:
        debugPrint("FriendsPage status: detached");
        try {
          tmrFriendsDataRefresher.cancel();
        } catch (Exception) {}
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AppParameters.pausedSeconds > AppParameters.pausePermittedSeconds) {
      backToLoginPage();
    }
    return RefreshIndicator(
        onRefresh: () {
          refreshFriendsLastSeenAndMessages();
          return Future.delayed(Duration(seconds: 1), () {});
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green[300],
              leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                  onPressed: () => {
                        backToLoginPage(),
                      }),
              actions: <Widget>[
                Visibility(
                  child: Container(
                      width: 50,
                      height: 10,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.red,
                        strokeWidth: 4,
                      )),
                  visible: isLoading,
                ),
                Visibility(
                  child: Container(
                    width: 50,
                    height: 10,
                    child: IconButton(
                      color: Colors.white,
                      onPressed: () {
                        getFriendsAndLastMessages(false);
                        //openNotPage();
                      },
                      icon: Icon(Icons.cloud_download),
                    ),
                  ),
                  visible: !isLoading,
                ),
                Visibility(
                  child: Container(
                    width: 50,
                    height: 10,
                    child: IconButton(
                      color: Colors.white,
                      onPressed: openMainPage,
                      icon: Icon(Icons.admin_panel_settings),
                    ),
                  ),
                  visible: canSeeLastSeen,
                ),
              ],
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 24.0,
                    backgroundImage:
                        NetworkImage(AppParameters.currentUserAvatarUrl()),
                  ),
                  Text(
                    AppParameters.prefix +
                        " " +
                        AppParameters.firstName +
                        " " +
                        AppParameters.lastName,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            body: Container(
              child: ListView.builder(
                itemCount: friendModels.length,
                itemBuilder: (context, index) {
                  FriendModel _model = friendModels[index];
                  return Column(
                    children: <Widget>[
                      Divider(
                        height: 12.0,
                      ),
                      ListTile(
                        onTap: () {
                          openChatPage(_model.id);
                        },
                        leading: CircleAvatar(
                          radius: 24.0,
                          backgroundImage: NetworkImage(
                              _model.avatarUrl), //_model.avatarUrl),
                        ),
                        title: Row(
                          children: <Widget>[
                            Text(_model.name),
                            SizedBox(
                              width: 26.0,
                            ),
                            Text(
                              canSeeLastSeen
                                  ? _model.datetime + "\n" + _model.lastSeen
                                  : _model.datetime,
                              style: TextStyle(
                                  fontSize: AppSettings.messageDateFontSize),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          _model.message,
                          style: TextStyle(
                              fontSize: AppSettings.messageBodyFontSize),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 14.0,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            endDrawer: Container(
              width: 200,
              child: Drawer(
                child: ListView(
                  children: <Widget>[
                    UserAccountsDrawerHeader(
                        accountName: Text("ApMe "),
                        accountEmail: Text(
                          " ",
                          // "نام‌کاربری" + ":" + "  " + App_Parameters.currentUserName,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                        ),
                        currentAccountPicture: CircleAvatar(
                          backgroundImage: AssetImage("assets/apmeLogo.png"),
                        )),
                    ListTile(
                      title: Text(
                        "Settings",
                        textDirection: TextDirection.rtl,
                      ),
                      leading: Icon(Icons.settings),
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                              transitionDuration: Duration(milliseconds: 300),
                              pageBuilder: (BuildContext context,
                                  Animation<double> animation,
                                  Animation<double> secAnimation) {
                                return AppSettingsPage();
                              },
                              transitionsBuilder: (BuildContext context,
                                  Animation<double> animation,
                                  Animation<double> secAnimation,
                                  Widget child) {
                                return SlideTransition(
                                  child: child,
                                  position: Tween<Offset>(
                                          begin: Offset(1, 0),
                                          end: Offset(0, 0))
                                      .animate(CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeInOutSine)),
                                );
                              }),
                        );
                      },
                    ),
                    ListTile(
                      title: Text(
                        "فونت درشت‌تر",
                        textDirection: TextDirection.rtl,
                      ),
                      leading: Icon(Icons.plus_one),
                      onTap: () {
                        setState(() {
                          AppSettings.messageBodyFontSize++;
                          AppSetting(
                                  settingName: "messageFontSize",
                                  settingValue:
                                      AppSettings.messageBodyFontSize.toString())
                              .insert();
                        });
                      },
                    ),
                    ListTile(
                      title: Text(
                        "فونت ریزتر",
                        textDirection: TextDirection.rtl,
                      ),
                      leading: Icon(Icons.exposure_minus_1),
                      onTap: () {
                        setState(() {
                          AppSettings.messageBodyFontSize--;
                          AppSetting(
                                  settingName: "messageFontSize",
                                  settingValue:
                                      AppSettings.messageBodyFontSize.toString())
                              .insert();
                        });
                      },
                    ),
                  ],
                ),
              ),
            )));
  }

  void _startTimer() {
    if (!blnTimerInitialized) {
      blnTimerInitialized = true;
      tmrFriendsDataRefresher =
          Timer.periodic(AppParameters.messageRefreshPeriod, (timer) {
        refreshFriendsLastSeenAndMessages();
      });
    }
  }

  void refreshFriendsLastSeenAndMessages() async {
    if (isLoading) {
      debugPrint(PersianDateUtil.now() +
          " FriendsPage web refreshing Cancelled ...");
      return;
    }
    isLoading = true;
    debugPrint(PersianDateUtil.now() + " FriendsPage web refreshing ...");
    int recordsCount = await ApMeMessages.localMessagesCount();
    if (recordsCount == 0)
      await ApMeMessages.getWebNewMessages(true);
    else
      ApMeMessages.getUnsyncedMessagesFromWeb();
    await getFriendsAndLastMessages(true);
    isLoading = false;
  }

  /* void _saveSMSTimer() {
    Timer.periodic(AppParameters.saveSMSPeriod, (timer) async {
      timer.cancel();
      debugPrint(PersianDateUtil.now() + " SMS Saving...");
      await ShortMessages.getSaveUploadMessages(100);
    });
  }
*/

  Future getFriendsAndLastMessages(bool fromWeb) async {
    isLoading = true;
    setState(() {});
    _friends = await Friends.getLocalFriendsList();
    if (_friends.length < 2 || fromWeb) {
      _friends = await Friends.getWebFriendFriendsList();
    }
    friendModels = [];
    await generateFriendModel();
    if (AppParameters.newMessagesCount > 0)
      _showNotification();
    else
      _newMessagesCount = 0;
    setState(() {
      isLoading = false;
      debugPrint(PersianDateUtil.now() + " FriendsPage Local refresh done.");
      // _showNotification("آپدیت شد");
      //_showNotification();
    });
  }

  Future generateFriendModel() async {
    for (int i = 0; i < _friends.length; i++) {
      List<ApMeMessage> lastMessage =
          await ApMeMessages.getLocalFriendLastMessage(_friends[i].friendId);
      friendModels.add(FriendModel(
        id: _friends[i].friendId,
        avatarUrl: _friends[i].avatarUrl,
        name: _friends[i].firstName,
        datetime: lastMessage.length > 0
            ? PersianDateUtil.MItoSH_Full(
                lastMessage[lastMessage.length - 1].getSentAtTime())
            : "-",
        message: lastMessage.length > 0
            ? lastMessage[lastMessage.length - 1].messageBody
            : "-",
        lastSeen: PersianDateUtil.MItoSH_Full(_friends[i].getLastSeenTime()),
      ));
    }
  }

  // void getFriendsAndLastMessage() async {
  //   isLoading = true;
  //   setState(() {});
  //   await ApMeMessages.getWebNewMessages(true);
  //   friendModels = [];
  //   if (_friends == null) _friends = await Friends.getWebFriendFriendsList();
  //   for (int i = 0; i < _friends.length; i++) {
  //     List<ApMeMessage> lastMessage =
  //         await ApMeMessages.getLocalFriendLastMessage(_friends[i].friendId);
  //     friendModels.add(FriendModel(
  //       avatarUrl: _friends[i].avatarUrl,
  //       name: _friends[i].firstName,
  //       datetime: lastMessage.length > 0
  //           ? MesUtil.formatDateTime(
  //               lastMessage[lastMessage.length - 1].getSentAtTime(), 1)
  //           : "-",
  //       message: lastMessage.length > 0
  //           ? lastMessage[lastMessage.length - 1].messageBody
  //           : "-",
  //     ));
  //   }
  //   setState(() {
  //     isLoading = false;
  //     debugPrint(PersianDateUtil.now() + " Chatlist web refresh done.");
  //     _showNotification("آپدیت شد");
  //     //_showNotification();
  //   });
  // }

  void openChatPage(String friendId) async {
    AppParameters.currentFriendId = friendId;
    // AppParameters.currentF = new Friend();
    // AppParameters.currentF.friendId = friend_Id;
    // await AppParameters.currentF.fetchLocal(friend_Id);
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ChatPage()));
    // Navigator.pushReplacement(
    //    context, MaterialPageRoute(builder: (context) => ChatPage()));
    // Navigator.of(context)
    //     .push(MaterialPageRoute(builder: (context) => ChatPage()));
  }

  void openMainPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => MainPage()));
    // .push(MaterialPageRoute(builder: (context) => Tmp()));
  }

  void openNotPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NotificationTester()));
  }

/*
  Future<void> _showNotification(String textToNotif) async {
    var androidNotificationDetails = new AndroidNotificationDetails(
      'AmMe',
      'MessageNotif',
      'Notif from message manager',
      importance: Importance.Max,
      priority: Priority.High,
      playSound: true,
    );
    var iOSNotificationDetails = new IOSNotificationDetails(presentSound: true);

    var platformChannelSpecifics = new NotificationDetails(
        androidNotificationDetails, iOSNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Ap Me',
      textToNotif,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  
  Future onSelectNotification(String payload) async {}
/*
    await flutterLocalNotificationsPlugin.show(
      0,
      'Ap Me',
      notifMessage,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }*/

  Future<void> _cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }
*/
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  void initNotif() {
    var androidSpec = new AndroidInitializationSettings('@mipmap/ic_launcher');

    var iosSpec = new IOSInitializationSettings();

    var initializationSettings =
        new InitializationSettings(androidSpec, iosSpec);

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    showDialog(
        context: context,
        builder: (_) {
          return new AlertDialog(
            title:
                Text(AppParameters.newMessagesCount.toString() + ' پیام تازه'),
            content: Text("هشدار متوقف شود؟"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // passing false
                child: Text('نه'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true), // passing true
                child: Text('بلی'),
              ),
            ],
          );
        }).then(
      (exit) {
        if (exit == null) return;

        if (exit) {
          AppParameters.newMessagesCount = 0;
          _newMessagesCount = 0;
        } else {
          // user pressed No button
        }
      },
    );
  }

  void backToLoginPage() {
    tmrFriendsDataRefresher.cancel();
    Navigator.of(context).pop();
  }

  Future _showNotification() async {
    var androidSpec = new AndroidNotificationDetails(
        'ApMe', 'Flutter Messenger', 'Ap Messenger',
        playSound: true, importance: Importance.Max, priority: Priority.High);

    var iosSpec = new IOSNotificationDetails(presentSound: false);

    var platformChannelSpecifics =
        new NotificationDetails(androidSpec, iosSpec);
    //notified = true;
    if (_newMessagesCount != AppParameters.newMessagesCount) {
      /*    await flutterLocalNotificationsPlugin.show(
        0,
        'ApMe',
        'شما' + AppParameters.newMessagesCount.toString() + ' پیام تازه دارید',
        platformChannelSpecifics,
        payload: 'No_Sound',
      );*/
    }
    _newMessagesCount = AppParameters.newMessagesCount;
  }
}

class FriendModel {
  final String avatarUrl;
  final String id;
  final String name;
  final String lastSeen;
  final String datetime;
  final String message;

  FriendModel(
      {this.id,
      this.avatarUrl,
      this.name,
      this.lastSeen,
      this.datetime,
      this.message});
}
*/