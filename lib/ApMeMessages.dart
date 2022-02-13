import 'package:ap_me/ApMeUtils.dart';
import 'package:ap_me/AppDatabase.dart';
import 'package:ap_me/AppParameters.dart';
import 'package:ap_me/TempMessages.dart';

import 'package:sqflite/sqflite.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

class ApMeMessages {
  static const String TableName = "Messages";

  static String tableCreator() {
    String sql = "CREATE TABLE " + ApMeMessages.TableName + "(";
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
    sql += "downloaded INTEGER DEFAULT 0, ";
    sql += "PRIMARY KEY(messageId,fromId)";
    sql += ")";
    return sql;
  }

  static Future<List<ApMeMessage>> getLocalMessages(int count) async {
    //var client = await AppDb.db;
    var res = await AppDatabase.currentDB.query(ApMeMessages.TableName,
        limit: count, orderBy: "messageId DESC, fromId ASC");
    if (res.isNotEmpty) {
      var messages =
          res.map((messageMap) => ApMeMessage.fromDb(messageMap)).toList();
      return messages;
    }
    return [];
  }

  static Future<int> localMessagesCount() async {
    //var client = await AppDb.db;
    return Sqflite.firstIntValue(await AppDatabase.currentDB
        .rawQuery('SELECT COUNT(*) FROM ' + ApMeMessages.TableName));
  }

  static Future<List<ApMeMessage>> getLocalUnuploadedMessages(int count) async {
    //var client = await AppDb.db;
    var res = await AppDatabase.currentDB.query(ApMeMessages.TableName,
        where: '(Uploaded = 0 )',
        limit: count,
        orderBy: "messageId ASC, fromId ASC");
    if (res.isNotEmpty) {
      var messages =
          res.map((messageMap) => ApMeMessage.fromDb(messageMap)).toList();
      return messages;
    }
    return [];
  }

  static Future<List<ApMeMessage>> getWebAllMessages(bool saveLocal) async {
    List<ApMeMessage> allMessages = [];

    List<List<String>> records = await ApMeUtils.fetchData([
      "104",
      AppParameters.currentUser,
      AppParameters.currentPassword,
    ]);
    if (records.length > 1)
      for (int i = 1; i < records.length; i++) {
        ApMeMessage tmpMessage = ApMeMessage.fromWebRecord(records[i]);
        if (tmpMessage.toId == AppParameters.currentUser) {
          if (tmpMessage.deliveredAt == 0) {
            tmpMessage.deliveredAt =
                (DateTime.now().toUtc().millisecondsSinceEpoch) ~/ 1000;
            tmpMessage.uploaded = 0;
          }
        }
        allMessages.add(tmpMessage);
        if (saveLocal) {
          tmpMessage.insert();
        }
      }
    return allMessages;
  }

  static Future<List<ApMeMessage>> getWebNewMessages(bool saveLocal) async {
    List<ApMeMessage> allMessages = [];
    int recordsCount = await localMessagesCount();
    List<List<String>> records = await ApMeUtils.fetchData([
      recordsCount == 0
          ? "104"
          : "102", //When application is reinstalled or is new
      AppParameters.currentUser,
      AppParameters.currentPassword,
    ]);
    if (records.length > 1) {
      AppParameters.newMessagesCount += records.length - 1;
      for (int i = 1; i < records.length; i++) {
        ApMeMessage tmpMessage = ApMeMessage.fromWebRecord(records[i]);
        tmpMessage.setDelivery(false); //will insert at next lines
        allMessages.add(tmpMessage);
        if (saveLocal) {
          tmpMessage.insert();
          //if (await tmpMessage.insert() == 0) tmpMessage.update();
        }
      }
    }
    syncMessages();
    return allMessages;
  }

  static Future<List<ApMeMessage>> getPartnerMessagesBeforeFromWeb(
      int count, bool justUnread, int timeUpperLimit) async {
    List<ApMeMessage> allMessages = [];
    List<List<String>> records = await ApMeUtils.fetchData([
      "202",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      count.toString(),
      AppParameters.currentFriendId,
      justUnread ? "1" : "0",
      timeUpperLimit.toString()
    ]);
    if (records.length > 1) {
      for (int i = 1; i < records.length; i++) {
        ApMeMessage tmpMessage = ApMeMessage.fromWebRecord(records[i]);
        tmpMessage.uploaded = 1;
        try {
          allMessages.add(tmpMessage);
          if (await tmpMessage.update() == 0) {
            await tmpMessage.insert();
          }
        } catch (Exception) {}
        //
        //  await tmpMessage.insert();
        //
      }
    }
    return allMessages;
  }

  static Future<List<ApMeMessage>> getUnsyncedMessagesFromWeb() async {
    List<ApMeMessage> allMessages = [];
    List<List<String>> records = await ApMeUtils.fetchData([
      "201",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      "30",
    ]);
    if (records.length > 1) {
      for (int i = 1; i < records.length; i++) {
        ApMeMessage tmpMessage = ApMeMessage.fromWebRecord(records[i]);
        tmpMessage.uploaded = 1;
        try {
          allMessages.add(tmpMessage);
          if (await tmpMessage.update() == 0) {
            await tmpMessage.insert();
          }
        } catch (Exception) {}
        //
        //  await tmpMessage.insert();
        //
      }
    }
    return allMessages;
  }

  static Future<List<ApMeMessage>> getWebUnsyncedMessages() async {
    List<ApMeMessage> allMessages = [];
    List<List<String>> records = await ApMeUtils.fetchData([
      "110",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      "10",
    ]);
    if (records.length > 1) {
      for (int i = 1; i < records.length; i++) {
        ApMeMessage tmpMessage = ApMeMessage.fromWebRecord(records[i]);
        tmpMessage.uploaded = 1;
        await tmpMessage.update();
      }
    }
    return allMessages;
  }

  static Future<List<ApMeMessage>> syncMessages() async {
    List<ApMeMessage> allMessages = await getLocalUnuploadedMessages(10);
    if (allMessages.length == 0) return null;
    String parameter4 = "";
    for (int i = 0; i < allMessages.length; i++) {
      parameter4 += allMessages[i].messageId.toString() + ";^;";
      parameter4 += allMessages[i].fromId + ";^;";
      parameter4 += allMessages[i].toId + ";^;";
      parameter4 += allMessages[i].messageBody + ";^;";
      parameter4 += allMessages[i].sentAt.toString() + ";^;";
      parameter4 += allMessages[i].deliveredAt.toString() + ";^;";
      parameter4 += allMessages[i].seenAt.toString() + ";^;";
      parameter4 += allMessages[i].messageType.toString() + ";^;";
      parameter4 += allMessages[i].url.toString() + ";^;";
      parameter4 += allMessages[i].deleted.toString() + ";^;";
      parameter4 += allMessages[i].uploaded.toString() + ";^;";
      parameter4 += allMessages[i].downloaded.toString() + ";^;";
      parameter4 += "\n;^;";
    }
    List<List<String>> records = await ApMeUtils.fetchData([
      "107",
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

  static Future<ApMeMessage> sendPendingMessage(TempMessage tempMessage) async {
    List<List<String>> records = await ApMeUtils.fetchData([
      "103",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      tempMessage.toId,
      tempMessage.messageBody
    ]);

    //Save as temporary Message and send them in group

    if (records[0][0] == "103" && records[0][1] == "0") {
      ApMeMessage sentMessage = ApMeMessage.fromWebRecord(records[1]);
      //messageToSend.sentAt =( DateTime.now().millisecondsSinceEpoch~/1000);
      sentMessage.insert();
      tempMessage.delete();
      return sentMessage;
    } else {
      return null; //this means Send Message was not successful
    }
  }

  static Future<ApMeMessage> sendTextMessage(String textToSend) async {
    TempMessage tempMessage = new TempMessage(
      messageId: 0,
      fromId: AppParameters.currentUser,
      toId: AppParameters.currentFriendId,
      messageBody: textToSend,
      sentAt: 0,
      deliveredAt: 0,
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
      AppParameters.currentFriendId,
      textToSend
    ]);
    if (records.length == 0) {
      tempMessage.insert();
      return null; //this means Send Message was not successful
    }
    if (records[0][0] == "103" && records[0][1] == "0") {
      ApMeMessage sentMessage = ApMeMessage.fromWebRecord(records[1]);
      //messageToSend.sentAt =( DateTime.now().millisecondsSinceEpoch~/1000);
      sentMessage.uploaded = 1;
      sentMessage.insert();
      return sentMessage;
    } else {
      //Save as temporary Message and send them in group
      tempMessage.insert();
      return null; //this means Send Message was not successful
    }
  }

  static Future<ApMeMessage> sendFileMessage(
      String textToSend, String fileType, String base64File) async {
    TempMessage tempMessage = new TempMessage(
      messageId: 0,
      fromId: AppParameters.currentUser,
      toId: AppParameters.currentFriendId,
      messageBody: textToSend,
      sentAt: 0,
      deliveredAt: 0,
      seenAt: 0,
      messageType: 0,
      url: "",
      deleted: 0,
      uploaded: 0,
    );

    List<List<String>> records = await ApMeUtils.fetchDataFileMessage([
      "501",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      AppParameters.currentFriendId,
      textToSend,
      fileType
    ], base64File);
    if (records.length == 0) {
      tempMessage.insert();
      return null; //this means Send Message was not successful
    }
    if (records[0][0] == "501" && records[0][1] == "0") {
      ApMeMessage sentMessage = ApMeMessage.fromWebRecord(records[1]);
      //messageToSend.sentAt =( DateTime.now().millisecondsSinceEpoch~/1000);
      sentMessage.uploaded = 1;
      sentMessage.insert();
      return sentMessage;
    } else {
      //Save as temporary Message and send them in group
      tempMessage.insert();
      return null; //this means Send Message was not successful
    }
  }

  static Future<ApMeMessage> editMessage(ApMeMessage messageToEdit) async {
    List<List<String>> records = await ApMeUtils.fetchData([
      "108",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      messageToEdit.messageId.toString(),
      messageToEdit.messageBody
    ]);
    if (records.length == 0) {
      return null; //this means edit Message was not successful
    }
    if (records[0][0] == "108" && records[0][1] == "0") {
      return messageToEdit;
    } else {
      return null; //this means edit Message was not successful
    }
  }

  static Future<ApMeMessage> editDeliveredMessage(
      ApMeMessage messageToEdit) async {
    List<List<String>> records = await ApMeUtils.fetchData([
      "208",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      messageToEdit.messageId.toString(),
      messageToEdit.messageBody
    ]);
    if (records.length == 0) {
      return null; //this means edit Message was not successful
    }
    if (records[0][0] == "208" && records[0][1] == "0") {
      return messageToEdit;
    } else {
      return null; //this means edit Message was not successful
    }
  }

  static Future<ApMeMessage> deleteMessage(ApMeMessage messageToDelete) async {
    List<List<String>> records = await ApMeUtils.fetchData([
      "109",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      messageToDelete.messageId.toString(),
      messageToDelete.messageBody
    ]);
    if (records.length == 0) {
      return null; //this means edit Message was not successful
    }
    if (records[0][0] == "109" &&
        records[0][1] == "0" &&
        records[0][2] == "0") {
      return messageToDelete;
    } else if (records[0][0] == "109" &&
        records[0][1] == "0" &&
        records[0][2] == "1") {
      messageToDelete.deleted = 1;
      return messageToDelete;
    } else {
      return null; //this means edit Message was not successful
    }
  }

  static Future<ApMeMessage> deleteDeliveredMessage(
      ApMeMessage messageToDelete) async {
    List<List<String>> records = await ApMeUtils.fetchData([
      "209",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      messageToDelete.messageId.toString(),
      messageToDelete.messageBody
    ]);
    if (records.length == 0) {
      return null; //this means edit Message was not successful
    }
    if (records[0][0] == "209" && records[0][1] == "0") {
      return messageToDelete;
    } else {
      return null; //this means edit Message was not successful
    }
  }

  static Future<void> clearAllLocalMessages() async {
    //var client = await AppDb.db;
    return await AppDatabase.currentDB.delete(ApMeMessages.TableName);
  }

  static Future<List<ApMeMessage>> getLocalFriendMessages(int count) async {
    //var client = await AppDb.db;
    var result = await AppDatabase.currentDB.query(
      ApMeMessages.TableName,
      where: '((fromId = ? And toId = ?) OR (toId = ? AND fromId = ?))',
      limit: count,
      whereArgs: [
        AppParameters.currentUser,
        AppParameters.currentFriendId,
        AppParameters.currentUser,
        AppParameters.currentFriendId,
      ],
      orderBy: 'sentAt DESC',
    );

    if (result.isNotEmpty) {
      var messages =
          result.map((messageMap) => ApMeMessage.fromDb(messageMap)).toList();
      return messages;
    }
    return [];
  }

  static Future<List<ApMeMessage>> getLocalFriendLastMessage(
      String friendId) async {
    //var client = await AppDb.db;
    var res = await AppDatabase.currentDB.query(
      ApMeMessages.TableName,
      where: '((fromId = ? And toId = ?) OR (toId = ? AND fromId = ?))',
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
          res.map((messageMap) => ApMeMessage.fromDb(messageMap)).toList();
      return messages;
    }
    return [];
  }
}

class ApMeMessage {
  @required
  int messageId;
  @required
  String fromId;
  @required
  String toId;
  @required
  String messageBody;
  @required
  int sentAt = 0;
  int deliveredAt = 0;
  int seenAt = 0;
  int messageType = 0;
  String url = "";
  int deleted = 0;
  int uploaded = 0;
  int downloaded = 0;
  DateTime _sentAtTime;
  bool isEditting = false;

  ApMeMessage({
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
    this.downloaded,
  }); //int  intSentAt = ((int.parse(sentAt)/100000) as int )+ 621355968000000000;
  DateTime getSentAtTime() {
    if (_sentAtTime == null)
      _sentAtTime = DateTime.fromMillisecondsSinceEpoch(sentAt * 1000);
    return _sentAtTime;
  }

  get fullUrl => messageType == 1
      ? AppParameters.mainSiteURL + "/images/" + fromId + "/" + url
      : "";

  ApMeMessage.fromWebRecord(List<String> record) {
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
    downloaded = record[11] == "True" ? 1 : 0;
  }
  ApMeMessage.fromTempMessage(TempMessage tempMessage) {
    messageId = tempMessage.messageId;
    fromId = tempMessage.fromId;
    toId = tempMessage.toId;
    messageBody = tempMessage.messageBody;
    sentAt = tempMessage.sentAt;
    deliveredAt = tempMessage.deliveredAt;
    seenAt = tempMessage.seenAt;
    messageType = tempMessage.messageType;
    url = tempMessage.url;
    deleted = tempMessage.deleted;
    uploaded = tempMessage.uploaded;
    downloaded = 0;
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
      'downloaded': downloaded,
    };
  }

  ApMeMessage.fromDb(Map<String, dynamic> map)
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
        uploaded = map['uploaded'],
        downloaded = map['downloaded'];

  Future setDelivery(bool saveIt) async {
    if (toId == AppParameters.currentUser && deliveredAt == 0) {
      deliveredAt = (DateTime.now().toUtc().millisecondsSinceEpoch) ~/ 1000;
      if (fromId != AppParameters.currentUser) uploaded = 0;
      if (saveIt) update();
    }
  }

  Future setSeen(bool saveIt) async {
    if (toId == AppParameters.currentUser) {
      seenAt = (DateTime.now().toUtc().millisecondsSinceEpoch) ~/ 1000;
      uploaded = 0;
      if (saveIt) update();
    }
  }

  Future<ApMeMessage> fetch(int messageId, String fromId) async {
    //var client = await AppDb.db;
    final Future<List<Map<String, dynamic>>> futureMaps =
        AppDatabase.currentDB.query(
      ApMeMessages.TableName,
      where: 'messageId = ? And fromId = ?',
      whereArgs: [messageId, fromId],
      orderBy: 'sentAt DESC',
    );

    var maps = await futureMaps;
    if (maps.length != 0) {
      return ApMeMessage.fromDb(maps.first);
    }
    return null;
  }

  Future<int> insert() async {
    int result = 0;
    try {
      //var client = await AppDb.db;
      result = await AppDatabase.currentDB.insert(
          ApMeMessages.TableName, toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.fail);
    } catch (e) {}
    print("Message Insert Result: " + result.toString());
    return result;
  }

  Future<int> update() async {
    int result = 0;
    //var client = await AppDb.db;
    print("Updating Message : from " +
        fromId +
        " to " +
        toId +
        " Up " +
        uploaded.toString());
    result = await AppDatabase.currentDB.update(
        ApMeMessages.TableName, toMapForDb(),
        where: 'messageId = ? And fromId = ?',
        whereArgs: [messageId, fromId],
        conflictAlgorithm: ConflictAlgorithm.replace);
    print("Update Result : " + result.toString());
    return result;
  }

  Future<int> delete() async {
    //var client = await AppDb.db;
    return await AppDatabase.currentDB.delete(ApMeMessages.TableName,
        where: 'messageId = ? And fromId = ?', whereArgs: [messageId, fromId]);
  }

  Future closeDb() async {
    //var client = await AppDb.db;
    await AppDatabase.currentDB.close();
  }
}
