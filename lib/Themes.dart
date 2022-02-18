import 'package:flutter/material.dart';

import 'AppSettings.dart';

class Themes {
  static Future setToBrownTheme() async {
    await AppSettings.saveNightMode(true);
    await AppSettings.saveFormsBackColor(Color.fromARGB(255, 26, 14, 4));
    await AppSettings.saveFormsForeColor(Color.fromARGB(255, 247, 228, 179));
    await AppSettings.saveTitlesBackColor(Color.fromARGB(255, 51, 27, 6));
    await AppSettings.saveTitlesForeColor(Color.fromARGB(255, 247, 228, 179));
    await AppSettings.saveSentMessageBackColor(
        Color.fromARGB(255, 120, 100, 060));
    await AppSettings.saveReceivedMessageBackColor(
        Color.fromARGB(255, 160, 140, 085));
    await AppSettings.saveSentMessageForeColor(Colors.white60);
    await AppSettings.saveSentDeliveredMessageForeColor(Colors.white);
    await AppSettings.saveReceivedMessageForeColor(Colors.white);
    await AppSettings.saveDisabledForegroundColor(Colors.brown[200]);
  }

  static Future setToGreenTheme() async {
    await AppSettings.saveNightMode(false);
    await AppSettings.saveFormsBackColor(Colors.green[100]);
    await AppSettings.saveFormsForeColor(Colors.green[900]);
    await AppSettings.saveTitlesBackColor(Colors.green[300]);
    await AppSettings.saveTitlesForeColor(Colors.brown[900]);
    await AppSettings.saveSentMessageBackColor(
        Color.fromARGB(255, 70, 160, 045));
    await AppSettings.saveReceivedMessageBackColor(
        Color.fromARGB(255, 55, 130, 070));
    await AppSettings.saveSentMessageForeColor(Colors.white60);
    await AppSettings.saveSentDeliveredMessageForeColor(Colors.white);
    await AppSettings.saveReceivedMessageForeColor(Colors.white);
    await AppSettings.saveDisabledForegroundColor(Colors.brown[200]);
  }

  static Future setToBlueTheme() async {
    await AppSettings.saveNightMode(true);
    await AppSettings.saveFormsBackColor(Colors.blue[100]);
    await AppSettings.saveFormsForeColor(Colors.blue[900]);
    await AppSettings.saveTitlesBackColor(Color.fromARGB(255, 30, 70, 130));
    await AppSettings.saveTitlesForeColor(Colors.blue[50]);
    await AppSettings.saveSentMessageBackColor(
        Color.fromARGB(255, 10, 30, 120));
    await AppSettings.saveReceivedMessageBackColor(
        Color.fromARGB(255, 30, 70, 130));
    await AppSettings.saveSentMessageForeColor(Colors.white70);
    await AppSettings.saveSentDeliveredMessageForeColor(Colors.white);
    await AppSettings.saveReceivedMessageForeColor(Colors.white);
    await AppSettings.saveDisabledForegroundColor(Colors.brown[200]);
  }

  static Future setToGreen1Theme() async {
    await AppSettings.saveNightMode(true);
    await AppSettings.saveFormsBackColor(Colors.green[100]);
    await AppSettings.saveFormsForeColor(Colors.brown[900]);
    await AppSettings.saveTitlesBackColor(Colors.green[600]);
    await AppSettings.saveTitlesForeColor(Colors.black);
    await AppSettings.saveSentMessageBackColor(Colors.green[700]);
    await AppSettings.saveReceivedMessageBackColor(Colors.green[900]);
    await AppSettings.saveSentMessageForeColor(Colors.green[200]);
    await AppSettings.saveSentDeliveredMessageForeColor(Colors.green[50]);
    await AppSettings.saveReceivedMessageForeColor(Colors.green[100]);
    await AppSettings.saveDisabledForegroundColor(Colors.grey);
  }

  static Future setToAmberTheme() async {
    await AppSettings.saveNightMode(true);
    await AppSettings.saveFormsBackColor(Colors.amber[100]);
    await AppSettings.saveFormsForeColor(Colors.brown[900]);
    await AppSettings.saveTitlesBackColor(Colors.amber[600]);
    await AppSettings.saveTitlesForeColor(Colors.black);
    await AppSettings.saveSentMessageBackColor(Colors.amber[700]);
    await AppSettings.saveReceivedMessageBackColor(Colors.amber[900]);
    await AppSettings.saveSentMessageForeColor(Colors.amber[200]);
    await AppSettings.saveSentDeliveredMessageForeColor(Colors.amber[50]);
    await AppSettings.saveReceivedMessageForeColor(Colors.amber[100]);
    await AppSettings.saveDisabledForegroundColor(Colors.grey);
  }

  static Future setToRedTheme() async {
    await AppSettings.saveNightMode(true);
    await AppSettings.saveFormsBackColor(Colors.red[100]);
    await AppSettings.saveFormsForeColor(Colors.brown[900]);
    await AppSettings.saveTitlesBackColor(Colors.red[600]);
    await AppSettings.saveTitlesForeColor(Colors.red[50]);
    await AppSettings.saveSentMessageBackColor(Colors.red[700]);
    await AppSettings.saveReceivedMessageBackColor(Colors.red[900]);
    await AppSettings.saveSentMessageForeColor(Colors.red[200]);
    await AppSettings.saveSentDeliveredMessageForeColor(Colors.red[50]);
    await AppSettings.saveReceivedMessageForeColor(Colors.red[100]);
    await AppSettings.saveDisabledForegroundColor(Colors.grey);
  }
}
