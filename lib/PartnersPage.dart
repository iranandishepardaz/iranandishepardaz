// import 'dart:async';
// import 'package:ap_me/Friends.dart';
// import 'package:ap_me/MainPage.dart';
// import 'package:ap_me/NotificationTester.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'AppParameters.dart';
// import 'ChatPage.dart';
// import 'ApMeMessages.dart';
// import 'ApMeUtils.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();
// const MethodChannel platform =
//     MethodChannel('dexterx.dev/flutter_local_notifications_example');

// class PartnersPage extends StatefulWidget {
//   @override
//   _PartnersPageState createState() => _PartnersPageState();
// }

// class _PartnersPageState extends State<PartnersPage> {
//   List<PartnerModel> partnerModels = [];
//   List<Friend> _friends;
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     initNotif();
//     getFriendsAndLastMessage();
//     _startTimer();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//             icon: Icon(Icons.arrow_back_ios),
//             color: Colors.white,
//             onPressed: () => {
//                   Navigator.of(context).pop(),
//                 }),
//         actions: <Widget>[
//           Visibility(
//             child: Container(
//                 width: 50,
//                 height: 10,
//                 child: CircularProgressIndicator(
//                   backgroundColor: Colors.red,
//                   strokeWidth: 4,
//                 )),
//             visible: isLoading,
//           ),
//           Visibility(
//             child: Container(
//               width: 50,
//               height: 10,
//               child: IconButton(
//                 //onPressed: getFriendsAndLastMessage,
//                 onPressed: () {
//                   openNotPage();
//                 },
//                 //onPressed: _showNotification,
//                 icon: Icon(Icons.cloud_download),
//               ),
//             ),
//             visible: !isLoading,
//           ),
//           Visibility(
//             child: Container(
//               width: 50,
//               height: 10,
//               child: IconButton(
//                 onPressed: openMainPage,
//                 icon: Icon(Icons.admin_panel_settings),
//               ),
//             ),
//             visible: AppParameters.currentUser == "akbar",
//           ),
//         ],
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 24.0,
//               backgroundImage:
//                   NetworkImage(AppParameters.currentUserAvatarUrl()),
//             ),
//             Text(
//               AppParameters.prefix +
//                   " " +
//                   AppParameters.firstName +
//                   " " +
//                   AppParameters.lastName,
//               style: TextStyle(fontSize: 14),
//             ),
//           ],
//         ),
//       ),
//       body: Container(
//         child: ListView.builder(
//           itemCount: partnerModels.length,
//           itemBuilder: (context, index) {
//             PartnerModel _model = partnerModels[index];
//             return Column(
//               children: <Widget>[
//                 Divider(
//                   height: 12.0,
//                 ),
//                 ListTile(
//                   onTap: () {
//                     openChatPage(_model.name);
//                   },
//                   leading: CircleAvatar(
//                     radius: 24.0,
//                     backgroundImage: NetworkImage(_model.avatarUrl), //_model.avatarUrl),
//                   ),
//                   title: Row(
//                     children: <Widget>[
//                       Text(_model.name),
//                       SizedBox(
//                         width: 26.0,
//                       ),
//                       Text(
//                         _model.datetime,
//                         style: TextStyle(fontSize: 12.0),
//                       ),
//                     ],
//                   ),
//                   subtitle: Text(_model.message),
//                   trailing: Icon(
//                     Icons.arrow_forward_ios,
//                     size: 14.0,
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   void _startTimer() {
//     // Timer.periodic(const Duration(seconds: 60), () {
//     //  print(DateTime.now().toString() + " Chatlist web refreshing ...");
//     //    getFriendsAndLastMessage();
// //    });
//   }



//   void getFriendsAndLastMessage() async {
//     isLoading = true;
//     setState(() {});
//     await ApMeMessages.getWebNewMessages(true);
//     partnerModels = [];
//     if (_friends == null) _friends = await Friends.getWebFriendFriendsList();
//     for (int i = 0; i < _friends.length; i++) {
//       List<ApMeMessage> lastMessage =
//           await ApMeMessages.getLocalFriendLastMessage(_friends[i].friendId);
//       partnerModels.add(PartnerModel(
//         avatarUrl:_friends[i].avatarUrl,
//         name: _friends[i].firstName,
//         datetime: lastMessage.length > 0
//             ? MesUtil.formatDateTime(
//                 lastMessage[lastMessage.length - 1].getSentAtTime(), 1)
//             : "-",
//         message: lastMessage.length > 0
//             ? lastMessage[lastMessage.length - 1].messageBody
//             : "-",
//       ));
//     }
//     setState(() {
//       isLoading = false;
//       print(DateTime.now().toString() + " Chatlist web refresh done.");
//       _showNotification("آپدیت شد");
//       //_showNotification();
//     });
//   }

//   void openChatPage(String friendId) {
//     AppParameters.currentFriend = friendId;
//     Navigator.pushReplacement(
//         context, MaterialPageRoute(builder: (context) => ChatPage()));
//     // Navigator.of(context)
//     //     .push(MaterialPageRoute(builder: (context) => ChatPage()));
//   }

//   void openMainPage() {
//     Navigator.of(context)
//         .push(MaterialPageRoute(builder: (context) => MainPage()));
//   }

//   void openNotPage() {
//     Navigator.of(context)
//         .push(MaterialPageRoute(builder: (context) => NotificationTester()));
//   }

//   Future<void> _showNotification(String textToNotif) async {
//     var androidNotificationDetails = new AndroidNotificationDetails(
//       'AmMe',
//       'MessageNotif',
//       'Notif from message manager',
//       importance: Importance.Max,
//       priority: Priority.High,
//       playSound: true,
//     );
//     var iOSNotificationDetails = new IOSNotificationDetails(presentSound: true);

//     var platformChannelSpecifics = new NotificationDetails(
//         androidNotificationDetails, iOSNotificationDetails);

//     await flutterLocalNotificationsPlugin.show(
//       0,
//       'Ap Me',
//       textToNotif,
//       platformChannelSpecifics,
//       payload: 'item x',
//     );
//   }

//   void initNotif() {
//     var initializationSettingsAndroid =
//         new AndroidInitializationSettings('@apme/ic_launcher');
//     var initializationSettingsIOS = new IOSInitializationSettings();
//     var initializationSettings = new InitializationSettings(
//         initializationSettingsAndroid, initializationSettingsIOS);
//     flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onSelectNotification: onSelectNotification);
//   }

//   Future onSelectNotification(String payload) async {}
// /*
//     await flutterLocalNotificationsPlugin.show(
//       0,
//       'Ap Me',
//       notifMessage,
//       platformChannelSpecifics,
//       payload: 'item x',
//     );
//   }*/

//   Future<void> _cancelNotification() async {
//     await flutterLocalNotificationsPlugin.cancel(0);
//   }
// }
