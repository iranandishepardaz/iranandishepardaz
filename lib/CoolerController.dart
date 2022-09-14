import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

//import 'SettingPage.dart';
import 'package:async/async.dart';

import 'AppParameters.dart';
//import 'ApcoUtils.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

//import 'WebBrowser.dart';

class CoolerController extends StatefulWidget {
  @override
  _CoolerControllerState createState() => _CoolerControllerState();
}

class _CoolerControllerState extends State<CoolerController> {
  //BluetoothDevice server = BluetoothDevice();
  //List<String> messages = List<String>();
  String _lastMessage = "\nStart\n";
  String _messageToShow = "";
  int ON_Reg = 0;
  int OFF_Reg = 0;
  int ON_Timer = 0;
  int OFF_Timer = 0;
  int initSeconds = 0;
  int stepValue = 0;
  bool fanIsON = false;
  bool waterIsON = false;
  bool speedIsHigh = false;

  int _errorsCount = 0;
  int _seconds = 0;
  double progressValue = 0;
  String remindedTime = "0:00";
  Color mainBackgroundColor = Colors.brown;
  bool isConnecting = true;

  TextEditingController cntlCommand = TextEditingController();
  TextEditingController cntlParam = TextEditingController();
  TextEditingController cntlOnReg = TextEditingController();
  TextEditingController cntlOffReg = TextEditingController();

  Icon statusIcon = Icon(
    Icons.bluetooth,
    size: 50,
  );
  bool BlueIsConnected = false;
  bool get isConnected => BlueIsConnected;

  Future<bool> b_IsConnected() async {
    if (connection == null) {
      connection =
          await BluetoothConnection.toAddress(AppParameters.macAddress);
    }
    BlueIsConnected = connection.isConnected;
    return connection.isConnected;
  }

  bool isDisconnecting = false;

  late BluetoothConnection connection;

  String _title = "کنترل کولر اندیشه";

  @override
  void initState() {
    initConn();
//    server = BluetoothDevice();
//    server = AppParameters.macAddress;
    _lastMessage =
        "\n${ApcoUtils.formatDateTime(DateTime.now(), 4)} App Started.";
    _messageToShow = _lastMessage;
    _connect();
    _timerOneSecond = Timer(Duration(seconds: 1), oneSecondTimeout);
    //infoRefreshTimer();
    //oneSecondTimer();
    super.initState();
  }

  void initConn() async {
    connection = await BluetoothConnection.toAddress(AppParameters.macAddress);
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    _disconnect();
    super.dispose();
  }

  @override
  void deactivate() {
    // Avoid memory leak (`setState` after deactivate) and disconnect
    _disconnect();
    super.deactivate();
  }

  late Timer _timerOneSecond;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor: Colors.brown[100],
          appBar: AppBar(
            backgroundColor: Colors.brown[400],
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.bluetooth,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                    color: Colors.yellow,
                    iconSize: AppParameters.iconsSize * 1.2,
                    onPressed: _toggleConnection,
                  ),
                  Text(_title),
                  IconButton(
                    icon: Icon(
                      Icons.list,
                      color: _logVisible ? Colors.black : Colors.blueGrey,
                    ),
                    iconSize: AppParameters.iconsSize * 1.2,
                    onPressed: _showHideLog,
                  ),
                ]),
          ),
          body: ListView(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: Icon(Icons.power),
                      color: Colors.green,
                      iconSize: AppParameters.iconsSize * 1.2,
                      onPressed: _turnON),
                  IconButton(
                      icon: Icon(Icons.power_off),
                      color: Colors.red,
                      iconSize: AppParameters.iconsSize * 1.2,
                      onPressed: _turnOFF),
                ],
              ),
              Stack(
                children: <Widget>[
                  SizedBox(
                    height: AppParameters.iconsSize * 1.2,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.brown[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                          //ON_Timer > 0 ? Colors.red : Colors.green
                          ON_Timer > 0 ? Colors.green : Colors.red),
                      value: progressValue,
                    ),
                  ),
                  Align(
                    child: Text(
                      (OFF_Timer == 0 && ON_Timer == 0) ? "..." : remindedTime,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: AppParameters.iconsSize * 1.2 * 3 / 4),
                    ),
                    alignment: Alignment.center,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: Icon(Icons.wb_sunny_sharp),
                      color: Colors.orange[100],
                      iconSize: AppParameters.iconsSize * 1.2,
                      onPressed: _morningTimer),
                  IconButton(
                      icon: Icon(Icons.wb_sunny_sharp),
                      color: Colors.orange,
                      iconSize: AppParameters.iconsSize * 1.2,
                      onPressed: _dayHotTimer),
                  IconButton(
                      icon: Icon(Icons.night_shelter_outlined),
                      color: Colors.lightBlue[700],
                      iconSize: AppParameters.iconsSize * 1.2,
                      onPressed: _nightTimer),
                  IconButton(
                      icon: Icon(Icons.night_shelter_outlined),
                      color: Colors.lightBlue[900],
                      iconSize: AppParameters.iconsSize * 1.2,
                      onPressed: _nightTimer2),
                  IconButton(
                      icon: Icon(Icons.sync_disabled),
                      color: Colors.red[600],
                      iconSize: AppParameters.iconsSize * 1.2,
                      onPressed: _turnOff4All),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: Icon(Icons.arrow_circle_down),
                      color: Colors.blue,
                      highlightColor: Colors.red[400],
                      visualDensity: VisualDensity.standard,
                      iconSize: speedIsHigh
                          ? AppParameters.iconsSize * 1.2 * 2 / 3
                          : AppParameters.iconsSize * 1.2,
                      onPressed: _setSpeedLow),
                  IconButton(
                      icon: Icon(Icons.arrow_circle_up),
                      color: Colors.blue,
                      iconSize: speedIsHigh
                          ? AppParameters.iconsSize * 1.2
                          : AppParameters.iconsSize * 1.2 * 2 / 3,
                      onPressed: _setSpeedHigh),
                ],
              ),
              SizedBox(
                height: 12,
                width: 12,
              ),
              SizedBox(
                height: 12,
                width: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: Icon(Icons.timer),
                      color: Colors.red,
                      iconSize: AppParameters.iconsSize * 1.2,
                      onPressed: _setCustomTimer),
                  /*IconButton(
                  icon: Icon(Icons.add_circle),
                  color: Colors.green,
                  iconSize: AppParameters.iconsSize * 1.2,
                  onPressed: _addOnStep),*/
                  Container(
                    width: AppParameters.iconsSize * 1.2,
                    height: AppParameters.iconsSize * 1.2,
                    color: Colors.green,
                    child: TextField(
                      style: TextStyle(
                          fontSize: AppParameters.iconsSize * 1.2 / 3,
                          color: Colors.black),
                      //decoration: InputDecoration(hintText: "روشنی"),
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      controller: cntlOnReg,
                    ),
                  ),
                  Container(
                    width: AppParameters.iconsSize * 1.2,
                    height: AppParameters.iconsSize * 1.2,
                    color: Colors.red,
                    child: TextField(
                      style: TextStyle(
                          fontSize: AppParameters.iconsSize * 1.2 / 3,
                          color: Colors.black),
                      //decoration: InputDecoration(hintText: "خاموشی"),
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      controller: cntlOffReg,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 70,
                    color: Colors.red,
                    child: TextField(
                      style: TextStyle(fontSize: 25.0, color: Colors.black),
                      decoration: InputDecoration(hintText: "cmd"),
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      controller: cntlCommand,
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 70.0,
                    color: Colors.green,
                    child: TextField(
                      style: TextStyle(fontSize: 25.0, color: Colors.black),
                      decoration: InputDecoration(hintText: "Parameter"),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      controller: cntlParam,
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.send),
                      color: Colors.blueGrey,
                      iconSize: AppParameters.iconsSize * 1.2,
                      onPressed: _sendCommand),
                ],
              ),
              Text("$_messageToShow"),
            ],
          ),
          endDrawer: Drawer(
              child: ListView(children: <Widget>[
            UserAccountsDrawerHeader(
                accountName: Text("کنترل کولر"),
                accountEmail: null,
                currentAccountPicture: CircleAvatar(
                    //  backgroundImage:Image(image: AssetImage("settings.png")),
                    )),
            IconButton(
                icon: Icon(Icons.av_timer),
                color: Colors.blueGrey,
                iconSize: AppParameters.iconsSize * 1.2,
                onPressed: _setClock),
            IconButton(
                icon: Icon(Icons.open_in_new),
                color: Colors.blueGrey,
                iconSize: AppParameters.iconsSize * 1.2,
                onPressed: () {
                  /*  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => WebBrowser("https://let2trade.com/sepehr/gps/")));
                    */
                }),
            IconButton(
                icon: Icon(Icons.settings),
                color: Colors.blueGrey,
                iconSize: AppParameters.iconsSize * 1.2,
                onPressed: _openSettingPage),
          ])),
        ),
        onWillPop: () async {
          _disconnect();
          return true;
        });
  }

  void _start() async {
    if (!isConnected) _connect();
    //if (isStopped) infoRefreshTimer();
    _sendMessage("APC_14_000000");
  }

  void _toggleConnection() {
    if (isConnected) {
      isStopped = true;
      print("Disconnecting...");
      _disconnect();
      //  _turnOffBT();
    } else {
      //   _turnOnBT();
      isStopped = false;
      print("Connecting...");
      _connect();
      if (!_timerOneSecond.isActive)
        _timerOneSecond = Timer(Duration(seconds: 1), oneSecondTimeout);
    }
  }

  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

// Method to send message,
  // for turning the bletooth device on
  void _turnOnBT() async {
    bluetooth.isEnabled.then((isConnected) {
      if (isConnected!) {
        bluetooth..write("1");
        print('Device Turned On');
      }
    });
  }

  // Method to send message,
  // for turning the bletooth device off
  void _turnOffBT() {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.write("0");
        print('Device Turned Off');
      }
    });
  }

  void _connect() async {
    isBusy = true;

    if (isConnected) {
      _lastMessage = '\nAlready connected to the Cooler\n$_lastMessage';
      _getCompactInfo();
      setState(() {
        _showAll();
      });
      isBusy = false;
      return;
    }
    // server = BluetoothDevice();
    connection = await BluetoothConnection.toAddress(AppParameters.macAddress);
    BluetoothConnection.toAddress(AppParameters.macAddress).then((_connection) {
      connection = _connection;
      _lastMessage =
          '${ApcoUtils.timeTag()}\nConnected to the Cooler\n$_lastMessage';
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
        _getCompactInfo();
      });

      connection.input?.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          _lastMessage = 'Disconnecting locally!\n$_lastMessage';
        } else {
          _lastMessage = 'Disconnected remotely!\n$_lastMessage';
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      _lastMessage =
          "${ApcoUtils.timeTag() + ' Error\n' + error.message}\n$_lastMessage";
      _errorsCount++;
    });
    if (_errorsCount > 10) {
      _errorsCount = 0;
      isDisconnecting = true;
      connection.dispose();
      // connection = null;
    }
    if (_logVisible) _messageToShow = _lastMessage;
    setState(() {});
    isBusy = false;
  }

  void _disconnect() async {
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      // connection = null;
    }
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
/*    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }
*/
    String currentMessage = String.fromCharCodes(data);
    // Create message if there is new line character

    //  _lastMessage = AP_Util.formatDateTime(DateTime.now(), 4) +
    //     " < "
    _lastMessage = currentMessage + _lastMessage;
    String tmpString = currentMessage.substring(0, 4);
    if (tmpString == "Turn") {
      _getCompactInfo();
      setState(() {});
    }
    if (tmpString == "APC_") {
      _decodeMessage(currentMessage);
    }
    if (_logVisible) _messageToShow = _lastMessage;
    setState(() {});
  }

  void _decodeMessage(String currentMessage) async {
    // isCalcutating = true;
    int index = 49;
    int tempValue = 0;
    //decode Clock
    String tmpString = currentMessage.substring(index, index + 6);
    index += 6;

    tempValue = int.parse(currentMessage.substring(index, index + 2)) * 3600;
    index += 2;
    tempValue += int.parse(currentMessage.substring(index, index + 2)) * 60;
    index += 2;
    tempValue += int.parse(currentMessage.substring(index, index + 2));
    index += 2;
    ON_Reg = tempValue;

    tempValue = int.parse(currentMessage.substring(index, index + 2)) * 3600;
    index += 2;
    tempValue += int.parse(currentMessage.substring(index, index + 2)) * 60;
    index += 2;
    tempValue += int.parse(currentMessage.substring(index, index + 2));
    index += 2;
    OFF_Reg = tempValue;

    tempValue = int.parse(currentMessage.substring(index, index + 2)) * 3600;
    index += 2;
    tempValue += int.parse(currentMessage.substring(index, index + 2)) * 60;
    index += 2;
    tempValue += int.parse(currentMessage.substring(index, index + 2));
    index += 2;
    ON_Timer = tempValue;

    tempValue = int.parse(currentMessage.substring(index, index + 2)) * 3600;
    index += 2;
    tempValue += int.parse(currentMessage.substring(index, index + 2)) * 60;
    index += 2;
    tempValue += int.parse(currentMessage.substring(index, index + 2));
    index += 2;
    OFF_Timer = tempValue;

    tempValue = int.parse(currentMessage.substring(index, index + 1));
    index += 1;
    fanIsON = tempValue == 0 ? false : true;

    tempValue = int.parse(currentMessage.substring(index, index + 1));
    index += 1;
    waterIsON = tempValue == 0 ? false : true;

    tempValue = int.parse(currentMessage.substring(index, index + 1));
    index += 1;
    speedIsHigh = tempValue == 0 ? false : true;

    tempValue = int.parse(currentMessage.substring(index, index + 1));
    index += 1;
    initSeconds = tempValue;

    tempValue = int.parse(currentMessage.substring(index, index + 1));
    index += 1;
    stepValue = tempValue;

    cntlOnReg.text = (ON_Reg ~/ 60).toString().padLeft(3, '0');
    cntlOffReg.text = (OFF_Reg ~/ 60).toString().padLeft(3, '0');
/*
    if (OFF_Timer == 0 && ON_Timer == 0)
      progressValue = 0;
    else {
      if (ON_Timer > 0) {
        progressValue = ON_Timer / ON_Reg;
        remindedTime = (ON_Timer ~/ 60).toString().padLeft(2, '0') +
            ":" +
            (ON_Timer % 60).toString().padLeft(2, '0');
      }
      if (OFF_Timer > 0) {
        progressValue = OFF_Timer / OFF_Reg;
        remindedTime = (OFF_Timer ~/ 60).toString().padLeft(2, '0') +
            ":" +
            (OFF_Timer % 60).toString().padLeft(2, '0');
      }
    }*/
    isCalcutating = false;
  }

  void _sendMessage(String text) async {
    text = text.trim();
    isBusy = true;
    if (text.length > 0) {
      if (!isConnected) _connect();
      try {
        connection.output.add(Uint8List.fromList(utf8.encode("$text\r\n")));
        //connection.output.add(utf8.encode("$text\r\n"));
        await connection.output.allSent;
        if (text.substring(4, 6) != "14") {
          cntlCommand.text = text.substring(4, 6);
          cntlParam.text = text.substring(7);
        }
        setState(() {
          //messages.add(text);
          _lastMessage = "${ApcoUtils.timeTag()} > $text$_lastMessage";
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
    isBusy = false;
  }

/*
Commands:
1: Set OnRegister
2: Set OffRegister
3: Turn ON if ONRegister is zero set to 300 (5 Min)
4: Turn Off no change on Registers
5: ON_Register Increase by one Step
6: OFF_Register Increase by one Step
7: Show ON and OFF Registers (in seconds)
8: Show All Parameters with description
9: Set Clock
10: Set Speed
11: Set Step value
12: Set Init seconds
13: Set Set Duty Cycle
14: Show All Parameters compact mode together
*/

  void _turnON() async {
    _sendMessage('APC_03_000000');
  }

  void _turnOFF() async {
    _sendMessage('APC_04_000000');
  }

  void _addOnStep() async {
    _sendMessage('APC_05_000000');
  }

  void _addOffStep() async {
    _sendMessage('APC_06_000000');
  }

  void _showAll() async {
    _sendMessage('APC_08_000000');
  }

  void _setClock() async {
    DateTime inputDate = DateTime.now();
    String command =
        "APC_09_${inputDate.hour.toString().padLeft(2, '0')}${inputDate.minute.toString().padLeft(2, '0')}${inputDate.second.toString().padLeft(2, '0')}";
    _sendMessage(command);
  }

  void _setCustomTimer() async {
    String command = "APC_13_${cntlOnReg.text}${cntlOffReg.text}";
    _sendMessage(command);
  }

  void _setSpeedLow() async {
    _sendMessage('APC_10_000000');
  }

  void _setSpeedHigh() async {
    _sendMessage('APC_10_000001');
  }

  void _turnOff4All() async {
    _sendMessage('APC_13_000000');
  }

  void _dayHotTimer() async {
    _sendMessage('APC_13_005005');
  }

  void _morningTimer() async {
    _sendMessage('APC_13_004015');
  }

  void _nightTimer() async {
    _sendMessage('APC_13_005035');
  }

  void _nightTimer2() async {
    _sendMessage('APC_13_005055');
  }

  void _getCompactInfo() async {
    _sendMessage('APC_14_000000');
  }

  void _sendCommand() async {
    if (cntlParam.text.length == 0) cntlParam.text = "000000";
    String command = "APC_${cntlCommand.text}_${cntlParam.text}";
    _sendMessage(command);
  }

  bool _logVisible = true;
  void _showHideLog() {
    if (_logVisible) {
      _logVisible = false;
      _messageToShow = "";
    } else {
      _logVisible = true;
      _messageToShow = _lastMessage;
    }
    setState(() {});
  }

  bool isStopped = false; //global
  bool isBusy = false;
  bool isCalcutating = false;

  /* sec2Timer() {
    Timer.periodic(Duration(seconds: 2), (timer) {
      if (isStopped) {
        timer.cancel();
      }
      print("Timer 2 ...\n");
      setState(() {
        if (ON_Timer > 2) ON_Timer -= 2;
      });
    });
  }
*/
  addMessage(String theMesssage) {}
/*
  infoRefreshTimer() {
    Timer.periodic(Duration(seconds: 10), (timer) {
      if (!isBusy) {
        if (isStopped) {
          timer.cancel();
        }
        print("Timer 10\n");
        _sendMessage('APC_14_000000');
        oneSecondTimeout();
        setState(() {});
      }
    });
  }
*/
  void _openSettingPage() {
    //Navigator.of(context)        .push(MaterialPageRoute(builder: (context) => SettingPage()));
  }

  void _calculate() {
    if (ON_Timer > 0) {
      ON_Timer--;
    }
    if (OFF_Timer > 0) {
      OFF_Timer--;
    }

    if (OFF_Timer == 0 && ON_Timer == 0)
      progressValue = 0;
    else {
      if (ON_Timer > 0) {
        progressValue = ON_Timer / ON_Reg;
        remindedTime =
            "${(ON_Timer ~/ 60).toString().padLeft(2, '0')}:${(ON_Timer % 60).toString().padLeft(2, '0')}";
      }
      if (OFF_Timer > 0) {
        progressValue = OFF_Timer / OFF_Reg;
        remindedTime =
            "${(OFF_Timer ~/ 60).toString().padLeft(2, '0')}:${(OFF_Timer % 60).toString().padLeft(2, '0')}";
      }
    }
  }

  void oneSecondTimeout() {
    if (isStopped) {
      return;
    }
    if (_seconds++ > 9) {
      _seconds = 0;
      if (!isBusy) {
        print("Timer 10\n");
        _sendMessage('APC_14_000000');
        oneSecondTimeout();
      }
    }
    print("Second\n");
    _calculate();
    setState(() {});
    if (!_timerOneSecond.isActive)
      _timerOneSecond = Timer(Duration(seconds: 1), oneSecondTimeout);
  }
/*
  oneSecondTimer() {
    Timer.periodic(Duration(seconds: 1), (oneSecTimer) {
      if (isStopped) {
        oneSecTimer.cancel();
      }

      print("Second\n");

      if (ON_Timer > 0) {
        ON_Timer--;
      }
      if (OFF_Timer > 0) {
        OFF_Timer--;
      }

      if (OFF_Timer == 0 && ON_Timer == 0)
        progressValue = 0;
      else {
        if (ON_Timer > 0) {
          progressValue = ON_Timer / ON_Reg;
          remindedTime = (ON_Timer ~/ 60).toString().padLeft(2, '0') +
              ":" +
              (ON_Timer % 60).toString().padLeft(2, '0');
        }
        if (OFF_Timer > 0) {
          progressValue = OFF_Timer / OFF_Reg;
          remindedTime = (OFF_Timer ~/ 60).toString().padLeft(2, '0') +
              ":" +
              (OFF_Timer % 60).toString().padLeft(2, '0');
        }
      }

      setState(() {});
    });
  }

*/
}

class ApcoUtils {
  static String timeTag() {
    return formatDateTime(DateTime.now(), 4);
  }

  static String formatDateTime(DateTime inputDate, int format) {
    String output = "";
    switch (format) {
      case 0:
        output = "${inputDate.hour}:${inputDate.minute}:${inputDate.second}";
        break;
      case 1:
        output =
            "${inputDate.year.toString().padLeft(2, '0')}/${inputDate.month.toString().padLeft(2, '0')}/${inputDate.day.toString().padLeft(2, '0')}  ${inputDate.hour.toString().padLeft(2, '0')}:${inputDate.minute.toString().padLeft(2, '0')}:${inputDate.second.toString().padLeft(2, '0')}";
        break;
      case 2:
        output =
            "${inputDate.year.toString().padLeft(2, '0')}/${inputDate.month.toString().padLeft(2, '0')}/${inputDate.day.toString().padLeft(2, '0')}  ${inputDate.hour.toString().padLeft(2, '0')}:${inputDate.minute.toString().padLeft(2, '0')}";
        break;
      case 3:
        output =
            "${inputDate.hour.toString().padLeft(2, '0')}:${inputDate.minute.toString().padLeft(2, '0')}";

        break;
      case 4:
        output =
            "${inputDate.hour.toString().padLeft(2, '0')}:${inputDate.minute.toString().padLeft(2, '0')}:${inputDate.second.toString().padLeft(2, '0')}";

        break;
      default:
        output = "?";
    }

    return output;
  }

  static String persianDayOfWeek(DateTime grDate) {
    String strOut = "_";
    switch (grDate.weekday) {
      case 6:
        strOut = "شنبه";
        break;
      case 7:
        strOut = "یکشنبه";
        break;
      case 1:
        strOut = "دوشنبه";
        break;
      case 2:
        strOut = "سه شنبه";
        break;
      case 3:
        strOut = "چهارشنبه";
        break;
      case 4:
        strOut = "پنجشنبه";
        break;
      case 5:
        strOut = "جمعه";
        break;
    }
    return (strOut);
  }

  static String persianMonthName(int persianMonth) {
    switch (persianMonth) {
      case 1:
        return "فروردین";
      case 2:
        return "اردیبهشت";
      case 3:
        return "خرداد";
      case 4:
        return "تیر";
      case 5:
        return "مرداد";
      case 6:
        return "شهریور";
      case 7:
        return "مهر";
      case 8:
        return "آبان";
      case 9:
        return "آذر";
      case 10:
        return "دی";
      case 11:
        return "بهمن";
      case 12:
        return "اسفند";
      default:
        return "";
    }
  }

  static bool isLeapYear(int persianYear) {
    int remind = persianYear % 33;
    return (remind == 1 ||
        remind == 5 ||
        remind == 9 ||
        remind == 13 ||
        remind == 18 ||
        remind == 22 ||
        remind == 26 ||
        remind == 30);
  }

  static String toPersianDateFull(DateTime grDate) {
    String output = "";
    try {
      output += persianDayOfWeek(grDate);
      output += " ${toPersianDate(grDate)} ";
      output += "${grDate.hour}:${grDate.minute}";
    } catch (exn) {}
    return output;
  }

  static String toPersianDateYYMMDDHHmm(DateTime grDate) {
    String output = "";
    try {
      output += "${toPersianDate(grDate)} ";
      output += "${grDate.hour}:${grDate.minute}";
    } catch (exn) {}
    return output;
  }

  static String toPersianDateYYMMDDHHmmss(DateTime grDate) {
    String output = "";
    try {
      output += "${toPersianDate(grDate)} ";
      output +=
          "${grDate.hour.toString().padLeft(2, '0')}:${grDate.minute.toString().padLeft(2, '0')}:${grDate.second.toString().padLeft(2, '0')}";
    } catch (exn) {}
    return output;
  }

  static String toPersianDate(DateTime grDate) {
    List<int> monthDays = [];

    monthDays.insert(0, 31);
    monthDays.insert(1, 31);
    monthDays.insert(2, 28);
    monthDays.insert(3, 31);
    monthDays.insert(4, 30);
    monthDays.insert(5, 31);
    monthDays.insert(6, 31);
    monthDays.insert(6, 30);
    monthDays.insert(7, 31);
    monthDays.insert(8, 31);
    monthDays.insert(9, 30);
    monthDays.insert(10, 31);
    monthDays.insert(11, 30);
    monthDays.insert(12, 31);
    int grDay = grDate.day;
    int grMonth = grDate.month;
    int grYear = grDate.year;
    int perYear;
    int perMonth;
    int perDays;
    int perDay;
    if (grYear % 4 == 0) {
      monthDays[2] = 29;
    } else {
      monthDays[2] = 28;
    }

    int grDays = grDay;
    if (grMonth > 1) {
      for (int I = 1; I < grMonth; I++) {
        grDays = grDays + monthDays[I];
      }
    }

    if (grDays < 80) {
      perYear = grYear - 622;
      perDays = grDays + 286;
      if (perYear % 4 == 3) perDays = perDays + 1;
    } else {
      perYear = grYear - 621;
      perDays = grDays - 79;
    }
    perDay = perDays;
    if (perDays <= 186)
      for (perMonth = 0; perDay > 31; perMonth++) {
        if (perDay > 30) perDay = perDay - 31;
      }
    else {
      perDay = perDay - 186;
      for (perMonth = 6; perDay > 30; perMonth++) {
        perDay = perDay - 30;
      }
    }

    perMonth = perMonth + 1;

    String strOut = "${perYear.toString().padLeft(4)}/$perMonth/$perDay";

    return (strOut);
  }

  static DateTime toGregorianDate(String perDate) {
    bool isValid;
    DateTime output = DateTime(1900, 1, 1);
    int perDays, grYear = 0, grDays = 0, grDay = 0, grMonth = 0;
    List<int> monthDays = [];

    monthDays.insert(0, 31);
    monthDays.insert(1, 31);
    monthDays.insert(2, 31);
    monthDays.insert(3, 31);
    monthDays.insert(4, 30);
    monthDays.insert(5, 31);
    monthDays.insert(6, 31);
    monthDays.insert(6, 30);
    monthDays.insert(7, 31);
    monthDays.insert(8, 31);
    monthDays.insert(9, 30);
    monthDays.insert(10, 31);
    monthDays.insert(11, 30);
    monthDays.insert(12, 31);

    try {
      String strBuffer = perDate.substring(0, perDate.indexOf("/"));
      int perYear = int.parse(strBuffer);
      perDate = perDate.substring(perDate.indexOf("/") + 1);

      strBuffer = perDate.substring(0, perDate.indexOf("/"));
      int perMonth = int.parse(strBuffer);
      perDate = perDate.substring(perDate.indexOf("/") + 1);
      //strBuffer = Sh_Date.substring(0, Sh_Date.indexOf(" "));

      int perDay = int.parse(perDate);
      isValid = true;
      if (perMonth < 7 && perDay > 31) isValid = false;
      if (7 < perMonth && perMonth < 11 && perDay > 30) isValid = false;
      if (perMonth == 12) if ((perYear % 4 == 3 && perDay > 30) ||
          (perYear % 4 != 3 && perDay > 29)) {
        isValid = false;
      }
      if (perMonth > 12 || perMonth < 1) isValid = false;
      if (!isValid) return (DateTime.parse("1900-01-01 00:00:00"));

      if (perMonth <= 7) {
        perDays = 31 * perMonth + perDay - 31;
      } else {
        perDays = 30 * perMonth + perDay - 24;
      }

      int isLeapYear = perYear % 4;
      if (isLeapYear == 3 && perDays <= 287) {
        grYear = perYear + 621;
        grDays = perDays + 79;
      } else if (isLeapYear == 3 && perDays > 287) {
        grYear = perYear + 622;
        grDays = perDays - 287;
      } else if (isLeapYear != 3 && perDays <= 286) {
        grYear = perYear + 621;
        grDays = perDays + 79;
      } else if (isLeapYear != 3 && perDays > 286) {
        grYear = perYear + 622;
        grDays = perDays - 286;
      }

      if (grYear % 4 == 0) {
        monthDays[2] = 29;
      } else {
        monthDays[2] = 28;
      }

      grDay = grDays;
      bool done = false;
      for (grMonth = 1; grMonth < 13 && !done; grMonth++) {
        if (grDay <= monthDays[grMonth]) {
          done = true;
        } else {
          grDay = grDay - monthDays[grMonth];
        }
      }
      grMonth--;
      strBuffer =
          "$grYear-${grMonth.toString().padLeft(2, '0')}-${grDay.toString().padLeft(2, '0')} 00:00:00";
      output = DateTime.parse(strBuffer); // "1900-01-01 00:00:00")
      return (output);
    } catch (exp) {
      return (DateTime.parse("1900-01-01 00:00:00"));
    }
  }
}
