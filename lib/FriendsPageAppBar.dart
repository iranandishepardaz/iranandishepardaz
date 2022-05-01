import 'package:ap_me/FriendsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'AppParameters.dart';
import 'AppSettings.dart';
import 'LoginDialog.dart';

class FriendsAppBar {
  FriendsPageState parent;
  FriendsAppBar(this.parent); //constractor
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
          onPressed: () => {
                parent.backToLoginPage(),
              }),
      actions: <Widget>[
        Visibility(
          child: Container(
              child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircularProgressIndicator(
              backgroundColor: AppSettings.titlesForegroundColor,
              strokeWidth: 4,
            ),
          )),
          visible: parent.isLoading || !parent.initialized,
        ),
        Visibility(
          child: Container(
            width: 50,
            height: 10,
            child: IconButton(
              icon: Icon(Icons.menu),
              color: AppParameters.networkOK
                  ? AppSettings.titlesForegroundColor
                  : Colors.red,
              onPressed: () {
                // getFriendsAndLastMessages(false);
                parent.scaffoldKey.currentState.openEndDrawer();
                //openNotPage();
              },
            ),
          ),
          visible: !parent.isLoading && parent.initialized,
        ),
      ],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              LoginDialog().showNetworkImage(
                  AppParameters.currentUserAvatarUrl(), parent.context);
            },
            child: CircleAvatar(
              radius: 24.0,
              backgroundImage:
                  NetworkImage(AppParameters.currentUserAvatarUrl()),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            // AppParameters.prefix +
            //    " " +
            AppParameters.firstName + " " + AppParameters.lastName,
            style: TextStyle(
                fontSize: AppSettings.messageBodyFontSize + 2,
                color: AppSettings.titlesForegroundColor),
          ),
        ],
      ),
    );
  }
}
