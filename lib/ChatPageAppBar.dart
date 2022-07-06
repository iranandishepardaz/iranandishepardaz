import 'AppParameters.dart';
import 'ChatPage.dart';
import 'LoginDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'AppParameters.dart';
import 'AppSettings.dart';
//import 'LoginDialog.dart';

class ChatAppBar {
  ChatPageState parent;
  ChatAppBar(this.parent); //constractor
  AppBar appBar() {
    return AppBar(
      //textTheme: TextTheme(),
      //textTheme: TextTheme(bodyText1: TextStyle(color: Colors.yellow)),
      backgroundColor: AppSettings.titlesBackgroundColor,
      foregroundColor: AppSettings.titlesForegroundColor,
      //shadowColor: AppSettings.titlesForegroundColor,
      //backgroundColor: Colors.red[400],
      brightness: AppSettings.nightMode ? Brightness.dark : Brightness.light,
      centerTitle: false,
      titleSpacing: 0.0,
      leadingWidth: 35,
      leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: AppSettings.titlesForegroundColor,
          onPressed: parent.backToFriendsPage),
      title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        GestureDetector(
          onTap: () {
            LoginDialog().showNetworkImage(
                AppParameters.currentFriendAvatarUrl(), parent.context);
          },
          child: CircleAvatar(
            radius: 24.0,
            backgroundImage:
                NetworkImage(AppParameters.currentFriendAvatarUrl()),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          AppParameters.currentFriendName,
          style: TextStyle(
              fontSize: AppSettings.messageBodyFontSize + 2,
              color: AppSettings.titlesForegroundColor),
        ),
      ]),
      actions: [
        IconButton(
          color: AppSettings.titlesForegroundColor,
          onPressed: parent.scrollToLastMessage,
          icon: Icon(Icons.arrow_downward_sharp),
        ),
        Visibility(
          child: Container(
              child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircularProgressIndicator(
              backgroundColor: AppSettings.titlesForegroundColor,
              strokeWidth: 4,
            ),
          )),
          visible: parent.isLoading,
        ),
        Visibility(
          child: Container(
              child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: IconButton(
              //color: AppSettings.titlesForegroundColor,
              color: AppParameters.networkOK
                  ? AppSettings.titlesForegroundColor
                  : Colors.red,
              onPressed: parent.getUnsynced,
              icon: Icon(Icons.cloud_download),
            ),
          )),
          visible: !parent.isLoading,
        ),
      ],
    );
  }
}
