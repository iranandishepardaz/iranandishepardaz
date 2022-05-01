import 'package:ap_me/ApMeUtils.dart';
import 'package:ap_me/AppDatabase.dart';
import 'package:ap_me/AppParameters.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}'
      '${alpha.toRadixString(16).padLeft(2, '0')}';
}

extension ColorHex on Color {
  String toHexTriplet() =>
      '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

class AppSettings {
  static const String TableName = "AppSettings";

  static String tableCreator() {
    String sql = "CREATE TABLE " + AppSettings.TableName + "(";
    sql += "settingName TEXT, ";
    sql += "settingValue TEXT, ";
    sql += "PRIMARY KEY(settingName)";
    sql += ")";
    return sql;
  }

  static Future readCurrentSetings() async {
    await readFingerFirst();
    await readNightMode();
    await readPermittedIdleSeconds();
    await readMessageBodyFontSize();
    await readMessageDateFontSize();
    await readLastLoggedUser();
    await readLastLoggedPassword();
    await readDisabledForegroundColor();
    await readFormsBackColor();
    await readTitlesBackColor();
    await readFormsForeColor();
    await readTitlesForeColor();
    await readReceivedMessageBackColor();
    await readSentMessageForeColor();
    await readSentDeliveredMessageForeColor();
    await readReceivedMessageForeColor();
    await readSentMessageBackColor();
  }

  static Future resetToDefaultSetings() async {
    await savefingerFirst(false);
    await saveNightMode(false);
    await savePermittedIdleSeconds(defaultPermittedIdleSeconds);
    await saveMessageBodyFontSize(defaultMessageBodyFontSize);
    await saveMessageDateFontSize(defaultMessageDateFontSize);
    await saveFormsBackColor(defaultFormsBackColor);
    await saveFormsForeColor(defaultFormsForeColor);
    await saveTitlesBackColor(defaultTitlesBackColor);
    await saveTitlesForeColor(defaultTitlesForeColor);
    await saveReceivedMessageBackColor(defaultReceivedMessageBackColor);
    await saveSentMessageForeColor(defaultSentMessageForeColor);
    await saveSentDeliveredMessageForeColor(
        defaultSentDeliveredMessageForeColor);
    await saveReceivedMessageForeColor(defaultReceivedMessageForeColor);
    await saveSentMessageBackColor(defaultSentMessageBackColor);
    await saveDisabledForegroundColor(defaultDisabledForegroundColor);
  }

  static Future<void> clearAllAppSettings() async {
    //var client = await AppDb.db;
    return await AppDatabase.currentDB.delete(AppSettings.TableName);
  }

  static Future<List<AppSetting>> getAllSettings(int count) async {
    List<AppSetting> output = [];
    final Future<List<Map<String, dynamic>>> futureMaps =
        AppDatabase.currentDB.query(
      AppSettings.TableName,
      orderBy: 'settingName ASC',
      limit: count,
    );

    var maps = await futureMaps;
    for (int i = 0; i < maps.length; i++)
      output.add(AppSetting.fromDb(maps[i]));
    return output;
  }

  static Future<AppSetting> fetchSetting() async {
    final Future<List<Map<String, dynamic>>> futureMaps =
        AppDatabase.currentDB.query(
      AppSettings.TableName,
      where: 'settingName = ?',
      whereArgs: ['nightMode'],
      orderBy: 'settingName ASC',
    );

    var maps = await futureMaps;
    if (maps.length != 0) {
      return AppSetting.fromDb(maps.first);
    }
    return null;
  }

  static bool stringToBoolean(String value) {
    return value.toLowerCase() == 'true' || value.toLowerCase() == '1';
  }

  static saveSetting(String name, String value) async {
    try {
      AppSetting tmpSetting =
          AppSetting(settingName: name, settingValue: value);
      await tmpSetting.insert();
    } catch (e) {}
  }

  static Future<String> getSettingValue(String settingName) async {
    AppSetting tmpSetting =
        AppSetting(settingName: settingName, settingValue: "");
    await tmpSetting.fetch();
    return tmpSetting.settingValue;
  }

  static bool _nMode;
  static get nightMode => _nMode == null ? false : _nMode;
  static set nightMode(value) => _nMode = value;
  static saveNightMode(bool nMode) async {
    _nMode = nMode;
    await saveSetting("nightMode", _nMode.toString());
  }

  static Future<bool> readNightMode() async {
    _nMode = stringToBoolean(await getSettingValue("nightMode"));
    return _nMode;
  }

  static bool _fingerFirst;
  static get fingerFirst => _fingerFirst == null ? false : _fingerFirst;
  static set fingerFirst(value) => _fingerFirst = value;

  static savefingerFirst(bool fFirst) async {
    _fingerFirst = fFirst;
    await saveSetting("fingerFirst", fFirst.toString());
  }

  static Future<bool> readFingerFirst() async {
    _fingerFirst = stringToBoolean(await getSettingValue("fingerFirst"));
    return _fingerFirst;
  }

  static double defaultPermittedIdleSeconds = 100;
  static double _permittedIdleSeconds;
  static get permittedIdleSeconds => _permittedIdleSeconds == null
      ? defaultPermittedIdleSeconds
      : _permittedIdleSeconds;
  static set permittedIdleSeconds(value) => _permittedIdleSeconds = value;
  static savePermittedIdleSeconds(double msgFontSize) async {
    _permittedIdleSeconds = msgFontSize;
    await saveSetting("permittedIdleSeconds", msgFontSize.toString());
  }

  static Future<double> readPermittedIdleSeconds() async {
    _permittedIdleSeconds = defaultPermittedIdleSeconds;
    try {
      _permittedIdleSeconds =
          double.parse(await getSettingValue("permittedIdleSeconds"));
    } catch (e) {}
    return _permittedIdleSeconds;
  }

  static double defaultMessageBodyFontSize = 14;
  static double _messageBodyFontSize;
  static get messageBodyFontSize => _messageBodyFontSize == null
      ? defaultMessageBodyFontSize
      : _messageBodyFontSize;
  static set messageBodyFontSize(value) => _messageBodyFontSize = value;
  static saveMessageBodyFontSize(double msgFontSize) async {
    _messageBodyFontSize = msgFontSize;
    await saveSetting("messageBodyFontSize", msgFontSize.toString());
  }

  static Future<double> readMessageBodyFontSize() async {
    _messageBodyFontSize = defaultMessageBodyFontSize;
    try {
      _messageBodyFontSize =
          double.parse(await getSettingValue("messageBodyFontSize"));
    } catch (e) {}
    return _messageBodyFontSize;
  }

  static double defaultMessageDateFontSize = 8.5;
  static double _messageDateFontSize;
  static get messageDateFontSize => _messageDateFontSize == null
      ? defaultMessageDateFontSize
      : _messageDateFontSize;
  static set messageDateFontSize(value) => _messageDateFontSize = value;
  static saveMessageDateFontSize(double msgFontSize) async {
    _messageDateFontSize = msgFontSize;
    await saveSetting("messageDateFontSize", msgFontSize.toString());
  }

  static Future<double> readMessageDateFontSize() async {
    _messageDateFontSize = defaultMessageDateFontSize;
    try {
      _messageDateFontSize =
          double.parse(await getSettingValue("messageDateFontSize"));
    } catch (e) {}
    return _messageDateFontSize;
  }

  static String defaultLastLoggedUser = "-";
  static String _lastLoggedUser;
  static get lastLoggedUser =>
      _lastLoggedUser == null ? defaultLastLoggedUser : _lastLoggedUser;
  static set lastLoggedUser(value) => _lastLoggedUser = value;
  static saveLastLoggedUser(String lLoggedUser) async {
    _lastLoggedUser = lLoggedUser;
    await saveSetting("lastLoggedUser", lLoggedUser);
  }

  static Future<String> readLastLoggedUser() async {
    _lastLoggedUser = await getSettingValue("lastLoggedUser");
    return _lastLoggedUser;
  }

  static String defaultLastLoggedPassword = ".";
  static String _lastLoggedPassword;
  static get lastLoggedPassword => _lastLoggedPassword == null
      ? defaultLastLoggedPassword
      : _lastLoggedPassword;
  static set lastLoggedPassword(value) => _lastLoggedPassword = value;
  static saveLastLoggedPassword(String lastPass) async {
    _lastLoggedPassword = lastPass;
    await saveSetting("lastLoggedPassword", lastPass);
  }

  static Future<String> readLastLoggedPassword() async {
    _lastLoggedPassword = await getSettingValue("lastLoggedPassword");
    return _lastLoggedPassword;
  }

  static Color defaultSentMessageBackColor = Color.fromARGB(255, 70, 160, 045);
  static Color _sentMessageBackColor;
  static get sentMessageBackColor => _sentMessageBackColor == null
      ? defaultSentMessageBackColor
      : _sentMessageBackColor;
  static set sentMessageBackColor(value) => _sentMessageBackColor = value;
  static saveSentMessageBackColor(Color color) async {
    _sentMessageBackColor = color;
    await saveSetting("sentMessageBackColor",
        '#${_sentMessageBackColor.value.toRadixString(16)}');
  }

  static Future<Color> readSentMessageBackColor() async {
    _sentMessageBackColor =
        HexColor.fromHex(await getSettingValue("sentMessageBackColor"));
    return _sentMessageBackColor;
  }

  static Color defaultReceivedMessageBackColor =
      Color.fromARGB(255, 55, 130, 070);
  static Color _receivedMessageBackColor;
  static get receivedMessageBackColor => _receivedMessageBackColor == null
      ? defaultReceivedMessageBackColor
      : _receivedMessageBackColor;
  static set receivedMessageBackColor(value) =>
      _receivedMessageBackColor = value;
  static saveReceivedMessageBackColor(Color color) async {
    _receivedMessageBackColor = color;
    await saveSetting("receivedMessageBackColor",
        '#${_receivedMessageBackColor.value.toRadixString(16)}');
  }

  static Future<Color> readReceivedMessageBackColor() async {
    _receivedMessageBackColor =
        HexColor.fromHex(await getSettingValue("receivedMessageBackColor"));
    return _receivedMessageBackColor;
  }

  static Color defaultSentMessageForeColor = Colors.white60;
  static Color _sentMessageForeColor;
  static get sentMessageForeColor => _sentMessageForeColor == null
      ? defaultSentMessageForeColor
      : _sentMessageForeColor;
  static set sentMessageForeColor(value) => _sentMessageForeColor = value;
  static saveSentMessageForeColor(Color color) async {
    _sentMessageForeColor = color;
    await saveSetting("sentMessageForeColor",
        '#${_sentMessageForeColor.value.toRadixString(16)}');
  }

  static Future<Color> readSentMessageForeColor() async {
    _sentMessageForeColor =
        HexColor.fromHex(await getSettingValue("sentMessageForeColor"));
    return _sentMessageForeColor;
  }

  static Color defaultSentDeliveredMessageForeColor = Colors.white;
  static Color _sentDeliveredMessageForeColor;
  static get sentDeliveredMessageForeColor =>
      _sentDeliveredMessageForeColor == null
          ? defaultSentDeliveredMessageForeColor
          : _sentDeliveredMessageForeColor;
  static set sentDeliveredMessageForeColor(value) =>
      _sentDeliveredMessageForeColor = value;
  static saveSentDeliveredMessageForeColor(Color color) async {
    _sentDeliveredMessageForeColor = color;
    await saveSetting("sentDeliveredMessageForeColor",
        '#${_sentDeliveredMessageForeColor.value.toRadixString(16)}');
  }

  static Future<Color> readSentDeliveredMessageForeColor() async {
    _sentDeliveredMessageForeColor = HexColor.fromHex(
        await getSettingValue("sentDeliveredMessageForeColor"));
    return _sentDeliveredMessageForeColor;
  }

  static Color defaultReceivedMessageForeColor = Colors.white;
  static Color _receivedMessageForeColor;
  static get receivedMessageForeColor => _receivedMessageForeColor == null
      ? defaultReceivedMessageForeColor
      : _receivedMessageForeColor;
  static set receivedMessageForeColor(value) =>
      _receivedMessageForeColor = value;
  static saveReceivedMessageForeColor(Color color) async {
    _receivedMessageForeColor = color;
    await saveSetting("receivedMessageForeColor",
        '#${_receivedMessageForeColor.value.toRadixString(16)}');
  }

  static Future<Color> readReceivedMessageForeColor() async {
    _receivedMessageForeColor =
        HexColor.fromHex(await getSettingValue("receivedMessageForeColor"));
    return _receivedMessageForeColor;
  }

  static Color defaultFormsBackColor = Colors.green[100];
  static Color _formsBackgroundColor;
  static get formsBackgroundColor => _formsBackgroundColor == null
      ? defaultFormsBackColor
      : _formsBackgroundColor;
  static set formsBackgroundColor(value) => _formsBackgroundColor = value;
  static saveFormsBackColor(Color color) async {
    _formsBackgroundColor = color;
    await saveSetting("formsBackgroundColor",
        '#${_formsBackgroundColor.value.toRadixString(16)}');
  }

  static Future<Color> readFormsBackColor() async {
    _formsBackgroundColor =
        HexColor.fromHex(await getSettingValue("formsBackgroundColor"));
    return _formsBackgroundColor;
  }

  static Color defaultFormsForeColor = Colors.green[900];
  static Color _formsForegroundColor;
  static get formsForegroundColor => _formsForegroundColor == null
      ? defaultFormsForeColor
      : _formsForegroundColor;
  static set formsForegroundColor(value) => _formsForegroundColor = value;
  static saveFormsForeColor(Color color) async {
    _formsForegroundColor = color;
    await saveSetting("formsForegroundColor",
        '#${_formsForegroundColor.value.toRadixString(16)}');
  }

  static Future<Color> readFormsForeColor() async {
    _formsForegroundColor =
        HexColor.fromHex(await getSettingValue("formsForegroundColor"));
    return _formsForegroundColor;
  }

  static Color defaultTitlesBackColor = Colors.green[300];
  static Color _titlesBackgroundColor;
  static get titlesBackgroundColor => _titlesBackgroundColor == null
      ? defaultTitlesBackColor
      : _titlesBackgroundColor;
  static set titlesBackgroundColor(value) => _titlesBackgroundColor = value;
  static saveTitlesBackColor(Color color) async {
    _titlesBackgroundColor = color;
    await saveSetting("titlesBackgroundColor",
        '#${_titlesBackgroundColor.value.toRadixString(16)}');
  }

  static Future<Color> readTitlesBackColor() async {
    _titlesBackgroundColor =
        HexColor.fromHex(await getSettingValue("titlesBackgroundColor"));
    return _titlesBackgroundColor;
  }

  static Color defaultTitlesForeColor = Colors.green[900];
  static Color _titlesForegroundColor;
  static get titlesForegroundColor => _titlesForegroundColor == null
      ? defaultTitlesForeColor
      : _titlesForegroundColor;
  static set titlesForegroundColor(value) => _titlesForegroundColor = value;
  static saveTitlesForeColor(Color color) async {
    _titlesForegroundColor = color;
    await saveSetting("titlesForegroundColor",
        '#${_titlesForegroundColor.value.toRadixString(16)}');
  }

  static Future<Color> readTitlesForeColor() async {
    _titlesForegroundColor =
        HexColor.fromHex(await getSettingValue("titlesForegroundColor"));
    return _titlesForegroundColor;
  }

  static Color defaultDisabledForegroundColor = Colors.brown[200];
  static Color _disabledForegroundColor;
  static get disabledForegroundColor => _disabledForegroundColor == null
      ? defaultDisabledForegroundColor
      : _disabledForegroundColor;
  static set disabledForegroundColor(value) => _disabledForegroundColor = value;
  static saveDisabledForegroundColor(Color color) async {
    _disabledForegroundColor = color;
    await saveSetting("disabledForegroundColor",
        '#${_disabledForegroundColor.value.toRadixString(16)}');
  }

  static Future<Color> readDisabledForegroundColor() async {
    _disabledForegroundColor =
        HexColor.fromHex(await getSettingValue("disabledForegroundColor"));
    return _disabledForegroundColor;
  }

  static get messageEditStyle => TextStyle(
      backgroundColor: AppSettings.titlesBackgroundColor,
      color: AppSettings.titlesForegroundColor,
      fontSize: messageBodyFontSize);
}

class AppSetting {
  @required
  String settingName;
  @required
  String settingValue;

  AppSetting({
    this.settingName,
    this.settingValue,
  });

  Map<String, dynamic> toMapForDb() {
    return {
      'settingName': settingName,
      'settingValue': settingValue,
    };
  }

  AppSetting.fromDb(Map<String, dynamic> map)
      : settingName = map['settingName'],
        settingValue = map['settingValue'];

  Future fetch() async {
    final Future<List<Map<String, dynamic>>> futureMaps =
        AppDatabase.currentDB.query(
      AppSettings.TableName,
      where: 'settingName = ?',
      whereArgs: [settingName],
    );
    var maps = await futureMaps;
    if (maps.length != 0) {
      settingValue = AppSetting.fromDb(maps.first).settingValue;
    }
  }

  Future<int> insert() async {
    int result = 0;
    try {
      //var client = await AppDb.db;
      result = await AppDatabase.currentDB.insert(
          AppSettings.TableName, toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {}
    print("Insert Setting : " +
        settingName +
        " => " +
        settingValue +
        " result:" +
        result.toString());
    return result;
  }

  Future<int> update() async {
    //var client = await AppDb.db;
    print("Updating setting : from " + settingName + " = " + settingValue);
    return await AppDatabase.currentDB.update(
        AppSettings.TableName, toMapForDb(),
        where: 'settingName = ? ',
        whereArgs: [settingName],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> delete() async {
    //var client = await AppDb.db;
    return await AppDatabase.currentDB.delete(AppSettings.TableName,
        where: 'settingName = ? ', whereArgs: [settingName]);
  }

  Future<List<List<String>>> upload() async {
    List<List<String>> records = await ApMeUtils.fetchData([
      "503",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      settingName.toString(),
      settingValue,
    ]);
    return records;
  }

  Future closeDb() async {
    //var client = await AppDb.db;
    await AppDatabase.currentDB.close();
  }
}

class ColorSetting extends AppSetting {
  Color defaultColor = Colors.white;
}
