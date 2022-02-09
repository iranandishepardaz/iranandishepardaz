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
          color: AppParameters.formsBackgroundColor,
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                  decoration: new BoxDecoration(
                    border: new Border.all(
                        color: AppParameters.titlesBackgroundColor, width: 4),
                    color: AppParameters.formsBackgroundColor,
                  ),
                  accountName: Text(
                    "ApMe Messenger ",
                    style: new TextStyle(
                      color: AppParameters.formsForegroundColor,
                    ),
                  ),
                  accountEmail: Text(
                    " ",
                    // "نام‌کاربری" + ":" + "  " + App_Parameters.currentUserName,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                      color: AppParameters.formsForegroundColor,
                    ),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: AssetImage("assets/apmeLogo.png"),
                  )),
              ListTile(
                tileColor: AppParameters.formsBackgroundColor,
                title: Text(
                  "Settings",
                  textDirection: TextDirection.rtl,
                  style: new TextStyle(
                    color: AppParameters.formsForegroundColor,
                  ),
                ),
                leading: Icon(
                  Icons.settings,
                  color: AppParameters.formsForegroundColor,
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
                tileColor: AppParameters.formsBackgroundColor,
                title: Text(
                  "تم",
                  textDirection: TextDirection.rtl,
                  style: new TextStyle(
                    color: AppParameters.formsForegroundColor,
                  ),
                ),
                leading: Icon(
                  AppSettings.nightMode
                      ? Icons.nightlight_outlined
                      : Icons.wb_sunny_outlined,
                  color: AppParameters.formsForegroundColor,
                ),
                onTap: () {
                  parent.setState(() {
                    //AppSettings.nightMode = !AppSettings.nightMode;
                    AppSettings.saveNightMode(!AppSettings.nightMode);
                    //AppSettings.getNightMode();
                  });
                },
              ),
              ListTile(
                tileColor: AppParameters.formsBackgroundColor,
                title: Text(
                  "فونت درشت‌تر",
                  textDirection: TextDirection.rtl,
                  style: new TextStyle(
                    color: AppParameters.formsForegroundColor,
                  ),
                ),
                leading: Icon(Icons.arrow_drop_up,
                    color: AppParameters.formsForegroundColor),
                onTap: () {
                  parent.setState(() {
                    AppParameters.messageFontSize++;
                    AppParameters.messageDateFontSize =
                        AppParameters.messageFontSize * 6 / 10;
                    AppSettings.setMessageFontSize(
                        AppParameters.messageFontSize);
                    AppSettings.setMessageDateFontSize(
                        AppParameters.messageDateFontSize);
                  });
                },
              ),
              ListTile(
                tileColor: AppParameters.formsBackgroundColor,
                title: Text(
                  "فونت ریزتر",
                  textDirection: TextDirection.rtl,
                  style: new TextStyle(
                    color: AppParameters.formsForegroundColor,
                  ),
                ),
                leading: Icon(
                  Icons.arrow_drop_down,
                  color: AppParameters.formsForegroundColor,
                ),
                onTap: () {
                  parent.setState(() {
                    if (AppParameters.messageFontSize < 6) return;
                    AppParameters.messageFontSize--;
                    AppParameters.messageDateFontSize =
                        AppParameters.messageFontSize * 6 / 10;
                    AppSettings.setMessageFontSize(
                        AppParameters.messageFontSize);
                    AppSettings.setMessageDateFontSize(
                        AppParameters.messageDateFontSize);
                    /* AppSetting(
                                      settingName: "messageFontSize",
                                      settingValue:
                                          AppParameters.messageFontSize.toString())
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
