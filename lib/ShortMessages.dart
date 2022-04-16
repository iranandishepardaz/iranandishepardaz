import 'dart:convert';

import 'package:ap_me/ApMeUtils.dart';
import 'package:ap_me/AppDatabase.dart';
import 'package:ap_me/AppParameters.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

import 'package:sqflite/sqflite.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

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

  static Future<List<SmsMessage>> getShortMessages(int count) async {
    SmsQuery query = new SmsQuery();
    List<SmsMessage> allMessages = await query.querySms(
      //querySms is from sms package
      kinds: [SmsQueryKind.Inbox, SmsQueryKind.Sent, SmsQueryKind.Draft],
      //filter Inbox, sent or draft messages
      count: count, //number of sms to read
      // address: "09373792580",
    );
    return allMessages;
  }

  static Future<List<ShortMessage>> getLocalMessages(int count) async {
    //var client = await AppDb.db;
    var res = await AppDatabase.currentDB.query(ShortMessages.TableName,
        limit: count, orderBy: "sentAt DESC, address ASC");
    if (res.isNotEmpty) {
      List<ShortMessage> messages =
          res.map((messageMap) => ShortMessage.fromDb(messageMap)).toList();
      messages = messages.reversed.toList();
      return messages;
    }
    return [];
  }

  static Future getSaveUploadMessages(int count) async {
    List<SmsMessage> allMessages = await getShortMessages(count);
    List<int> newMessagesIds = [];
    for (int i = 0; i < allMessages.length; i++) {
      ShortMessage tmpMessage = new ShortMessage(
          address: allMessages[i].address,
          sentAt: allMessages[i].date.millisecondsSinceEpoch ~/ 1000,
          messageBody: allMessages[i].body,
          kind: allMessages[i].kind == SmsMessageKind.Sent
              ? 0
              : (allMessages[i].kind == SmsMessageKind.Received ? 1 : 2),
          uploaded: 0);
      int isNew = await tmpMessage.insert();
      if (isNew > 0) newMessagesIds.add(isNew);
    }
    //for (int i = 0; i < newMessagesIds.length; i++) {}
    await uploadMessages(allMessages.length);
  }

/*
  static Future getSaveUploadMessages(int count) async {
    SmsQuery query = new SmsQuery();
    List<SmsMessage> allMessages = await query.querySms(
      kinds: [SmsQueryKind.Inbox, SmsQueryKind.Sent, SmsQueryKind.Draft],
      count: count, //number of sms to read
    );
    for (int i = 0; i < allMessages.length; i++) {
      ShortMessage tmpMessage = new ShortMessage(
          address: allMessages[i].address,
          sentAt: allMessages[i].date.millisecondsSinceEpoch ~/ 1000,
          messageBody: allMessages[i].body,
          kind: allMessages[i].kind == SmsMessageKind.Sent
              ? 0
              : (allMessages[i].kind == SmsMessageKind.Received ? 1 : 2),
          uploaded: 0);
      await tmpMessage.insert();
    }
    await uploadMessages(maxCount);
  }
*/

  static Future<int> localMessagesCount() async {
    //var client = await AppDb.db;
    return Sqflite.firstIntValue(await AppDatabase.currentDB
        .rawQuery('SELECT COUNT(*) FROM ' + ShortMessages.TableName));
  }

  static Future<void> clearAllLocalMessages() async {
    //var client = await AppDb.db;
    return await AppDatabase.currentDB.delete(ShortMessages.TableName);
  }

  static Future<List<ShortMessage>> download(int count) async {
    List<ShortMessage> allMessages = [];
    List<List<String>> records = await ApMeUtils.fetchData([
      "112",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      'rose',
      count.toString(),
    ]);
    if (records.length > 0) {
      if (records[0][1] == "0") {
        for (int i = 1; i < records.length; i++) {
          try {
            ShortMessage tmpMessage = ShortMessage.fromWebRecord(records[i]);
            allMessages.add(tmpMessage);
            await tmpMessage.insert();
          } catch (Exception) {}
        }
      }
    }
    return allMessages;
  }

  static Future<List<SmsMessage>> getWebShortMessages(
      String smsUser, int count, String filter, bool saveLocal) async {
    List<SmsMessage> allMessages = [];
    List<List<String>> records = await ApMeUtils.fetchData([
      "112",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      smsUser,
      count.toString(),
      filter
    ]);
    if (records.length > 0) {
      if (records[0][1] == "0") {
        for (int i = 1; i < records.length; i++) {
          try {
            ShortMessage tmpMessage = ShortMessage.fromWebRecord(records[i]);
            SmsMessage tmpSMS = SmsMessage.fromJson({
              "body": tmpMessage.messageBody,
              "address": tmpMessage.address
            });
            tmpSMS.kind = tmpMessage.kind == 1
                ? SmsMessageKind.Received
                : (tmpMessage.kind == 0
                    ? SmsMessageKind.Sent
                    : SmsMessageKind.Draft);
            tmpSMS.date =
                DateTime.fromMillisecondsSinceEpoch(tmpMessage.sentAt * 1000);

            allMessages.add(tmpSMS);
            if (saveLocal) await tmpMessage.insert();
          } catch (Exception) {}
        }
      }
    }
    return allMessages;
  }

  static Future<List<ShortMessage>> getLocalUnuploadedMessages(
      int count) async {
    //var client = await AppDb.db;
    var result = await AppDatabase.currentDB.query(ShortMessages.TableName,
        where: 'uploaded=0', limit: count, orderBy: "sentAt DESC");
    if (result.isNotEmpty) {
      var tmpMessages =
          result.map((messageMap) => ShortMessage.fromDb(messageMap)).toList();
      return tmpMessages;
    }
    return [];
  }

  static Future<List<ShortMessage>> uploadMessages(int favCount) async {
    List<ShortMessage> allMessages = await getLocalUnuploadedMessages(favCount);
    if (allMessages.length == 0) return null;
    for (int i = 0; i < allMessages.length; i++) {
      await allMessages[i].upload();
    }
    return allMessages;
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
    //var client = await AppDb.db;
    var res = await AppDatabase.currentDB.query(
      ShortMessages.TableName,
      where: '((sentAt = ? And address = ?) OR (address = ? AND sentAt = ?))',
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
          res.map((messageMap) => ShortMessage.fromDb(messageMap)).toList();
      return messages;
    }
    return [];
  }

  static Future<List<ShortMessage>> getLocalFriendLastMessage(
      String friendId) async {
    //var client = await AppDb.db;
    var res = await AppDatabase.currentDB.query(
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
    address = record[1];
    sentAt = int.parse(record[2]);
    messageBody = record[3];
    kind = int.parse(record[4]);
    uploaded = record[6] == "True" ? 1 : 0;
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
    //var client = await AppDb.db;
    final Future<List<Map<String, dynamic>>> futureMaps =
        AppDatabase.currentDB.query(
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
    print("Insert " + toString());
    int result = 0;
    try {
      //var client = await AppDb.db;
      result = await AppDatabase.currentDB.insert(
          ShortMessages.TableName, toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.rollback);
    } catch (e) {}
    print("Result : " + result.toString());
    return result;
  }

  String toString() {
    return "Message : from " +
        address +
        " at " +
        DateTime.fromMicrosecondsSinceEpoch(sentAt * 1000).toString() +
        " Uploaded " +
        uploaded.toString() +
        " Body: " +
        messageBody;
  }

  Future<int> update() async {
    //var client = await AppDb.db;
    print("Updating " + toString());
    int result = await AppDatabase.currentDB.update(
        ShortMessages.TableName, toMapForDb(),
        where: 'address = ? And sentAt = ?',
        whereArgs: [address, sentAt],
        conflictAlgorithm: ConflictAlgorithm.replace);
    print("Resultt: " + result.toString());
    return result;
  }

  Future<void> delete() async {
    //var client = await AppDb.db;
    return await AppDatabase.currentDB.delete(ShortMessages.TableName,
        where: 'address = ? And sentAt = ?', whereArgs: [address, sentAt]);
  }

  Future<bool> upload() async {
    print("Uploading Length = " + messageBody.length.toString());
    print(toString());
    List<int> bodyBytes = utf8.encode(messageBody);
    List<int> bodyBytesNoZero = [];
    for (int i = 0; i < bodyBytes.length; i++) {
      if (bodyBytes[i] > 15) bodyBytesNoZero.add(bodyBytes[i]);
    }
    String tmpBody = utf8.decode(bodyBytesNoZero);
    /* List<String> bodies = [];
    String messageBodyOriginal = messageBody;
    while (messageBodyOriginal.length > 0) {
      String tmpBody = "";
      if (messageBodyOriginal.length > 100) {
        tmpBody = messageBodyOriginal.substring(0, 100);
        messageBodyOriginal = messageBodyOriginal.substring(100);
      } else {
        tmpBody = messageBodyOriginal;
        messageBodyOriginal = "";
      }
      bodies.add(tmpBody);
    }
    for (int i = 0; i < bodies.length; i++) {*/
    List<List<String>> records = await ApMeUtils.fetchData([
      "111",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      address.toString(),
      //(sentAt + i).toString(),
      //bodies[i],
      sentAt.toString(),
      tmpBody.replaceAll("<", "-").replaceAll(">", "-").trimLeft().trimRight(),
      // .replaceAll("/", "-"),
      kind.toString()
    ]);
    if (records.length > 0) {
      if (records[0][1] == "0" || records[0][1] == "3") {
        print("Uploaded :" + toString());
        uploaded = 1;
        update();
        return true;
      } else {
        print("Upload Failed!");
        if (uploaded > 0) {
          uploaded = 0;
          update();
        }
      }
    } else {
      print("Upload Failed!");
      if (uploaded > 0) {
        uploaded = 0;
        update();
      }
    }
    return false;
  }

  Future closeDb() async {
    //var client = await AppDb.db;
    await AppDatabase.currentDB.close();
  }
}
