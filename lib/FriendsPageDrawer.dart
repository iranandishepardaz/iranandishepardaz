import 'package:ap_me/AdminPage.dart';
import 'package:ap_me/LoginDialog.dart';
import 'package:flutter/material.dart';

import 'AppParameters.dart';
import 'AppSettings.dart';
import 'AppSettingsPage.dart';

class FriendsPageDrawer {
  static sideDrawer(State parent) {
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
                  "تم",
                  textDirection: TextDirection.rtl,
                  style: new TextStyle(
                    color: AppParameters.formsForegroundColor,
                    fontSize: AppSettings.messageBodyFontSize,
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
                    AppSettings.nightMode = !AppSettings.nightMode;
                    AppSettings.saveNightMode(AppSettings.nightMode);
                    // AppSettings.saveSetting(
                    //    "NightMode", (AppSettings.nightMode).toString());
                    //AppSettings.saveNightMode(!AppSettings.nightMode);
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
                    fontSize: AppSettings.messageBodyFontSize,
                  ),
                ),
                leading: Icon(Icons.arrow_drop_up,
                    color: AppParameters.formsForegroundColor),
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
                tileColor: AppParameters.formsBackgroundColor,
                title: Text(
                  "فونت ریزتر",
                  textDirection: TextDirection.rtl,
                  style: new TextStyle(
                    color: AppParameters.formsForegroundColor,
                    fontSize: AppSettings.messageBodyFontSize,
                  ),
                ),
                leading: Icon(
                  Icons.arrow_drop_down,
                  color: AppParameters.formsForegroundColor,
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
              Visibility(
                visible: AppParameters.canCheckBiometric,
                child: ListTile(
                  tileColor: AppParameters.formsBackgroundColor,
                  title: Text(
                    "اثر انگشت",
                    textDirection: TextDirection.rtl,
                    style: new TextStyle(
                      color: AppParameters.formsForegroundColor,
                      fontSize: AppSettings.messageBodyFontSize,
                    ),
                  ),
                  leading: Switch(
                    activeColor: AppParameters.sentDeliveredMessageForeColor,
                    inactiveThumbColor: AppParameters.sentMessageForeColor,
                    value: AppSettings.fingerFirst,
                    onChanged: (value) async {
                      parent.setState(() {
                        AppSettings.fingerFirst = value;
                      });
                      AppSettings.savefingerFirst(AppSettings.fingerFirst);
                    },
                  ),
                ),
              ),
              Visibility(
                  visible: AppParameters.canSeeLastSeen,
                  child: ListTile(
                    tileColor: AppParameters.formsBackgroundColor,
                    title: Text(
                      "تنظیمات ",
                      textDirection: TextDirection.rtl,
                      style: new TextStyle(
                        color: AppParameters.formsForegroundColor,
                        fontSize: AppSettings.messageBodyFontSize,
                      ),
                    ),
                    leading: Icon(
                      Icons.admin_panel_settings,
                      color: AppParameters.formsForegroundColor,
                    ),
                    onTap: () {
                      openMainPage(parent.context);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  static void openMainPage(BuildContext context) {
    if (AppParameters.currentUser == 'admin')
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => AdminPage()));
    else {
      return LoginDialog().showLoginDialog(context);
    }
    // .push(MaterialPageRoute(builder: (context) => Tmp()));
  }
}
