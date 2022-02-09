import 'package:ap_me/ApMeMessages.dart';
import 'package:ap_me/ApMeUtils.dart';
import 'package:ap_me/AppDatabase.dart';
import 'package:ap_me/AppParameters.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/cupertino.dart';

import 'package:meta/meta.dart';

class TempMessages {
  static const String TableName = "TempMessages";

  static String tableCreator() {
    String sql = "CREATE TABLE " + TempMessages.TableName + "(";
    sql += "messageId INTEGER DEFAULT 0, ";
    sql += "fromId TEXT, ";
    sql += "toId TEXT, ";
    sql += "messageBody TEXT, ";
    sql += "sentAt INTEGER DEFAULT 0,";
    sql += "deliveredAt INTEGER DEFAULT 0, ";
    sql += "seenAt INTEGER, ";
    sql += "messageType INTEGER DEFAULT 0, ";
    sql += "url TEXT, ";
    sql += "deleted INTEGER DEFAULT 0, ";
    sql += "uploaded INTEGER DEFAULT 0, ";
    sql += "PRIMARY KEY(messageId,fromId)";
    sql += ")";
    return sql;
  }

  static Future<List<TempMessage>> getAllTempMessages() async {
    //var client = await AppDb.db;
    var res = await AppDatabase.currentDB
        .query(TempMessages.TableName, orderBy: "messageId desc, fromId ASC");
    if (res.isNotEmpty) {
      var messages =
          res.map((messageMap) => TempMessage.fromDb(messageMap)).toList();
      return messages;
    }
    return [];
  }

  static Future<List<TempMessage>> getLocalFriendMessages() async {
    //var client = await AppDb.db;
    var res = await AppDatabase.currentDB.query(
      TempMessages.TableName,
      where: '((fromId = ? And toId = ?) OR (toId = ? AND fromId = ?))',
      whereArgs: [
        AppParameters.currentUser,
        AppParameters.currentFriendId,
        AppParameters.currentUser,
        AppParameters.currentFriendId,
      ],
      orderBy: 'sentAt ASC',
    );

    if (res.isNotEmpty) {
      var messages =
          res.map((messageMap) => TempMessage.fromDb(messageMap)).toList();
      return messages;
    }
    return [];
  }

  static Future<TempMessage> sendTempMessagesToServer(String textToSend) async {
    List<List<String>> records = await ApMeUtils.fetchData([
      "103",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      AppParameters.currentFriendId,
      textToSend
    ]);
    if (records[0][0] == "103" && records[0][1] == "0") {
      //messageToSend.sentAt =( DateTime.now().millisecondsSinceEpoch~/1000);

    } else {
      return null; //this means Send Message was not successful
    }
  }

  static Future<void> clearAllTempMessages() async {
    //var client = await AppDb.db;
    return await AppDatabase.currentDB.delete(TempMessages.TableName);
  }
}

class TempMessage {
  @required
  int messageId;
  @required
  String fromId;
  @required
  String toId;
  @required
  String messageBody;
  @required
  int sentAt;
  int deliveredAt;
  int seenAt;
  int messageType;
  String url;
  int deleted;
  int uploaded;
  DateTime _sentAtTime;

  TempMessage({
    this.messageId,
    this.fromId,
    this.toId,
    this.messageBody,
    this.sentAt,
    this.deliveredAt,
    this.seenAt,
    this.messageType,
    this.url,
    this.deleted,
    this.uploaded,
  }) {} //int  intSentAt = ((int.parse(sentAt)/100000) as int )+ 621355968000000000;
  DateTime getSentAtTime() {
    if (_sentAtTime == null)
      _sentAtTime =
          DateTime.fromMillisecondsSinceEpoch((sentAt * 1000) - 62135596800000);
    return _sentAtTime;
  }

  TempMessage.fromswebRecord(List<String> record) {
    messageId = int.parse(record[0]);
    fromId = record[1];
    toId = record[2];
    messageBody = record[3];
    sentAt = int.parse(record[4]);
    deliveredAt = int.parse(record[5]);
    seenAt = int.parse(record[6]);
    messageType = int.parse(record[7]);
    url = record[8];
    deleted = record[9] == "True" ? 1 : 0;
    uploaded = record[10] == "True" ? 1 : 0;
  }

  Map<String, dynamic> toMapForDb() {
    return {
      'messageId': messageId,
      'fromId': fromId,
      'toId': toId,
      'messageBody': messageBody,
      'sentAt': sentAt,
      'deliveredAt': deliveredAt,
      'seenAt': seenAt,
      'messageType': messageType,
      'url': url,
      'deleted': deleted,
      'uploaded': uploaded,
    };
  }

  TempMessage.fromDb(Map<String, dynamic> map)
      : messageId = map['messageId'],
        fromId = map['fromId'],
        toId = map['toId'],
        messageBody = map['messageBody'],
        sentAt = map['sentAt'],
        deliveredAt = map['deliveredAt'],
        seenAt = map['seenAt'],
        messageType = map['messageType'],
        url = map['url'],
        deleted = map['deleted'],
        uploaded = map['uploaded'];

  TempMessage.fromApMeMessage(ApMeMessage apMeMessage) {
    messageId = apMeMessage.messageId;
    fromId = apMeMessage.fromId;
    toId = apMeMessage.toId;
    messageBody = apMeMessage.messageBody;
    sentAt = apMeMessage.sentAt;
    deliveredAt = apMeMessage.deliveredAt;
    seenAt = apMeMessage.seenAt;
    messageType = apMeMessage.messageType;
    url = apMeMessage.url;
    deleted = apMeMessage.deleted;
    uploaded = apMeMessage.uploaded;
  }

  Future<TempMessage> fetch(int messageId, String fromId) async {
    //var client = await AppDb.db;
    final Future<List<Map<String, dynamic>>> futureMaps =
        AppDatabase.currentDB.query(
      TempMessages.TableName,
      where: 'messageId = ? And fromId = ?',
      whereArgs: [messageId, fromId],
      orderBy: 'sentAt DESC',
    );

    var maps = await futureMaps;
    if (maps.length != 0) {
      return TempMessage.fromDb(maps.first);
    }
    return null;
  }

  Future<int> insert() async {
    messageId = await lastId() + 1;
    //var client = await AppDb.db;
    int result = await AppDatabase.currentDB.insert(
        TempMessages.TableName, toMapForDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print("Temp Message Insert Result: " + result.toString());
    return result;
  }

  Future<int> update() async {
    //var client = await AppDb.db;
    return await AppDatabase.currentDB.update(
        TempMessages.TableName, toMapForDb(),
        where: 'messageId = ? And fromId = ?',
        whereArgs: [messageId, fromId],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> delete() async {
    //var client = await AppDb.db;
    return await AppDatabase.currentDB.delete(TempMessages.TableName,
        where: 'messageId = ? And fromId = ?', whereArgs: [messageId, fromId]);
  }

  Future<int> lastId() async {
    //var client = await AppDb.db;
    final Future<List<Map<String, dynamic>>> futureMaps =
        AppDatabase.currentDB.query(
      TempMessages.TableName,
      limit: 1,
      orderBy: 'messageId DESC',
    );
    var maps = await futureMaps;
    if (maps.length != 0) {
      return TempMessage.fromDb(maps.first).messageId;
    }
    return 0;
  }

  Future<bool> send() async {
    List<List<String>> records = await ApMeUtils.fetchData([
      "103",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      toId,
      messageBody
    ]);
    if (records[0][0] == "103" && records[0][1] == "0") {
      //messageToSend.sentAt =( DateTime.now().millisecondsSinceEpoch~/1000);
      delete();
      return true;
    }
    return false;
  }
}
