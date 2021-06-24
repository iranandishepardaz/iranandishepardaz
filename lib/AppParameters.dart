import 'package:ap_me/AppDatabase.dart';

class AppParameters {
  static double iconsSize = 30;
  static String macAddress = "63:36:0F:05:92:E3";
  static String currentUser = "";
  static String currentPassword = "";
  static String currentFriend = "";
  static String firstName = "";
  static String lastName = "";
  static String prefix = "";
  static const String DatabaseName = "ApMe";
  // static String mainSiteURL = "http://192.168.1.12/";
  static String mainSiteURL = "http://mes.apcoware.ir/";
  //static String mainSiteURL = "http://akbarapco-001-site1.itempurl.com/";
  static String currentFriendAvatarUrl() {
    return userAvatarUrl(currentFriend);
  }

  static String currentUserAvatarUrl() {
    return userAvatarUrl(currentUser);
  }

  static int newMessagesCount = 0;

  static String userAvatarUrl(String userName) {
    return mainSiteURL + "images/pf/" + userName + ".jpg";
  }

  static const refreshPeriod = const Duration(seconds: 30);
  static bool chatPageNeedsRefresh = false;
}
