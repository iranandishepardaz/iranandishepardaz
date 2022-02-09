import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'AppParameters.dart';
import 'AppSettings.dart';

class ChatHeader extends AppBar {
  List<IconButton> _buttons = [];
  BuildContext parentContext;
  AppBar chatBar(
      List<IconButton> actions, bool isLoading, BuildContext context) {
    _buttons = actions;
    parentContext = context;
    return AppBar(
      brightness: AppSettings.nightMode ? Brightness.dark : Brightness.light,
      backgroundColor: AppParameters.titlesBackgroundColor,
      leading: Row(
        children: [
          _buttons[0],
        ],
      ),
      actions: <Widget>[
        Visibility(
          child: Container(
            width: 30,
            height: 10,
            child: _buttons[1],
          ),
          visible: !isLoading,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: isLoading
              ? CircularProgressIndicator(
                  backgroundColor: AppParameters.titlesForegroundColor,
                  strokeWidth: 4,
                )
              : _buttons[2],
        ),
        /* Visibility(
          child: Container(
            width: 40,
            height: 10,
            child: _buttons[2],
          ),
          visible: !isLoading,
        ),*/
      ],
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                  context: parentContext,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                            width: 2.0,
                            color: AppParameters.titlesForegroundColor),
                      ),
                      elevation: 16,
                      backgroundColor: AppParameters.titlesBackgroundColor,
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.network(
                              AppParameters.currentFriendAvatarUrl()),
                        ),
                      ),
                    );
                  });
            },
            child: CircleAvatar(
              radius: 24.0,
              backgroundImage:
                  NetworkImage((AppParameters.currentFriendAvatarUrl())),
            ),
          ),
          Text(
            "  " + AppParameters.currentFriendName + "   ",
            style: TextStyle(color: AppParameters.titlesForegroundColor),
//             + AppParameters.currentFriendId.getL
          ),
        ],
      ),
    );
  }
}
