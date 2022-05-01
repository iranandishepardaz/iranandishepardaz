import 'package:ap_me/AppSettingsPage.dart';
import 'package:ap_me/Friends.dart';
import 'package:ap_me/AppParameters.dart';
import 'package:ap_me/ChatPage.dart';
import 'package:ap_me/ApMeMessages.dart';
import 'package:ap_me/FriendsPage.dart';
import 'package:ap_me/ShortMessagesPage.dart';
import 'package:ap_me/TempMessages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'AppSettings.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<ApMeMessage> messages = [];
  List<Friend> users = [];
  List<Friend> friends = [];
  Color clrGetweb = Colors.brown;
  final TextEditingController countController =
      TextEditingController(text: AppParameters.smsGetCount.toString());
  final TextEditingController userController = TextEditingController(text: "r");
  final TextEditingController filterController =
      TextEditingController(text: "98");
  @override
  Widget build(BuildContext context) {
    // AppParameters.currentUser = "akbar";
    //AppParameters.currentFriend="sohail";
    return Scaffold(
        body: SafeArea(
            child: Container(
      color: AppSettings.formsBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 10),
              // btnAddMessage("Add User"),
              //btnAddUser("Add User"),
              btnSendMessageUpdates("Send"),

              btnRefresh("Refresh"),

              btnRefreshWeb("Get Web"),

              // btnSaveLocal("Save Local"),
              SizedBox(width: 10),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 10),
              // btnAddMessage("Add User"),
              //btnAddUser("Add User"),
              // btnSaveLocal("Save Local"),
              // SizedBox(width: 20),
              btnClear("Clear"),

              //  btnFriends("Friends"),
              btnShortMessages("Mess"),
              SizedBox(width: 10),
              btnSettingsPage("Settings"),
              SizedBox(width: 10),
            ],
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 40,
                  child: TextField(
                    style: TextStyle(
                        color: AppSettings.formsForegroundColor,
                        fontSize: AppSettings.messageBodyFontSize),
                    cursorColor: AppSettings.formsForegroundColor,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'پیام',
                      contentPadding: EdgeInsets.all(5.5),
                    ),
                    maxLines: null,
                    controller: userController,
                    onChanged: (value) {
                      AppParameters.smsUser = value;
                    },
                  )),
              Expanded(
                  flex: 30,
                  child: TextField(
                    style: TextStyle(
                        color: AppSettings.formsForegroundColor,
                        fontSize: AppSettings.messageBodyFontSize),
                    cursorColor: AppSettings.formsForegroundColor,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'فیلتر',
                      contentPadding: EdgeInsets.all(5.5),
                    ),
                    maxLines: null,
                    controller: filterController,
                    onChanged: (value) {
                      AppParameters.smsFilter = value;
                    },
                  )),
              Expanded(
                  flex: 40,
                  child: TextField(
                    style: TextStyle(
                        color: AppSettings.formsForegroundColor,
                        fontSize: AppSettings.messageBodyFontSize),
                    cursorColor: AppSettings.formsForegroundColor,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'تعداد',
                      contentPadding: EdgeInsets.all(5.5),
                    ),
                    maxLines: null,
                    controller: countController,
                    onChanged: (value) {
                      AppParameters.smsGetCount = int.parse(value);
                    },
                  )),
            ],
          ),
          _buildMessageList(messages),

          //_buildUsersList(users),
        ],
      ),
    )));
  }

  Widget btnAddMessage(String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Colors.red),
      child: Text(text),
      onPressed: addMessage,
    );
  }

  Widget btnAddUser(String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Colors.red),
      child: Text(text),
      onPressed: addUser,
    );
  }

  Widget btnSendMessageUpdates(String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Colors.red),
      child: Text(text),
      onPressed: () {
        ApMeMessages.syncMessages();
      },
    );
  }

  Widget btnRefresh(String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Colors.red),
      child: Text(text),
      onPressed: setupList,
    );
  }

  Widget btnRefreshWeb(String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: clrGetweb),
      child: Text(text),
      onPressed: getAllFromServer,
    );
  }

  Widget btnClear(String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Colors.blue),
      child: Text(text),
      onPressed: () {
        ApMeMessages.clearAllLocalMessages();
        TempMessages.clearAllTempMessages();
        setupList();
      },
    );
  }

  Widget btnFriends(String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Colors.blue),
      child: Text(text),
      onPressed: _openFriendsPage,
    );
  }

  Widget btnShortMessages(String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Colors.blue),
      child: Text(text),
      onPressed: _openSMSPage,
    );
  }

  Widget btnSettingsPage(String text) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Colors.blue),
        child: Text(text),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AppSettingsPage()));
        });
  }

  void _openChatPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ChatPage()));
  }

  void _openFriendsPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => FriendsPage()));
  }

  void _openSMSPage() {
    if (AppParameters.canSeeLastSeen && AppParameters.currentUser == "akbar")
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ShortMessagesPage()));
  }

  Future<void> getFriendsListFromServer() async {
    clrGetweb = Colors.grey;
    setState(() {});
    friends = await Friends.getWebFriendFriendsList();
    clrGetweb = Colors.brown;
    setState(() {});
  }

  Future<void> getMessagesFromServer() async {
    clrGetweb = Colors.grey;
    setState(() {});
    messages = await ApMeMessages.getWebNewMessages(true);
    clrGetweb = Colors.brown;
    setState(() {});
  }

  void getAllFromServer() async {
    await getFriendsListFromServer();
    await getMessagesFromServer();
  }

  void addMessage() async {
    var message = new ApMeMessage(
        messageId: 101,
        fromId: "akbar",
        toId: "mahnaz",
        messageBody: "Test Upload",
        uploaded: 3,
        sentAt: DateTime.now().microsecondsSinceEpoch);
    await message.insert();
    setupList();
  }

  void addUser() async {
    var user = new Friend(
      friendId: "akbar",
      firstName: "mahnaz",
      lastName: "پورخجسته",
    );
    await user.insert();
    setupList();
  }

  void setupList() async {
    // var _messages = await Messages.fetchFriendMessages(AppParameters.currentUser,AppParameters.currentFriend);
    var _messages =
        await ApMeMessages.getLocalMessages(int.parse(countController.text));
    var _users = await Friends.getLocalFriendsList();
    print(_messages.length.toString() + " Messages Saved to Bank");
    print(_users.length.toString() + " Users Saved to Bank");
    setState(() {
      messages = _messages;
      users = _users;
    });
  }

  onDelete(ApMeMessage message) async {
    await message.delete();
    setupList();
  }

  TextStyle myStyle() {
    return TextStyle(
      fontSize: 12,
      color: AppSettings.formsForegroundColor,
    );
  }

  Widget _buildUsersList(List<Friend> usersList) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: usersList.length,
        itemBuilder: (BuildContext context, int index) {
          return Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text('Id', style: myStyle()),
                    Text(usersList[index].friendId.toString(),
                        style: myStyle()),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text('Name', style: myStyle()),
                    Text(
                        usersList[index].firstName +
                            " " +
                            usersList[index].lastName,
                        style: myStyle()),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text('S:', style: myStyle()),
                    Text(usersList[index].lastName, style: myStyle()),
                  ],
                ),
              ),
              Expanded(
                child: Material(
                  child: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      usersList[index].delete();
                    },
                  ),
                ),
              ),
              Expanded(
                child: Material(
                  child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      usersList[index].insert();
                    },
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageList(List<ApMeMessage> messagesList) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: messagesList.length,
        itemBuilder: (BuildContext context, int index) {
          return Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text('Id', style: myStyle()),
                    Text(messagesList[index].messageId.toString(),
                        style: myStyle()),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text('Up Ty DA', style: myStyle()),
                    Text(
                        messagesList[index].uploaded.toString() +
                            " " +
                            messagesList[index].messageType.toString() +
                            " " +
                            (messagesList[index].deliveredAt ~/ 100000)
                                .toString(),
                        style: myStyle()),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text('From', style: myStyle()),
                    Text(messagesList[index].fromId, style: myStyle()),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text('To', style: myStyle()),
                    Text(messagesList[index].toId.toString(), style: myStyle()),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text('Body', style: myStyle()),
                    Text(messagesList[index].messageBody.toString(),
                        style: myStyle()),
                  ],
                ),
              ),
              Expanded(
                child: Material(
                  child: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      onDelete(messagesList[index]);
                    },
                  ),
                ),
              ),
              Expanded(
                child: Material(
                  child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      messagesList[index].insert();
                    },
                  ),
                ),
              )
            ],
          );
        },
        reverse: false,
      ),
    );
  }
}
