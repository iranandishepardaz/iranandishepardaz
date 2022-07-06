import 'dart:async';
import 'AppSettings.dart';
import 'FriendsPageDrawer.dart';
import 'LoginDialog.dart';
import 'NotificationTester.dart';
import 'OptionsDrawer.dart';
import 'ShortMessages.dart';

import 'Friends.dart';
import 'AdminPage.dart';
import 'NotificationTester.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
//Temp Comment import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'AppParameters.dart';
import 'ChatPage.dart';
import 'ApMeMessages.dart';
import 'PersianDateUtil.dart';
import 'FriendsPageAppBar.dart';
import 'package:async/async.dart';

//Temp Comment final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =    FlutterLocalNotificationsPlugin();
const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

class FriendsPage extends StatefulWidget {
  @override
  FriendsPageState createState() => FriendsPageState();
}

class FriendsPageState extends State<FriendsPage> {
  List<FriendModel> friendModels = [];
  late List<Friend> _friends = [];
  bool isLoading = false;
  bool initialized = false;
  int _newMessagesCount = 0;
  //bool blnTimerInitialized = false;
  //Timer tmrFriendsDataRefresher;
  late RestartableTimer _refreshTimer;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // WidgetsBinding.instance.addObserver(this);
    //Temp Comment initNotif();
    super.initState();
    initialize();
    //AppSettings.resetToDefaultSetings();
  }

  void initialize() async {
    int tmpBuffer = AppParameters.pausePermittedSeconds;
    AppParameters.pausePermittedSeconds = 1000;
    AppParameters.currentPage = "FriendsPage";
    await ShortMessages.getSaveUploadMessages(AppParameters.reqCount);
    AppSetting(
            settingName: "lastLoggedUser",
            settingValue: AppParameters.currentUser)
        .insert();
    //AppParameters.friendsRefreshPeriod = Duration(seconds: 15);
    AppParameters.pausePermittedSeconds = tmpBuffer;
    _refreshTimer =
        RestartableTimer(AppParameters.friendsRefreshPeriod, refreshFriends);
    await refreshFriends();
    initialized = true;
  }

/*  @override
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
          _startRefreshTimer();
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
*/
  Future<bool> _onWillPopSimple() async {
    backToLoginPage();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: AppParameters
    //        .titlesForegroundColor, //or set color with: Color(0xFF0000FF)
    // ));
    return WillPopScope(
        onWillPop: _onWillPopSimple,
        child: RefreshIndicator(
            onRefresh: () {
              if (initialized) refreshFriends();
              return Future.delayed(Duration(seconds: 1), () {});
            },
            child: Scaffold(
                key: scaffoldKey,
                appBar: FriendsAppBar(this).appBar(),
                body: Container(
                  decoration: new BoxDecoration(
                    border: new Border.all(
                        color: AppSettings.titlesBackgroundColor, width: 4),
                    color: AppSettings.formsBackgroundColor,
                  ),
                  child: ListView.builder(
                    itemCount: friendModels.length,
                    itemBuilder: (context, index) {
                      FriendModel _model = friendModels[index];
                      return Column(
                        children: <Widget>[
                          ListTile(
                            onTap: () {
                              openChatPage(_model.id, _model.name);
                            },
                            leading: GestureDetector(
                              onTap: () {
                                LoginDialog().showNetworkImage(
                                    _model.avatarUrl, this.context);
                              },
                              child: CircleAvatar(
                                radius:
                                    26.0, // AppSettings.messageBodyFontSize * 1.5,
                                backgroundImage: NetworkImage(
                                    _model.avatarUrl), //_model.avatarUrl),
                              ),
                            ),
                            title: Row(
                              children: <Widget>[
                                Text(
                                  _model.name,
                                  style: new TextStyle(
                                    color: AppSettings.formsForegroundColor,
                                  ),
                                ),
                                SizedBox(
                                  width: 26.0,
                                ),
                                Text(
                                  AppParameters.canSeeLastSeen
                                      ? _model.datetime + "\n" + _model.lastSeen
                                      : _model.datetime,
                                  style: TextStyle(
                                      color: AppSettings.formsForegroundColor,
                                      fontSize:
                                          AppSettings.messageDateFontSize),
                                ),
                              ],
                            ),
                            subtitle: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                _model.message,
                                style: TextStyle(
                                    color: AppSettings.formsForegroundColor,
                                    fontSize: AppSettings.messageBodyFontSize),
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 14.0,
                              color: AppSettings.formsForegroundColor,
                            ),
                          ),
                          Divider(
                            color: AppSettings.titlesBackgroundColor,
                            thickness: 3,
                            height: 3.0,
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      );
                    },
                  ),
                ),
                endDrawer: FriendsPageDrawer.sideDrawer(this))));
  }

  void refreshContent() {
    setState(() {});
  }

  /*
  void _startRefreshTimer() {
    if (!blnTimerInitialized) {
      blnTimerInitialized = true;
      tmrFriendsDataRefresher =
          Timer.periodic(AppParameters.messageRefreshPeriod, (timer) {
        refreshFriends();
      });
    }
  }
  */
  Future<void> refreshFriends() async {
    if (AppParameters.currentPage != "FriendsPage") {
      _refreshTimer.cancel();
      debugPrint(PersianDateUtil.now() + " FriendsPage Refreshing terminated.");
    } else {
      if (isLoading) {
        debugPrint(
            PersianDateUtil.now() + " FriendsPage Refreshing cancelled.");
      } else {
        if (isLoading) {
          debugPrint(PersianDateUtil.now() +
              " FriendsPage web refreshing Cancelled ...");
          return;
        }
        isLoading = true;
        try {
          debugPrint(PersianDateUtil.now() + " FriendsPage web refreshing ...");
          await getFriendsAndLastMessages(true);
          int? recordsCount = await ApMeMessages.localMessagesCount();
          if (recordsCount! < 10)
            await ApMeMessages.getWebNewMessages(true);
          else
            await ApMeMessages.getUnsyncedMessagesFromWeb();
        } catch (Exception) {}
        friendModels = [];
        await generateFriendModel();
        setState(() {});
      }

      _refreshTimer.reset();
      isLoading = false;
    }
  }

  Future getFriendsAndLastMessages(bool fromWeb) async {
    isLoading = true;
    setState(() {});
    if (_friends == null) _friends = [];
    if (_friends.length < 2 || fromWeb) {
      _friends = await Friends.getWebFriendFriendsList();
    }
    /*else {
      _friends = await Friends.getLocalFriendsList();
    }*/
    if (AppParameters.newMessagesCount > 0)
      //Temp Comment  _showNotification();
      //Temp Comment else
      _newMessagesCount = 0;
    setState(() {
      isLoading = false;
      debugPrint(PersianDateUtil.now() + " FriendsPage Local refresh done.");
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
                lastMessage[lastMessage.length - 1].getSentAtTime()!)
            : "-",
        message: lastMessage.length > 0
            ? lastMessage[lastMessage.length - 1].deleted == 0
                ? lastMessage[lastMessage.length - 1].messageBody.length > 50
                    ? lastMessage[lastMessage.length - 1]
                            .messageBody
                            .substring(0, 50) +
                        "..."
                    : lastMessage[lastMessage.length - 1].messageBody
                : "...."
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

  void openChatPage(String friendId, String friendName) async {
    AppParameters.currentFriendId = friendId;
    AppParameters.currentFriendName = friendName;

    // AppParameters.currentF = new Friend();
    // AppParameters.currentF.friendId = friend_Id;
    // await AppParameters.currentF.fetchLocal(friend_Id);
    _refreshTimer.cancel();
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ChatPage()));
    // .push(MaterialPageRoute(builder: (context) => FriendPage()));
    if (!AppParameters.authenticated) {
      backToLoginPage();
    } else {
      AppParameters.currentPage = "FriendsPage";
      refreshFriends();
      _refreshTimer =
          RestartableTimer(AppParameters.friendsRefreshPeriod, refreshFriends);
    }
    // Navigator.pushReplacement(
    //    context, MaterialPageRoute(builder: (context) => ChatPage()));
    // Navigator.of(context)
    //     .push(MaterialPageRoute(builder: (context) => ChatPage()));
  }

  final txtUserNameController = TextEditingController();
  final txtPasswordController = TextEditingController();
  String formMessage = "وارد شوید";
  void openMainPage() {
    if (AppParameters.currentUser == 'admin') {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => AdminPage()));
    } else {
      LoginDialog().showLoginDialog(context);
    }
    // .push(MaterialPageRoute(builder: (context) => Tmp()));
  }

  void openNotifPage() {
    //Temp Comment Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationTester()));
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

//Temp Comment
/*
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  void initNotif() {
    var androidSpec = new AndroidInitializationSettings('@mipmap/ic_launcher');

    var iosSpec = new IOSInitializationSettings();

    var initializationSettings =
        new InitializationSettings(android: androidSpec, iOS: iosSpec);

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    var context;
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
*/

  void backToLoginPage() {
    try {
      _refreshTimer.cancel();
    } catch (exp) {}
    try {
      Navigator.of(context).pop();
    } catch (exp) {}
  }

//Temp Comment
/*
  Future _showNotification() async {
    var androidSpec = const AndroidNotificationDetails(
        'ApMe', 'Flutter Messenger',
        playSound: true, importance: Importance.max, priority: Priority.high);

    var iosSpec = new IOSNotificationDetails(presentSound: false);

    var platformChannelSpecifics =
        new NotificationDetails(android: androidSpec, iOS: iosSpec);
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
  */
}

class FriendModel {
  final String avatarUrl;
  final String id;
  final String name;
  final String lastSeen;
  final String datetime;
  final String message;

  FriendModel(
      {this.id = "",
      this.avatarUrl = "",
      this.name = "",
      this.lastSeen = "",
      this.datetime = "",
      this.message = ""});
}
