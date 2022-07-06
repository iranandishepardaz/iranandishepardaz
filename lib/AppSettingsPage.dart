import 'ChatPage.dart';
import 'FriendsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppSettingsPage extends StatefulWidget {
  @override
  _AppSettingsPageState createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  static double _plusOne = 1;
  static double _plusTwo = 2;
  static double _plusTree = 3;
  static double _startPrice = 100;
  static double _endPrice = 100;
  static double _minusOne = -1;
  static double _minusTwo = -2;
  static double _minusTree = -3;

  static double _count = 1;
  static double _fee = 0.001;
  static double _totalStart = 1;
  static double _totalEnd = 1;
  static double _startFee = 1;
  static double _zeroLoss = 1;
  static double _endFee = 1;
  static double _diffrence = 0;
  static double _percent = 0;
  static bool _buySell = true;
  static bool _futureSpot = true;
  static bool _bnbFee = true;
  final startPriceController = TextEditingController();
  final endPriceController = TextEditingController();
  final countController = TextEditingController();
  final feeController = TextEditingController();
  static double spaceBet = 0.3;
  static int _digits = 5;
  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    startPriceController.addListener(_calculate());
  }

  String format(double n) {
    String s = n.toStringAsFixed(n.truncateToDouble() == n ? 0 : _digits);
    if (s.indexOf('.') >= 0)
      while (s.endsWith('0')) {
        s = s.substring(0, s.length - 1);
      }
    return s;
  }

  String formatDigit(double n, int digits) {
    String s = n.toStringAsFixed(n.truncateToDouble() == n ? 0 : digits);
    if (s.indexOf('.') >= 0)
      while (s.endsWith('0')) {
        s = s.substring(0, s.length - 1);
      }
    return s;
  }

  _clearAll() {
    startPriceController.text = "";
    endPriceController.text = "";
    countController.text = "";
    _calculate();
  }

  _calculate() {
    try {
      _startPrice = double.parse(startPriceController.text);
    } catch (ex) {
      _startPrice = 0;
    }
    try {
      _endPrice = double.parse(endPriceController.text);
    } catch (ex) {
      _endPrice = 0;
    }

    try {
      _count = double.parse(countController.text);
    } catch (ex) {
      _count = 0;
    }
    _plusTree = _startPrice * 1.03;
    _plusTwo = _startPrice * 1.02;
    _plusOne = _startPrice * 1.01;
    _minusOne = _startPrice * 0.99;
    _minusTwo = _startPrice * 0.98;
    _minusTree = _startPrice * 0.97;
    _totalStart = _count * _startPrice;
    _totalEnd = _count * _endPrice;
    if (_bnbFee) {
      if (_futureSpot)
        _fee = 0.00018;
      else
        _fee = 0.00075;
    } else {
      if (_futureSpot)
        _fee = 0.0002;
      else
        _fee = 0.001;
    }
    if (_buySell) {
      _diffrence = _totalEnd - _totalStart;
      _percent = ((_endPrice - _startPrice) / _startPrice) * 100;
      _zeroLoss = (_totalStart + (2 * _fee * _totalStart)) / _count;
    } else {
      _diffrence = _totalStart - _totalEnd;
      _percent = ((_startPrice - _endPrice) / _endPrice) * 100;
      _zeroLoss = (_totalStart - (2 * _fee * _totalStart)) / _count;
    }
    _diffrence -= (_fee * _totalStart + _fee * _totalEnd);
    _startFee = _totalStart * _fee;
    _endFee = _totalEnd * _fee;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(30.0), // here the desired height
            child: AppBar(
              backgroundColor: Colors.black,
              title: Text(
                "Crypto Trade Util",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              centerTitle: true,
              // leading: IconButton(
              //     icon: Icon(Icons.calculate, color: Colors.white),
              //     onPressed: () {
              //       Navigator.push(context,
              //           MaterialPageRoute(builder: (context) => profit()));
              //     }),

              // leading: IconButton(
              //   icon: Icon(Icons.calculate, color: Colors.white),
              //   onPressed: () => Navigator.of(context).pop(),
              // ),
            ),
          ),
          body: Container(
            // height: MediaQuery.of(context).size.height * 0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 35,
                  child: Container(
                    color: Colors.black87,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2, right: 2),
                      child: Column(
                        children: [
                          SizedBox(
                            height: spaceBet,
                          ),
                          Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  " +3%   " + formatDigit(_plusTree, 5),
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: spaceBet,
                          ),
                          Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  " +2%   " + format(_plusTwo),
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: spaceBet,
                          ),
                          Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  " +1%   " + format(_plusOne),
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: spaceBet,
                          ),
                          TextField(
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.singleLineFormatter
                            ],
                            onChanged: (text) {
                              _calculate();
                            },
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            controller: startPriceController,
                            decoration: InputDecoration(
                              // icon: const Icon(Icons.two_mp),
                              labelText: "Start Price",
                              labelStyle: new TextStyle(color: Colors.white),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                  color: Colors.greenAccent,
                                ),
                              ),
                              //errorText: "Enter Number only",
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          // Card(
                          //   child: new InkWell(
                          //     onTap: () {
                          //       debugPrint("tapped");
                          //     },
                          //     child: Container(
                          //       width: 70.0,
                          //       height: 20.0,
                          //     ),
                          //   ),
                          // ),

                          SizedBox(
                            height: spaceBet,
                          ),
                          Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "  -1%  " + format(_minusOne),
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 16),
                                ),
                                // new InkWell(
                                //     onTap: () {
                                //       debugPrint("object");
                                //     },
                                //   ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: spaceBet,
                          ),
                          Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "  -2%  " + format(_minusTwo),
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: spaceBet,
                          ),
                          Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "  -3%  ${format(_minusTree)}",
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          // Card(
                          //   color: Colors.white,
                          //   elevation: 8,
                          //   child: InkWell(
                          //     splashColor: Colors.red,
                          //     onTap: () async {},
                          //   ),
                          // ),
                          ElevatedButton(
                              child: Text("Clear" //Icons.delete_forever
                                  ),
                              style:
                                  ElevatedButton.styleFrom(primary: Colors.red),
                              onPressed: _clearAll),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _bnbFee ? "BNB" : "Tether",
                                style: TextStyle(
                                    color: _bnbFee
                                        ? Colors.yellow
                                        : Colors.greenAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Switch(
                                value: _bnbFee,
                                onChanged: (value) {
                                  _bnbFee = value;
                                  _calculate();
                                },
                                inactiveThumbColor: Colors.green[200],
                                inactiveTrackColor: Colors.greenAccent,
                                activeTrackColor: Colors.yellow,
                                activeColor: Colors.yellow[100],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 65,
                  child: Container(
                    color: Colors.black87,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Column(
                        children: [
                          // Card(
                          //   color: Colors.white,
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //       Text(
                          //         _buySell ? "Buy" : "Sell",
                          //         style: TextStyle(
                          //             color:
                          //                 _buySell ? Colors.green : Colors.red,
                          //             fontSize: 16),
                          //       ),
                          //       Switch(
                          //         value: _buySell,
                          //         onChanged: (value) {
                          //           _buySell = value;
                          //           _calculate();
                          //         },
                          //         inactiveThumbColor: Colors.blue,
                          //         inactiveTrackColor: Colors.red,
                          //         activeTrackColor: Colors.green,
                          //         activeColor: Colors.blue,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          SizedBox(
                            height: 2 * spaceBet,
                          ),
                          TextField(
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.singleLineFormatter
                              ],
                              onChanged: (text) {
                                _calculate();
                              },
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              controller: countController,
                              decoration: InputDecoration(
                                  // icon: const Icon(Icons.two_mp),
                                  labelText: "Count",
                                  labelStyle:
                                      new TextStyle(color: Colors.white),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: BorderSide(
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                  //errorText: "Enter Number only",
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ))),
                          SizedBox(
                            height: spaceBet * 12,
                          ),
                          TextField(
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.singleLineFormatter
                              ],
                              onChanged: (text) {
                                _calculate();
                              },
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              cursorColor: Colors.yellow,
                              controller: endPriceController,
                              decoration: InputDecoration(
                                  // icon: const Icon(Icons.two_mp),
                                  labelText: "End Price",
                                  labelStyle:
                                      new TextStyle(color: Colors.white),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: BorderSide(
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                  //errorText: "Enter Number only",
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ))),
                          SizedBox(
                            height: spaceBet,
                          ),
                          Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  " Break Even: " + formatDigit(_zeroLoss, 6),
                                  style: TextStyle(
                                      color:
                                          _buySell ? Colors.green : Colors.red,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: spaceBet,
                          ),
                          Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  " Start: " +
                                      format(_totalStart) +
                                      "    (" +
                                      formatDigit(_startFee, 3) +
                                      ")",
                                  style: TextStyle(
                                      color:
                                          _buySell ? Colors.green : Colors.red,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: spaceBet,
                          ),
                          Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  " End:   " +
                                      format(_totalEnd) +
                                      "    (" +
                                      formatDigit(_endFee, 2) +
                                      ")",
                                  style: TextStyle(
                                      color:
                                          _buySell ? Colors.red : Colors.green,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: spaceBet,
                          ),
                          Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  " PNL:  " + format(_diffrence) + " \$ ",
                                  style: TextStyle(
                                      color: _diffrence >= 0
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  " Per :  " + formatDigit(_percent, 2) + " %",
                                  style: TextStyle(
                                      color: _percent >= 0
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          Card(
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Card(
                                  color: Colors.white,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _futureSpot ? "Future" : "Spot",
                                        style: TextStyle(
                                            color: _futureSpot
                                                ? Colors.orange
                                                : Colors.brown,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Switch(
                                        value: _futureSpot,
                                        onChanged: (value) {
                                          _futureSpot = value;
                                          _calculate();
                                        },
                                        inactiveThumbColor: Colors.brown[200],
                                        inactiveTrackColor: Colors.brown,
                                        activeTrackColor: Colors.orange,
                                        activeColor: Colors.orange[200],
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _buySell ? "Buy" : "Sell",
                                  style: TextStyle(
                                      color:
                                          _buySell ? Colors.green : Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Switch(
                                  value: _buySell,
                                  onChanged: (value) {
                                    _buySell = value;
                                    _calculate();
                                  },
                                  inactiveThumbColor: Colors.blue,
                                  inactiveTrackColor: Colors.red,
                                  activeTrackColor: Colors.green,
                                  activeColor: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          endDrawer: Drawer(
            child: ListView(
              children: <Widget>[
                const UserAccountsDrawerHeader(
                    accountName: Text("Trader "),
                    accountEmail: Text(
                      " ",
                      // "نام‌کاربری" + ":" + "  " + App_Parameters.currentUserName,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: AssetImage("bitcoin.png"),
                    )),
                ListTile(
                  title: Text(
                    "Settings",
                    textDirection: TextDirection.rtl,
                  ),
                  leading: Icon(Icons.settings),
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 300),
                          pageBuilder: (BuildContext context,
                              Animation<double> animation,
                              Animation<double> secAnimation) {
                            return FriendsPage();
                          },
                          transitionsBuilder: (BuildContext context,
                              Animation<double> animation,
                              Animation<double> secAnimation,
                              Widget child) {
                            return SlideTransition(
                              child: child,
                              position: Tween<Offset>(
                                      begin: Offset(1, 0), end: Offset(0, 0))
                                  .animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOutSine)),
                            );
                          }),
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    "Profit",
                    textDirection: TextDirection.rtl,
                  ),
                  leading: Icon(Icons.calculate),
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                          transitionDuration: Duration(
                              milliseconds:
                                  300), //انیمیشن که چقدر زمان ببرد صفجه جدید باز شود
                          pageBuilder: (BuildContext context,
                              Animation<double> animation,
                              Animation<double> secAnimation) {
                            return ChatPage();
                          },
                          transitionsBuilder: (BuildContext context,
                              Animation<double> animation,
                              Animation<double> secAnimation,
                              Widget child) {
                            //انیمیشنی که میخاهیم از یک صفحه به صفحه دیگر برود را وارد میکنیم
                            return SlideTransition(
                              child: child,
                              position: Tween<Offset>(
                                      begin: Offset(1, 0), end: Offset(0, 0))
                                  .animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOutSine)),
                            );
                          }),
                    );
                  },
                ),
              ],
            ),
          )),
    );
  }
}
