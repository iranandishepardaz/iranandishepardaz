// import 'package:ap_me/ApMeUtils.dart';
// import 'package:ap_me/AppDatabase.dart';
// import 'package:ap_me/AppParameters.dart';
// import 'package:http/http.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:flutter/cupertino.dart';


// import 'package:meta/meta.dart';

// class Users {
//   static const String TableName = "Users";

//   static Future<List<ApMeUser>> getLocalFriendsList() async {
//     var client = await AppDatabase().db;
//     var res = await client.query(Users.TableName,
//         orderBy: "userId");
//     if (res.isNotEmpty) {
//       var users =
//           res.map((userMap) => ApMeUser.fromDb(userMap)).toList();
//       return users;
//     }
//     return [];
//   }

//  static Future<List<ApMeUser>> getWebUserFriendsList() async {
//     List<List<String>> records = await ApMeUtils.fetchData(
//         ["105", AppParameters.currentUser, AppParameters.currentPassword]);
//     List<ApMeUser> _friends = [];
//     if (records.length > 1)
//       for (int i = 1; i < records.length; i++) {
//         ApMeUser tmpUser = new ApMeUser(
//             userId: records[i][0],
//             firstName: records[i][1],
//             lastName: records[i][2],
//             remark:"-"
//             );
//         _friends.add(tmpUser);
//         tmpUser.insert();
//       }
//     ApMeUser tmpUser = new ApMeUser(
//         userId: AppParameters.currentUser,
//         firstName: "خودم",
//         lastName: "برای ذخیره",
//         remark: "",
//         );

//     _friends.add(tmpUser);
//     tmpUser.insert();
//     //  _friends.add(ApMeUser(
//     //     userId: AppParameters.currentUser, firstName: "خودم", lastName: "برای ذخیره"));
//     return _friends;
//   }

//  static Future<void> clearAllLocalUsers() async {
//     var client = await AppDatabase().db;
//     return client.delete(Users.TableName);
//   }


// /*
//   static Future<List<ApMeUser>> fetchFriendUsers() async {
//     var client = await AppDatabase().db;
//     var res = await client.query(
//       Users.TableName,
//       where: '((firstName = ? And lastName = ?) OR (lastName = ? AND firstName = ?))',
//       whereArgs: [
//         AppParameters.currentUser,
//         AppParameters.currentFriend,
//         AppParameters.currentUser,
//         AppParameters.currentFriend,
//       ],
//       orderBy: 'sentAt ASC',
//     );

//     if (res.isNotEmpty) {
//       var users =
//           res.map((userMap) => ApMeUser.fromDb(userMap)).toList();
//       return users;
//     }
//     return [];
//   }



//    static Future<List<ApMeUser>> fetchFriendLastUser(String friendId) async {
//     var client = await AppDatabase().db;
//     var res = await client.query(
//       Users.TableName,
//       where: '((firstName = ? And lastName = ?) OR (lastName = ? AND firstName = ?))',
//       whereArgs: [
//         AppParameters.currentUser,
//         friendId,
//         AppParameters.currentUser,
//         friendId,
//       ],
//       limit: 1,
//       orderBy: 'sentAt DESC',
//     );

//     if (res.isNotEmpty) {
//       var users =
//           res.map((userMap) => ApMeUser.fromDb(userMap)).toList();
//       return users;
//     }
//     return [];
//   }
//   */

// }



// class ApMeUser {
//   @required
//   final String userId;
//   @required
//   final String firstName;
//   @required
//   final String lastName;
//   @required
//   final String remark;
  
//   ApMeUser(
//       {this.userId,
//       this.firstName,
//       this.lastName,
//       this.remark,
//       });// {}
  
//   String get avatarUrl{
//     return AppParameters.userAvatarUrl(this.userId);
//   }

//   Map<String, dynamic> toMapForDb() {
//     return {
//       'userId': userId,
//       'firstName': firstName,
//       'lastName': lastName,
//       'remark': remark,      
//     };
//   }

//   ApMeUser.fromDb(Map<String, dynamic> map)
//       : userId = map['userId'],
//         firstName = map['firstName'],
//         lastName = map['lastName'],
//         remark = map['remark']      
//         ;

//   static String tableCreator() {
//     String sql = "CREATE TABLE " + Users.TableName + "(";
//     sql += "userId Text, ";
//     sql += "firstName TEXT, ";
//     sql += "lastName TEXT, ";
//     sql += "remark TEXT, ";
//     sql += "PRIMARY KEY(userId)";
//     sql += ")";
//     return sql;
//   }

//   Future<ApMeUser> fetchLocal(int userId) async {
//     var client = await AppDatabase().db;
//     final Future<List<Map<String, dynamic>>> futureMaps = client.query(
//       Users.TableName,
//       where: 'userId = ?',
//       whereArgs: [userId],
//       orderBy: 'UserId',
//     );
//     var maps = await futureMaps;
//     if (maps.length != 0) {
//       return ApMeUser.fromDb(maps.first);
//     }
//     return null;
//   }

//   Future<int> insert() async {
//     var client = await AppDatabase().db;
//     int result = await client.insert(Users.TableName, toMapForDb(),
//         conflictAlgorithm: ConflictAlgorithm.replace);
//     print("Insert Result : " + result.toString());
//     return result;
//   }

//   Future<int> update() async {
//     var client = await AppDatabase().db;
//     return client.update(Users.TableName, toMapForDb(),
//         where: 'userId = ?',
//         whereArgs: [userId],
//         conflictAlgorithm: ConflictAlgorithm.replace);
//   }

//   Future<void> delete() async {
//     var client = await AppDatabase().db;
//     return client.delete(Users.TableName,
//         where: 'userId = ?', whereArgs: [userId]);
//   }

//   Future closeDb() async {
//     var client = await AppDatabase().db;
//     client.close();
//   }
// }
