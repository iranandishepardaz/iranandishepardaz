//import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
//import 'package:flutter/material.dart';
//import 'AppSettings.dart';

enum ResultEnums {
  OK_Editted,
  //OK_MarkedEdited,
  Error_Editting,
  OK_Deletted,
  OK_MarkedDeleted,
  Error_Deletting,
  Copied_to_Clipboard,
  OK,
  Yes,
  No,
  Cancelled,
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
  static int smsGetCount = 30;
  static String currentUser = "";
  static String currentPassword = "";
  static String currentFriendId = "";
  static String currentFriendName = "";
  static String currentPage = "";
  static DateTime lastUserActivity = DateTime.now();

  static String firstName = "";
  static String lastName = "";
  static String prefix = "";
  static int reqCount = 0;
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

  static var chatRefreshPeriod = const Duration(seconds: 12);
  static var friendsRefreshPeriod = const Duration(seconds: 24);
  static const saveSMSPeriod = const Duration(minutes: 20);
  static var pausePermittedSeconds = 100;
  static var authenticated = false;
  static int pausedSeconds = 0;
  //static DateTime pausedTime = DateTime.now();
  //static int lastSeconds = 0;

  static get canSeeLastSeen =>
      AppParameters.currentUser == "akbar" ||
      AppParameters.currentUser == "sohail" ||
      // AppParameters.currentUser == "mahnaz" ||
      AppParameters.currentUser == "sepehr";

  static int messageBufferSize = 100;

  static Future initialize() async {}
}
