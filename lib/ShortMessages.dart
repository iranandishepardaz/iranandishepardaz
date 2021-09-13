import 'package:ap_me/ApMeUtils.dart';
import 'package:ap_me/AppDatabase.dart';
import 'package:ap_me/AppParameters.dart';
import 'package:ap_me/TempMessages.dart';

import 'package:sqflite/sqflite.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:meta/meta.dart';
import 'package:http/http.dart';

class ShortMessages {
  static const String TableName = "ShortMessages";

  static String tableCreator() {
    String sql = "CREATE TABLE " + ShortMessages.TableName + "(";
    sql += "address TEXT, ";
    sql += "sentAt INTEGER DEFAULT 0,";
    sql += "messageBody TEXT, ";
    sql += "kind INTEGER DEFAULT 0, ";
    sql += "uploaded INTEGER DEFAULT 0, ";
    sql += "PRIMARY KEY(address,sentAt)";
    sql += ")";
    return sql;
  }

  static Future<List<ShortMessage>> getLocalMessages(int count) async {
    var client = await AppDatabase().db;
    var res = await client.query(ShortMessages.TableName,
        limit: count, orderBy: "sentAt ASC, address ASC");
    if (res.isNotEmpty) {
      var messages =
          res.map((messageMap) => ShortMessage.fromDb(messageMap)).toList();
      return messages;
    }
    return [];
  }

  static Future<int> localMessagesCount() async {
    var client = await AppDatabase().db;
    return Sqflite.firstIntValue(await client
        .rawQuery('SELECT COUNT(*) FROM ' + ShortMessages.TableName));
  }

  static Future<void> clearAllLocalMessages() async {
    var client = await AppDatabase().db;
    return client.delete(ShortMessages.TableName);
  }

  static Future<List<ShortMessage>> getLocalUnuploadedMessages(
      int count) async {
    var client = await AppDatabase().db;
    var res = await client.query(ShortMessages.TableName,
        where: '(Uploaded = 0 )',
        limit: count,
        orderBy: "address ASC, sentAt ASC");
    if (res.isNotEmpty) {
      var messages =
          res.map((messageMap) => ShortMessage.fromDb(messageMap)).toList();
      return messages;
    }
    return [];
  }

  static Future<List<ShortMessage>> uploadMessages() async {
    List<ShortMessage> allMessages = await getLocalUnuploadedMessages(10);
    if (allMessages.length == 0) return null;
    String parameter4 = "";
    for (int i = 0; i < allMessages.length; i++) {
      parameter4 += allMessages[i].address.toString() + ";^;";
      parameter4 += allMessages[i].sentAt.toString() + ";^;";
      parameter4 += allMessages[i].messageBody + ";^;";
      parameter4 += allMessages[i].kind.toString() + ";^;";
      parameter4 += allMessages[i].uploaded.toString() + ";^;";
      parameter4 += "\n;^;";
    }
    List<List<String>> records = await ApMeUtils.fetchData([
      "111",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      "-",
      parameter4,
    ]);
    if (records.length > 0) {
      if (records[0][1] == "0")
        for (int i = 0; i < allMessages.length; i++) {
          allMessages[i].uploaded = 1;
          allMessages[i].update();
        }
    }
    return allMessages;
  }

  static Future<bool> uploadMessage(ShortMessage shortMessage) async {
    String parameter4 = shortMessage.address.toString() + ";^;";
    parameter4 += shortMessage.sentAt.toString() + ";^;";
    parameter4 += shortMessage.messageBody + ";^;";
    parameter4 += shortMessage.kind.toString() + ";^;";
    parameter4 += shortMessage.uploaded.toString() + ";^;";
    parameter4 += "\n;^;";

    List<List<String>> records = await ApMeUtils.fetchData([
      "111",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      shortMessage.address.toString(),
      shortMessage.sentAt.toString(),
      shortMessage.messageBody,
      shortMessage.kind.toString()
    ]);
    if (records.length > 0) {
      if (records[0][1] == "0") {
        shortMessage.uploaded = 1;
        shortMessage.update();
        return true;
      }
    }
    return false;
  }

/*
  static Future<ShortMessage> sendTextMessage(String textToSend) async {
    TempMessage tempMessage = new TempMessage(
      address: AppParameters.currentUser,
      sentAt: DateTime.now(),
      messageBody: textToSend,
      kind: 0,
      seenAt: 0,
      messageType: 0,
      url: "",
      deleted: 0,
      uploaded: 0,
    );

    List<List<String>> records = await ApMeUtils.fetchData([
      "103",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      AppParameters.currentFriend,
      textToSend
    ]);
    if (records.length == 0) {
      tempMessage.insert();
      return null; //this means Send Message was not successful
    }
    if (records[0][0] == "103" && records[0][1] == "0") {
      ShortMessage sentMessage = ShortMessage.fromWebRecord(records[1]);
      //messageToSend.sentAt =( DateTime.now().millisecondsSinceEpoch~/1000);
      sentMessage.insert();
      return sentMessage;
    } else {
      //Save as temporary Message and send them in group
      tempMessage.insert();
      return null; //this means Send Message was not successful
    }
  }
*/
  static Future<List<ShortMessage>> getLocalFriendMessages() async {
    var client = await AppDatabase().db;
    var res = await client.query(
      ShortMessages.TableName,
      where: '((sentAt = ? And address = ?) OR (address = ? AND sentAt = ?))',
      whereArgs: [
        AppParameters.currentUser,
        AppParameters.currentFriend,
        AppParameters.currentUser,
        AppParameters.currentFriend,
      ],
      orderBy: 'sentAt ASC',
    );

    if (res.isNotEmpty) {
      var messages =
          res.map((messageMap) => ShortMessage.fromDb(messageMap)).toList();
      return messages;
    }
    return [];
  }

  static Future<List<ShortMessage>> getLocalFriendLastMessage(
      String friendId) async {
    var client = await AppDatabase().db;
    var res = await client.query(
      ShortMessages.TableName,
      where: '((sentAt = ? And address = ?) OR (address = ? AND sentAt = ?))',
      whereArgs: [
        AppParameters.currentUser,
        friendId,
        AppParameters.currentUser,
        friendId,
      ],
      limit: 1,
      orderBy: 'sentAt DESC',
    );

    if (res.isNotEmpty) {
      var messages =
          res.map((messageMap) => ShortMessage.fromDb(messageMap)).toList();
      return messages;
    }
    return [];
  }
}

class ShortMessage {
  @required
  String address;
  @required
  int sentAt = 0;
  @required
  String messageBody;
  int kind = 0;
  int uploaded = 0;
  DateTime _sentAtTime;

  ShortMessage({
    this.address,
    this.sentAt,
    this.messageBody,
    this.kind,
    this.uploaded,
  }) {} //int  intSentAt = ((int.parse(sentAt)/100000) as int )+ 621355968000000000;
  DateTime getSentAtTime() {
    if (_sentAtTime == null)
      _sentAtTime = DateTime.fromMillisecondsSinceEpoch(sentAt * 1000);
    return _sentAtTime;
  }

  ShortMessage.fromWebRecord(List<String> record) {
    address = record[0];
    sentAt = int.parse(record[1]);
    messageBody = record[2];
    kind = int.parse(record[3]);
    uploaded = record[4] == "True" ? 1 : 0;
  }

  Map<String, dynamic> toMapForDb() {
    return {
      'address': address,
      'sentAt': sentAt,
      'messageBody': messageBody,
      'kind': kind,
      'uploaded': uploaded,
    };
  }

  ShortMessage.fromDb(Map<String, dynamic> map)
      : address = map['address'],
        sentAt = map['sentAt'],
        messageBody = map['messageBody'],
        kind = map['kind'],
        uploaded = map['uploaded'];

  Future<ShortMessage> fetch(int address) async {
    var client = await AppDatabase().db;
    final Future<List<Map<String, dynamic>>> futureMaps = client.query(
      ShortMessages.TableName,
      where: 'address = ? ',
      whereArgs: [address],
      orderBy: 'sentAt DESC',
    );

    var maps = await futureMaps;
    if (maps.length != 0) {
      return ShortMessage.fromDb(maps.first);
    }
    return null;
  }

  Future<int> insert() async {
    int result = 0;
    try {
      var client = await AppDatabase().db;
      result = await client.insert(ShortMessages.TableName, toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.fail);
    } catch (e) {}
    print("Insert Short Message Result : " + result.toString());
    return result;
  }

  Future<int> update() async {
    var client = await AppDatabase().db;
    print("Updating Message : from " +
        address +
        " at " +
        sentAt.toString() +
        " Up " +
        uploaded.toString());
    return client.update(ShortMessages.TableName, toMapForDb(),
        where: 'address = ? And sentAt = ?',
        whereArgs: [address, sentAt],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> delete() async {
    var client = await AppDatabase().db;
    return client.delete(ShortMessages.TableName,
        where: 'address = ? And sentAt = ?', whereArgs: [address, sentAt]);
  }

  Future closeDb() async {
    var client = await AppDatabase().db;
    client.close();
  }
}
