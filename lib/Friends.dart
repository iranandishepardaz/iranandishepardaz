import 'package:ap_me/ApMeUtils.dart';
import 'package:ap_me/AppDatabase.dart';
import 'package:ap_me/AppParameters.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/cupertino.dart';

import 'package:meta/meta.dart';

class Friends {
  static const String TableName = "Friends";

  static String tableCreator() {
    String sql = "CREATE TABLE " + Friends.TableName + "(";
    sql += "friendId Text, ";
    sql += "firstName TEXT, ";
    sql += "lastName TEXT, ";
    sql += "lastSeen INTEGER DEFAULT 0, ";
    sql += "PRIMARY KEY(friendId)";
    sql += ")";
    return sql;
  }

  static Future<List<Friend>> getLocalFriendsList() async {
    //var client = await AppDb.db;
    var res = await AppDatabase.currentDB
        .query(Friends.TableName, orderBy: "friendId");
    if (res.isNotEmpty) {
      var friends = res.map((friendMap) => Friend.fromDb(friendMap)).toList();
      return friends;
    }
    return [];
  }

  static Future<List<Friend>> getWebFriendFriendsList() async {
    List<List<String>> records = await ApMeUtils.fetchData(
        ["105", AppParameters.currentUser, AppParameters.currentPassword]);
    List<Friend> _friends = [];
    clearAllLocalFriends();
    if (records.length > 1)
      for (int i = 1; i < records.length; i++) {
        Friend tmpFriend = new Friend(
            friendId: records[i][0],
            firstName: records[i][1],
            lastName: records[i][2],
            lastSeen: int.parse(records[i][3]));
        _friends.add(tmpFriend);
        tmpFriend.insert();
      }
    Friend tmpFriend = new Friend(
      friendId: AppParameters.currentUser,
      firstName: "خودم",
      lastName: "برای ذخیره",
      lastSeen: 0,
    );

    _friends.add(tmpFriend);
    tmpFriend.insert();
    //  _friends.add(Friend(
    //     friendId: AppParameters.currentFriend, firstName: "خودم", lastName: "برای ذخیره"));
    return _friends;
  }

  static Future<void> clearAllLocalFriends() async {
    //var client = await AppDb.db;
    return await AppDatabase.currentDB.delete(Friends.TableName);
  }
}

class Friend {
  @required
  String friendId;
  @required
  final String firstName;
  @required
  final String lastName;
  @required
  final int lastSeen;

  Friend({
    this.friendId,
    this.firstName,
    this.lastName,
    this.lastSeen,
  }); // {}

  DateTime _lastSeenTime;
  DateTime getLastSeenTime() {
    if (_lastSeenTime == null)
      _lastSeenTime = DateTime.fromMillisecondsSinceEpoch(this.lastSeen * 1000);
    return _lastSeenTime;
  }

  String get avatarUrl {
    return AppParameters.userAvatarUrl(this.friendId);
  }

  Map<String, dynamic> toMapForDb() {
    return {
      'friendId': friendId,
      'firstName': firstName,
      'lastName': lastName,
      'lastSeen': lastSeen,
    };
  }

  Friend.fromDb(Map<String, dynamic> map)
      : friendId = map['friendId'],
        firstName = map['firstName'],
        lastName = map['lastName'],
        lastSeen = map['lastSeen'];

  Future<Friend> fetchLocal(String friendId) async {
    //var client = await AppDb.db;
    final Future<List<Map<String, dynamic>>> futureMaps =
        AppDatabase.currentDB.query(
      Friends.TableName,
      where: 'friendId = ?',
      whereArgs: [friendId],
      orderBy: 'FriendId',
    );
    var maps = await futureMaps;
    if (maps.length != 0) {
      return Friend.fromDb(maps.first);
    }
    return null;
  }

  Future<int> insert() async {
    //var client = await AppDb.db;
    int result = await AppDatabase.currentDB.insert(
        Friends.TableName, toMapForDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print("Friend Insert Result : " + result.toString());
    return result;
  }

  Future<int> update() async {
    //var client = await AppDb.db;
    return await AppDatabase.currentDB.update(Friends.TableName, toMapForDb(),
        where: 'friendId = ?',
        whereArgs: [friendId],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> delete() async {
    //var client = await AppDb.db;
    return await AppDatabase.currentDB.delete(Friends.TableName,
        where: 'friendId = ?', whereArgs: [friendId]);
  }
}
