import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AppParameters.dart';
import 'FriendsPage.dart';

class ChatHeader extends AppBar {
  
  List<IconButton> _buttons = [];
  BuildContext parentContext;
  AppBar chatBar(List<IconButton> actions, bool isLoading) {
    _buttons = actions;

    return AppBar(   
       backgroundColor: Colors.green[200],
      leading: Row(        
        children: [
          _buttons[0],
        ],
      ),
      actions: <Widget>[
        Visibility(
          child: Container(
              width: 50,
              height: 10,
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
                strokeWidth: 4,
              )),
          visible: isLoading,
        ),
        Visibility(
          child: Container(            
            width: 50,
            height: 10,
            child: _buttons[1],
          ),
          visible: !isLoading,
        ),
      ],
      title: Row(
        children: [
          CircleAvatar(
            radius: 24.0,
            backgroundImage:
                NetworkImage((AppParameters.currentFriendAvatarUrl())),
          ),
          Text("  " + AppParameters.currentFriend),
        ],
      ),      
    );
  }


}
