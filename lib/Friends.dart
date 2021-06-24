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
    sql += "remark TEXT, ";
    sql += "PRIMARY KEY(friendId)";
    sql += ")";
    return sql;
  }
  
  static Future<List<Friend>> getLocalFriendsList() async {
    var client = await AppDatabase().db;
    var res = await client.query(Friends.TableName,
        orderBy: "friendId");
    if (res.isNotEmpty) {
      var friends =
          res.map((friendMap) => Friend.fromDb(friendMap)).toList();
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
            remark:"-"
            );
        _friends.add(tmpFriend);
        tmpFriend.insert();
      }
    Friend tmpFriend = new Friend(
        friendId: AppParameters.currentUser,
        firstName: "خودم",
        lastName: "برای ذخیره",
        remark: "",
        );

    _friends.add(tmpFriend);
    tmpFriend.insert();
    //  _friends.add(Friend(
    //     friendId: AppParameters.currentFriend, firstName: "خودم", lastName: "برای ذخیره"));
    return _friends;
  }

 static Future<void> clearAllLocalFriends() async {
    var client = await AppDatabase().db;
    return client.delete(Friends.TableName);
  }

}



class Friend {
  @required
  final String friendId;
  @required
  final String firstName;
  @required
  final String lastName;
  @required
  final String remark;
  
  Friend(
      {this.friendId,
      this.firstName,
      this.lastName,
      this.remark,
      });// {}
  
  String get avatarUrl{
    return AppParameters.userAvatarUrl(this.friendId);
  }

  Map<String, dynamic> toMapForDb() {
    return {
      'friendId': friendId,
      'firstName': firstName,
      'lastName': lastName,
      'remark': remark,      
    };
  }

  Friend.fromDb(Map<String, dynamic> map)
      : friendId = map['friendId'],
        firstName = map['firstName'],
        lastName = map['lastName'],
        remark = map['remark']      
        ;

  Future<Friend> fetchLocal(int friendId) async {
    var client = await AppDatabase().db;
    final Future<List<Map<String, dynamic>>> futureMaps = client.query(
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
    var client = await AppDatabase().db;
    int result = await client.insert(Friends.TableName, toMapForDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print("Insert Result : " + result.toString());
    return result;
  }

  Future<int> update() async {
    var client = await AppDatabase().db;
    return client.update(Friends.TableName, toMapForDb(),
        where: 'friendId = ?',
        whereArgs: [friendId],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> delete() async {
    var client = await AppDatabase().db;
    return client.delete(Friends.TableName,
        where: 'friendId = ?', whereArgs: [friendId]);
  }

}
