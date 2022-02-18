import 'package:ap_me/AdminPage.dart';
import 'package:ap_me/LoginDialog.dart';
import 'package:ap_me/Themes.dart';
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
                  "تم",
                  textDirection: TextDirection.rtl,
                  style: new TextStyle(
                    color: AppSettings.formsForegroundColor,
                    fontSize: AppSettings.messageBodyFontSize,
                  ),
                ),
                leading: Icon(
                  AppSettings.nightMode
                      ? Icons.nightlight_outlined
                      : Icons.wb_sunny_outlined,
                  color: AppSettings.formsForegroundColor,
                ),
                onTap: () async {
                  await AppSettings.saveNightMode(!AppSettings.nightMode);
                  if (AppSettings.nightMode) {
                    await Themes.setToBrownTheme();
                  } else {
                    await Themes.setToGreenTheme();
                  }
                  parent.setState(() {});
                },
              ),
              ListTile(
                tileColor: AppSettings.formsBackgroundColor,
                title: Text(
                  "فونت درشت‌تر",
                  textDirection: TextDirection.rtl,
                  style: new TextStyle(
                    color: AppSettings.formsForegroundColor,
                    fontSize: AppSettings.messageBodyFontSize,
                  ),
                ),
                leading: Icon(Icons.arrow_drop_up,
                    color: AppSettings.messageBodyFontSize > 17
                        ? AppSettings.disabledForegroundColor
                        : AppSettings.formsForegroundColor),
                onTap: () {
                  parent.setState(() {
                    if (AppSettings.messageBodyFontSize > 17) return;
                    AppSettings.saveMessageBodyFontSize(
                        ++AppSettings.messageBodyFontSize);
                    AppSettings.saveMessageDateFontSize(
                        AppSettings.messageBodyFontSize * 6 / 10);
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
                    fontSize: AppSettings.messageBodyFontSize,
                  ),
                ),
                leading: Icon(
                  Icons.arrow_drop_down,
                  color: AppSettings.messageBodyFontSize < 8
                      ? AppSettings.disabledForegroundColor
                      : AppSettings.formsForegroundColor,
                ),
                onTap: () {
                  parent.setState(() {
                    if (AppSettings.messageBodyFontSize < 8) return;
                    AppSettings.saveMessageBodyFontSize(
                        --AppSettings.messageBodyFontSize);
                    AppSettings.saveMessageDateFontSize(
                        AppSettings.messageBodyFontSize * 6 / 10);
                  });
                },
              ),
              ListTile(
                tileColor: AppSettings.formsBackgroundColor,
                title: Text(
                  "تم آبی",
                  textDirection: TextDirection.rtl,
                  style: new TextStyle(
                    color: AppSettings.formsForegroundColor,
                    fontSize: AppSettings.messageBodyFontSize,
                  ),
                ),
                leading: Icon(
                  Icons.color_lens,
                  color: Colors.blue,
                ),
                onTap: () async {
                  await Themes.setToBlueTheme();
                  parent.setState(() {});
                },
              ),
              ListTile(
                tileColor: AppSettings.formsBackgroundColor,
                title: Text(
                  "تم کهربایی",
                  textDirection: TextDirection.rtl,
                  style: new TextStyle(
                    color: AppSettings.formsForegroundColor,
                    fontSize: AppSettings.messageBodyFontSize,
                  ),
                ),
                leading: Icon(
                  Icons.color_lens,
                  color: Colors.amber,
                ),
                onTap: () async {
                  await Themes.setToAmberTheme();
                  parent.setState(() {});
                },
              ),
              Visibility(
                visible: AppParameters.canCheckBiometric,
                child: ListTile(
                  tileColor: AppSettings.formsBackgroundColor,
                  title: Text(
                    "اثر انگشت",
                    textDirection: TextDirection.rtl,
                    style: new TextStyle(
                      color: AppSettings.formsForegroundColor,
                      fontSize: AppSettings.messageBodyFontSize,
                    ),
                  ),
                  leading: Switch(
                    activeColor: AppSettings.formsForegroundColor,
                    inactiveThumbColor: AppSettings.disabledForegroundColor,
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
                    tileColor: AppSettings.formsBackgroundColor,
                    title: Text(
                      "تنظیمات ",
                      textDirection: TextDirection.rtl,
                      style: new TextStyle(
                        color: AppSettings.formsForegroundColor,
                        fontSize: AppSettings.messageBodyFontSize,
                      ),
                    ),
                    leading: Icon(
                      Icons.admin_panel_settings,
                      color: AppSettings.formsForegroundColor,
                    ),
                    onTap: () {
                      openAdminPage(parent.context);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  static void openAdminPage(BuildContext context) {
    if (AppParameters.currentUser == 'admin')
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => AdminPage()));
    else {
      return LoginDialog().showLoginDialog(context);
    }
    // .push(MaterialPageRoute(builder: (context) => Tmp()));
  }
}
