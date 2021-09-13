import 'package:ap_me/Friends.dart';
import 'package:ap_me/ApMeUtils.dart';
import 'package:ap_me/AppParameters.dart';
import 'package:ap_me/ChatPage.dart';
import 'package:ap_me/ApMeMessages.dart';
import 'package:ap_me/FriendsPage.dart';
import 'package:ap_me/PartnersPage.dart';
import 'package:ap_me/ShortMessagesPage.dart';
import 'package:ap_me/TempMessages.dart';
import 'package:ap_me/Tmp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<ApMeMessage> messages = [];
  List<Friend> users = [];
  Color clrGetweb = Colors.brown;
  @override
  Widget build(BuildContext context) {
    AppParameters.currentUser = "akbar";
    //AppParameters.currentFriend="sohail";
    return Container(
      alignment: Alignment.topCenter,
      color: Colors.green[300],
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 20),
              // btnAddMessage("Add User"),
              //btnAddUser("Add User"),
              btnSendMessageUpdates("Send"),

              btnRefresh("Refresh"),

              btnRefreshWeb("Get Web"),

              // btnSaveLocal("Save Local"),
              // SizedBox(width: 20),
              btnClear("Clear"),

              //  btnFriends("Friends"),
              btnShortMessages("Mess"),
              SizedBox(width: 20),
            ],
          ),
          _buildMessageList(messages),
          //_buildUsersList(users),
        ],
      ),
    );
  }

  Widget btnAddMessage(String text) {
    return RaisedButton(
      color: Colors.red,
      child: Text(text),
      onPressed: addMessage,
    );
  }

  Widget btnAddUser(String text) {
    return RaisedButton(
      color: Colors.red,
      child: Text(text),
      onPressed: addUser,
    );
  }

  Widget btnSendMessageUpdates(String text) {
    return RaisedButton(
      color: Colors.red,
      child: Text(text),
      onPressed: () {
        ApMeMessages.syncMessages();
      },
    );
  }

  Widget btnRefresh(String text) {
    return RaisedButton(
      color: Colors.red,
      child: Text(text),
      onPressed: setupList,
    );
  }

  Widget btnRefreshWeb(String text) {
    return RaisedButton(
      color: clrGetweb,
      child: Text(text),
      onPressed: getMessagesFromServer,
    );
  }

  Widget btnClear(String text) {
    return RaisedButton(
      color: Colors.blue,
      child: Text(text),
      onPressed: () {
        ApMeMessages.clearAllLocalMessages();
        TempMessages.clearAllTempMessages();
        setupList();
      },
    );
  }

  Widget btnFriends(String text) {
    return RaisedButton(
      color: Colors.blue,
      child: Text(text),
      onPressed: _openFriendsPage,
    );
  }

  Widget btnShortMessages(String text) {
    return RaisedButton(
      color: Colors.blue,
      child: Text(text),
      onPressed: _openSMSPage,
    );
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
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ShortMessagesPage()));
  }

  void getMessagesFromServer() async {
    clrGetweb = Colors.grey;
    setState(() {});
    messages = await ApMeMessages.getWebNewMessages(true);
    clrGetweb = Colors.brown;
    setState(() {});
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
    var _messages = await ApMeMessages.getLocalMessages(10000);
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
      color: Colors.black,
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
                    Text('Remark', style: myStyle()),
                    Text(usersList[index].remark, style: myStyle()),
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
      ),
    );
  }
}
