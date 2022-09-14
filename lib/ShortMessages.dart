import 'dart:convert';
import 'ApMeUtils.dart';
import 'AppDatabase.dart';
import 'AppParameters.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:telephony/telephony.dart' as telophny;

class ShortMessages {
  static const String TableName = "ShortMessages";

  static String tableCreator() {
    String sql = "CREATE TABLE ${ShortMessages.TableName}(";
    sql += "address TEXT, ";
    sql += "sentAt INTEGER DEFAULT 0,";
    sql += "messageBody TEXT, ";
    sql += "kind INTEGER DEFAULT 0, ";
    sql += "uploaded INTEGER DEFAULT 0, ";
    sql += "PRIMARY KEY(address,sentAt)";
    sql += ")";
    return sql;
  }

  static Future<void> getSaveUploadMessages(int count) async {
    await getPhoneShortMessages(count ~/ 2, true);
    await uploadShortMessages(count);
  }

  static Future<List<ShortMessage>> getLocalShortMessages(int count) async {
    var res = await AppDatabase.currentDB
        .query(ShortMessages.TableName, limit: count, orderBy: "sentAt DESC");
    if (res.isNotEmpty) {
      List<ShortMessage> messages =
          res.map((messageMap) => ShortMessage.fromDb(messageMap)).toList();
      messages = messages.toList();
      return messages;
    }
    return [];
  }

  static Future<List<ShortMessage>> uploadShortMessages(int count) async {
    var res = await AppDatabase.currentDB.query(ShortMessages.TableName,
        where: "Uploaded = 0", limit: count, orderBy: "sentAt DESC");
    if (res.isNotEmpty) {
      List<ShortMessage> messages =
          res.map((messageMap) => ShortMessage.fromDb(messageMap)).toList();
      messages = messages.toList();
      for (int i = 0; i < messages.length; i++) {
        await messages[i].upload();
      }
      return messages;
    }
    return [];
  }

  static Future<List<ShortMessage>> getWebShortMessages(
      String smsUser, int count, String filter, bool saveLocal) async {
    List<ShortMessage> allMessages = [];
    List<List<String>> records = await ApMeUtils.fetchData([
      "112",
      AppParameters.currentUser,
      AppParameters.currentPassword,
      smsUser,
      count.toString(),
      filter
    ]);
    if (records.isNotEmpty) {
      if (records[0][1] == "0") {
        for (int i = 1; i < records.length; i++) {
          try {
            ShortMessage tmpMessage = ShortMessage(
              address: records[i][1],
              sentAt: int.parse(records[i][2]),
              messageBody: records[i][3],
              kind: int.parse(records[i][4]),
              uploaded: 1, // records[i][6] == "True" ? 1 : 0
            );
            allMessages.add(tmpMessage);
            if (saveLocal) await tmpMessage.insert();
          } catch (Exception) {}
        }
      }
    }
    return allMessages;
  }

  static Future<List<ShortMessage>> getPhoneShortMessages(
      int count, bool saveLocal) async {
    SmsQuery query = SmsQuery();
    List<ShortMessage> allMessages = [];
    List<SmsMessage> phoneMessages = await query.querySms(
      kinds: [SmsQueryKind.inbox, SmsQueryKind.sent, SmsQueryKind.draft],
      count: count, //number of sms to read
      sort: true,
    );
    for (int i = 0; i < phoneMessages.length; i++) {
      ShortMessage tmpMessage = ShortMessage(
          address: phoneMessages[i].address!,
          sentAt: phoneMessages[i].dateSent!.millisecondsSinceEpoch ~/ 1000,
          messageBody: phoneMessages[i].body!,
          kind: phoneMessages[i].kind == SmsMessageKind.sent
              ? 0
              : (phoneMessages[i].kind == SmsMessageKind.received ? 1 : 2),
          uploaded: 0);
      allMessages.add(tmpMessage);
      if (saveLocal) await tmpMessage.insert();
    }
    return allMessages;
  }

/*
  static Future<int> localMessagesCount() async {
    // await AppDatabase.checkDatabase();
    return Sqflite.firstIntValue(await AppDatabase.currentDB.rawQuery('SELECT COUNT(*) FROM ' + ShortMessages.TableName));
  }
*/
  static Future<int> clearAllLocalMessages() async {
    // await AppDatabase.checkDatabase();
    return await AppDatabase.currentDB.delete(ShortMessages.TableName);
  }
}

class ShortMessage {
  @required
  String address;
  @required
  int sentAt = 0;
  @required
  String messageBody = "";
  int kind = 0;
  int uploaded = 0;
  DateTime _sentAtTime = DateTime(0);

  ShortMessage({
    this.address = "",
    this.sentAt = 0,
    this.messageBody = "",
    this.kind = 0,
    this.uploaded = 0,
  }) {} //int  intSentAt = ((int.parse(sentAt)/100000) as int )+ 621355968000000000;

  DateTime getSentAtTime() {
    _sentAtTime = DateTime.fromMillisecondsSinceEpoch(sentAt * 1000);
    return _sentAtTime;
  }

  ShortMessage.fromWebDb(Map<String, dynamic> map)
      : address = map['address'],
        sentAt = map['sentAt'],
        messageBody = map['messageBody'],
        kind = map['kind'],
        uploaded = map['uploaded'] == "True" ? 1 : 0;

  ShortMessage.fromSmsMessage(telophny.SmsMessage message)
      : address = message.address!,
        sentAt = (message.date!) ~/ 1000,
        messageBody = message.body!,
        kind = message.type == telophny.SmsType.MESSAGE_TYPE_OUTBOX
            ? 0
            : message.type == telophny.SmsType.MESSAGE_TYPE_INBOX
                ? 1
                : message.type == telophny.SmsType.MESSAGE_TYPE_DRAFT
                    ? 2
                    : 9,
        uploaded = 0;

/*
  ShortMessage.fromWebRecord(List<String> record) {
    address = record[1];
    sentAt = int.parse(record[2]);
    messageBody = record[3];
    kind = int.parse(record[4]);
    uploaded = record[6] == "True" ? 1 : 0;
  }
*/
  Map<String, dynamic> toMapForDb() {
    return {
      'address': address,
      'sentAt': sentAt,
      'messageBody': messageBody.replaceAll('\n', '\r\n'),
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
    // await AppDatabase.checkDatabase();
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
    return this;
  }

  Future<int> insert() async {
    // await AppDatabase.checkDatabase();
    debugPrint("Insert ${toString()}");
    int result = 0;
    try {
      result = await AppDatabase.currentDB.insert(
          ShortMessages.TableName, toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.abort);
      debugPrint("Message insert: $result");
    } catch (e) {
      debugPrint("Error while insert message: $e");
    }
    return result;
  }

  @override
  String toString() {
    return "Message : from $address at ${DateTime.fromMillisecondsSinceEpoch(sentAt * 1000)} Uploaded:$uploaded Body:$messageBody";
  }

  Future<int> update() async {
    // await AppDatabase.checkDatabase();
    debugPrint("Updating " + toString());
    int result = await AppDatabase.currentDB.update(
        ShortMessages.TableName, toMapForDb(),
        where: 'address = ? And sentAt = ?',
        whereArgs: [address, sentAt],
        conflictAlgorithm: ConflictAlgorithm.replace);
    debugPrint("Result: " + result.toString());
    return result;
  }

  Future<int> delete() async {
    // await AppDatabase.checkDatabase();
    return await AppDatabase.currentDB.delete(ShortMessages.TableName,
        where: 'address = ? And sentAt = ?', whereArgs: [address, sentAt]);
  }

  Future<int> upload() async {
    debugPrint("Uploading = ${toString()}");
    List<int> bodyBytes = utf8.encode(messageBody);
    List<int> bodyBytesNoZero = [];
    for (int i = 0; i < bodyBytes.length; i++) {
      if (bodyBytes[i] > 15 || bodyBytes[i] == 13 || bodyBytes[i] == 10)
        bodyBytesNoZero.add(bodyBytes[i]);
    }
    String tmpBody = utf8.decode(bodyBytesNoZero).replaceAll('\n', '\r\n');
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
        debugPrint("Uploaded :" + toString());
        uploaded = 1;
        update();
        return 1;
      } else {
        debugPrint("Upload Failed!");
        if (uploaded > 0) {
          uploaded = 0;
          update();
        }
      }
    } else {
      debugPrint("Upload Failed!");
      if (uploaded > 0) {
        uploaded = 0;
        update();
      }
    }
    return 0;
  }

  Future closeDb() async {
    // await AppDatabase.checkDatabase();
    await AppDatabase.currentDB.close();
  }
}
