import 'package:flutter/material.dart';

import 'AppParameters.dart';
import 'AppSettings.dart';
import 'AppSettingsPage.dart';

class OptionsDrawer {
  static SideDrawer(State parent) {
    return Container(
      width: 180,
      child: Drawer(
        child: Container(
          width: 180,
          color: AppSettings.formsBackgroundColor,
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                  decoration: new BoxDecoration(
                    border: new Border.all(
                        color: AppSettings.titlesBackgroundColor, width: 4),
                    color: AppSettings.formsBackgroundColor,
                  ),
                  accountName: Text(
                    "ApMe Messenger ",
                    style: new TextStyle(
                      color: AppSettings.formsForegroundColor,
                    ),
                  ),
                  accountEmail: Text(
                    " ",
                    // "نام‌کاربری" + ":" + "  " + App_Parameters.currentUserName,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                      color: AppSettings.formsForegroundColor,
                    ),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: AssetImage("assets/apmeLogo.png"),
                  )),
              ListTile(
                tileColor: AppSettings.formsBackgroundColor,
                title: Text(
                  "Settings",
                  textDirection: TextDirection.rtl,
                  style: new TextStyle(
                    color: AppSettings.formsForegroundColor,
                  ),
                ),
                leading: Icon(
                  Icons.settings,
                  color: AppSettings.formsForegroundColor,
                ),
                onTap: () {
                  Navigator.of(parent.context).push(
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
                                    begin: Offset(1, 0), end: Offset(0, 0))
                                .animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOutSine)),
                          );
                        }),
                  );
                },
              ),
              ListTile(
                tileColor: AppSettings.formsBackgroundColor,
                title: Text(
                  "تم",
                  textDirection: TextDirection.rtl,
                  style: new TextStyle(
                    color: AppSettings.formsForegroundColor,
                  ),
                ),
                leading: Icon(
                  AppSettings.nightMode
                      ? Icons.nightlight_outlined
                      : Icons.wb_sunny_outlined,
                  color: AppSettings.formsForegroundColor,
                ),
                onTap: () {
                  parent.setState(() {
                    //AppSettings.nightMode = !AppSettings.nightMode;
                    // AppSettings.nightMode = (!AppSettings.nightMode);
                    AppSettings.saveNightMode(!AppSettings.nightMode);
                    //AppSettings.getNightMode();
                  });
                },
              ),
              ListTile(
                tileColor: AppSettings.formsBackgroundColor,
                title: Text(
                  "فونت درشت‌تر",
                  textDirection: TextDirection.rtl,
                  style: new TextStyle(
                    color: AppSettings.formsForegroundColor,
                  ),
                ),
                leading: Icon(Icons.arrow_drop_up,
                    color: AppSettings.formsForegroundColor),
                onTap: () {
                  parent.setState(() {
                    AppSettings.messageBodyFontSize++;
                    AppSettings.messageDateFontSize =
                        AppSettings.messageBodyFontSize * 6 / 10;
                    AppSettings.saveMessageBodyFontSize(
                        AppSettings.messageBodyFontSize);
                    AppSettings.saveMessageDateFontSize(
                        AppSettings.messageDateFontSize);
                  });
                },
              ),
              ListTile(
                tileColor: AppSettings.formsBackgroundColor,
                title: Text(
                  "فونت ریزتر",
                  textDirection: TextDirection.rtl,
                  style: new TextStyle(
                    color: AppSettings.formsForegroundColor,
                  ),
                ),
                leading: Icon(
                  Icons.arrow_drop_down,
                  color: AppSettings.formsForegroundColor,
                ),
                onTap: () {
                  parent.setState(() {
                    if (AppSettings.messageBodyFontSize < 6) return;
                    AppSettings.messageBodyFontSize--;
                    AppSettings.messageDateFontSize =
                        AppSettings.messageBodyFontSize * 6 / 10;
                    AppSettings.saveMessageBodyFontSize(
                        AppSettings.messageBodyFontSize);
                    AppSettings.saveMessageDateFontSize(
                        AppSettings.messageDateFontSize);
                    /* AppSetting(
                                      settingName: "messageFontSize",
                                      settingValue:
                                          AppSettings.messageBodyFontSize.toString())
                                  .insert();
                              AppSetting(
                                      settingName: "messageDateFontSize",
                                      settingValue: AppParameters
                                          .messageDateFontSize
                                          .toString())
                                  .insert();*/
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
