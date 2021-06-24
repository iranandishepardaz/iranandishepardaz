import 'dart:async';

import 'package:ap_me/FriendsPage.dart';
import 'package:ap_me/TempMessages.dart';

import 'ApMeUtils.dart';
import 'AppParameters.dart';
import 'package:flutter/material.dart';
import 'ApMeMessages.dart';
import 'MessageBubble.dart';

class CattingPage extends StatefulWidget {
  @override
  _CattingPageState createState() => _CattingPageState();
}

class _CattingPageState extends State<CattingPage> {
  String textToSend;
  List<MessageBubble> messageBubbles = [];
  List<ApMeMessage> messages = [];
  List<TempMessage> tempMessages = [];
  final messageBodyTextController = TextEditingController();
  bool isLoading = false;


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.lightGreen,
    );
  }
}