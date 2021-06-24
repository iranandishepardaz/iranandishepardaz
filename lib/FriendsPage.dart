import 'dart:async';
import 'Friends.dart';
import 'MainPage.dart';
import 'NotificationTester.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'AppParameters.dart';
import 'ChatPage.dart';
import 'ApMeMessages.dart';
import 'ApMeUtils.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<FriendModel> friendModels = [];
  List<Friend> _friends;
  bool isLoading = false;
   int _newMessagesCount = 0;

  @override
  void initState() {
    super.initState();
    initNotif();
    getFriendsAndLastMessages(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () => {
                  Navigator.of(context).pop(),
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
            visible: AppParameters.currentUser == "akbar",
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
                    backgroundImage:
                        NetworkImage(_model.avatarUrl), //_model.avatarUrl),
                  ),
                  title: Row(
                    children: <Widget>[
                      Text(_model.name),
                      SizedBox(
                        width: 26.0,
                      ),
                      Text(
                        _model.datetime,
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ],
                  ),
                  subtitle: Text(_model.message),
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
    );
  }

  void _startTimer() {
    Timer.periodic(AppParameters.refreshPeriod, (timer) async {
      timer.cancel();
      print(DateTime.now().toString() + " Chatlist web refreshing ...");
      await ApMeMessages.getWebNewMessages(true);
      await getFriendsAndLastMessages(true);
    });
  }

  Future getFriendsAndLastMessages(bool fromWeb) async {
    isLoading = true;
    setState(() {});
    _friends = await Friends.getLocalFriendsList();
    if (_friends.length == 0 || fromWeb) {
      _friends = await Friends.getWebFriendFriendsList();
    }
    friendModels = [];
    await generateModels();
    if (AppParameters.newMessagesCount > 0) _showNotification();
    else  _newMessagesCount = 0;
    setState(() {
      isLoading = false;
      print(DateTime.now().toString() + " Chatlist Local refresh done.");
      // _showNotification("آپدیت شد");
      //_showNotification();
    });
    _startTimer();
  }

  Future generateModels() async {
    for (int i = 0; i < _friends.length; i++) {
      List<ApMeMessage> lastMessage =
          await ApMeMessages.getLocalFriendLastMessage(_friends[i].friendId);
      friendModels.add(FriendModel(
        id: _friends[i].friendId,
        avatarUrl: _friends[i].avatarUrl,
        name: _friends[i].firstName,
        datetime: lastMessage.length > 0
            ? MesUtil.formatDateTime(
                lastMessage[lastMessage.length - 1].getSentAtTime(), 1)
            : "-",
        message: lastMessage.length > 0
            ? lastMessage[lastMessage.length - 1].messageBody
            : "-",
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
  //     print(DateTime.now().toString() + " Chatlist web refresh done.");
  //     _showNotification("آپدیت شد");
  //     //_showNotification();
  //   });
  // }

  void openChatPage(String friendId) {
    AppParameters.currentFriend = friendId;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ChatPage()));
    // Navigator.of(context)
    //     .push(MaterialPageRoute(builder: (context) => ChatPage()));
  }

  void openMainPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => MainPage()));
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
    var AndSetting = new AndroidInitializationSettings('@mipmap/ic_launcher');

    var IOSSetting = new IOSInitializationSettings();

    var initializationSettings =
        new InitializationSettings(AndSetting, IOSSetting);

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
              FlatButton(
                onPressed: () => Navigator.pop(context, false), // passing false
                child: Text('نه'),
              ),
              FlatButton(
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
        } else {
          // user pressed No button
        }
      },
    );
  }

 
  Future _showNotification() async {
    var AndSpec = new AndroidNotificationDetails(
        'ApMe', 'Flutter Messenger', 'Ap Messenger',
        playSound: true, importance: Importance.Max, priority: Priority.High);

    var IOSSpec = new IOSNotificationDetails(presentSound: false);

    var platformChannelSpecifics = new NotificationDetails(AndSpec, IOSSpec);
    //notified = true;
    if (_newMessagesCount != AppParameters.newMessagesCount) {
      await flutterLocalNotificationsPlugin.show(
        0,
        'ApMe',
        'شما' + AppParameters.newMessagesCount.toString() + ' پیام تازه دارید',
        platformChannelSpecifics,
        payload: 'No_Sound',
      );
    }
    _newMessagesCount = AppParameters.newMessagesCount;
  }
}

class FriendModel {
  final String avatarUrl;
  final String id;
  final String name;
  final String datetime;
  final String message;

  FriendModel(
      {this.id, this.avatarUrl, this.name, this.datetime, this.message});
}
