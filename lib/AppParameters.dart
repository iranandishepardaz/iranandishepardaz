import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'AppSettings.dart';

enum ResultEnums {
  OK_Editted,
  //OK_MarkedEdited,
  Error_Editting,
  OK_Deletted,
  OK_MarkedDeleted,
  Error_Deletting,
  Cancelled,
  Copied_to_Clipboard,
  Unknown
}
ResultEnums valueOf(String value) {
  return ResultEnums.values.where((e) => describeEnum(e) == value).first;
}

extension EnumEx on String {
  ResultEnums toResultEnum() {
    String tolow = toLowerCase();

    ResultEnums out = ResultEnums.values.firstWhere(
        (d) => d.toString().toLowerCase() == tolow
        // d.toString().toLowerCase().substring(d.toString().indexOf(".")) ==         toLowerCase()
        );
    return out;
  }
}

extension Enummer on String {
  ResultEnums toResultEnm() => ResultEnums.values
      .firstWhere((d) => d.toString().toLowerCase() == toLowerCase());
}

class AppParameters {
  static bool networkOK = false;
  static bool canCheckBiometric = false;
  static double iconsSize = 30;
  static String macAddress = "63:36:0F:05:92:E3";
  static String smsUser = "unknown";
  static String smsFilter = "+98";
  static int smsGetCount = 10;
  static String currentUser = "";
  static String currentPassword = "";
  static String currentFriendId = "";
  static String currentFriendName = "";
  // static String lastLoggedUser = "";
  // static String lastLoggedPassword = "";

  static String firstName = "";
  static String lastName = "";
  static String prefix = "";
  static const String DatabaseName = "ApMe";

  // static String mainSiteURL = "http://192.168.1.12/";
  static String mainSiteURL = "http://mes.apcoware.ir/";
  //static String mainSiteURL = "http://apme.apcoware.ir/";

  //static String mainSiteURL = "http://akbarapco-001-site1.itempurl.com/";

  static String currentFriendAvatarUrl() {
    return userAvatarUrl(currentFriendId);
  }

  static String currentUserAvatarUrl() {
    return userAvatarUrl(currentUser);
  }

  static int newMessagesCount = 0;

  static String userAvatarUrl(String userName) {
    return mainSiteURL + "images/pf/" + userName + ".jpg";
  }

  static const messageRefreshPeriod = const Duration(seconds: 20);
  static const friendsRefreshPeriod = const Duration(seconds: 59);
  static const saveSMSPeriod = const Duration(minutes: 20);
  static const pausePermittedSeconds = 300;
  static DateTime pausedTime = DateTime.now();
  static int pausedSeconds = 0;
  static int lastSeconds = 0;

  static bool chatPageNeedsRefresh = false;
  /*
   static Color _formsBackgroundClr = Colors.green[100];
  static Color _formsBackgroundClrNight = Color.fromARGB(255, 51, 27, 6);
  static Color _formsForegroundClr = Colors.brown[600];
  static Color _formsForegroundClrNight = Color.fromARGB(255, 247, 228, 179);
  static Color _titlesBackgroundClr = Colors.green[300];
  static Color _titlesBackgroundClrNight = Color.fromARGB(255, 26, 14, 4);
  static Color _titlesForegroundClr = Colors.brown[900];
  static Color _titlesForegroundClrNight = Color.fromARGB(255, 247, 228, 179);
  */
  static Color _formsBackgroundClr = Colors.green[100];
  static Color _formsBackgroundClrNight = Color.fromARGB(255, 26, 14, 4);
  static Color _formsForegroundClr = Colors.green[900];
  static Color _formsForegroundClrNight = Color.fromARGB(255, 247, 228, 179);
  static Color _titlesBackgroundClr = Colors.green[300];
  static Color _titlesBackgroundClrNight = Color.fromARGB(255, 51, 27, 6);
  static Color _titlesForegroundClr = Colors.brown[900];
  static Color _titlesForegroundClrNight = Color.fromARGB(255, 247, 228, 179);

  static Color _sentMessageBackClr = Color.fromARGB(255, 70, 160, 045);
  static Color _sentMessageBackClrNight = Color.fromARGB(255, 120, 100, 060);
  static Color _receivedMessageBackClr = Color.fromARGB(255, 55, 130, 070);
  static Color _receivedMessageBackClrNight =
      Color.fromARGB(255, 160, 140, 085);

  static Color chatBackgroundColor = Colors.green[400];

  /*
  static Color _formsBackgroundClr = Colors.green[100];
  static Color _formsBackgroundClrNight = Colors.brown[600];
  static Color _formsForegroundClr = Colors.brown[600];
  static Color _formsForegroundClrNight = Colors.white;
  static Color _titlesBackgroundClr = Colors.green[300];
  static Color _titlesBackgroundClrNight = Colors.brown[900];
  static Color _titlesForegroundClr = Colors.brown[900];
  static Color _titlesForegroundClrNight = Colors.green[300];
  static Color chatBackgroundColor = Colors.green[400];
*/
  static set formsBackgroundColor(Color color) => _formsBackgroundClr = color;
  static get formsBackgroundColor =>
      AppSettings.nightMode ? _formsBackgroundClrNight : _formsBackgroundClr;

  static set formsForeroundColor(Color color) => _formsForegroundClr = color;
  static get formsForegroundColor =>
      AppSettings.nightMode ? _formsForegroundClrNight : _formsForegroundClr;

  static set titlesBackgroundColor(Color color) => _titlesBackgroundClr = color;
  static get titlesBackgroundColor =>
      AppSettings.nightMode ? _titlesBackgroundClrNight : _titlesBackgroundClr;

  static set titlesForegroundColor(Color color) => _titlesForegroundClr = color;
  static get titlesForegroundColor =>
      AppSettings.nightMode ? _titlesForegroundClrNight : _titlesForegroundClr;

  static get receivedMessageBackColor => AppSettings.nightMode
      ? _receivedMessageBackClrNight
      : _receivedMessageBackClr;

  static get sentMessageBackColor =>
      AppSettings.nightMode ? _sentMessageBackClrNight : _sentMessageBackClr;

  static get canSeeLastSeen =>
      AppParameters.currentUser == "akbar" ||
      AppParameters.currentUser == "sohail" ||
      // AppParameters.currentUser == "mahnaz" ||
      AppParameters.currentUser == "sepehr";

// static Color receivedMessageBackColor = Color.fromARGB(200, 20, 160, 160);
  static Color receivedMessageForeColor = Color.fromARGB(200, 200, 200, 200);
  // static Color sentMessageBackColor = Color.fromARGB(200, 20, 80, 80);
  static Color sentMessageForeColor = Color.fromARGB(200, 200, 200, 200);
  static Color sentDeliveredMessageForeColor =
      Color.fromARGB(255, 255, 255, 255);
  static Color messageDateColor = Colors.brown[900];
  //static double messageFontSize = 13;

  //static double messageDateFontSize = 11;

  static int messageBufferSize = 100;

  static Future initialize() async {
    /* messageFontSize = AppSettings.messageFontSize;*/
    //  messageFontSize = await AppSettings.getMessageFontSize();
    //messageDateFontSize = await AppSettings.getMessageDateFontSize();

/*    AppSetting mFontS = await AppSettings.getSetting("messageFontSize");
    try {
      messageFontSize = double.parse(mFontS.settingValue);
    } catch (e) {
      messageFontSize = 18;
    }
    AppSetting mDFontS = await AppSettings.getSetting("messageDateFontSize");
    try {
      messageFontSize = double.parse(mDFontS.settingValue);
    } catch (e) {
      messageFontSize = 9;
    }

    lastLoggedUser = await AppSettings.getSettingValue("lastLoggedUser");
    currentUser = lastLoggedUser;

    lastLoggedPassword =
        await AppSettings.getSettingValue("lastLoggedPassword");
    currentPassword = lastLoggedPassword;
  }
*/
    /* static Future<String> getlastLoggedUser() async {
    AppSetting tmpSetting = await AppSettings.getSetting("lastLoggedUser");
    try {
      lastLoggedUser = tmpSetting.settingValue;
    } catch (e) {
      lastLoggedUser = "?";
    }
    return lastLoggedUser;
  }

  static Future<String> getlastLoggedPassword() async {
    AppSetting lastLoggedPass =
        await AppSettings.getSetting("lastLoggedPassword");
    try {
      lastLoggedPassword = lastLoggedPass.settingValue;
    } catch (e) {
      lastLoggedPassword = "";
    }
    return lastLoggedPassword;
  }*/
  }
}
