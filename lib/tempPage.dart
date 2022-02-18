import 'package:ap_me/AppParameters.dart';
import 'package:ap_me/FriendsPageDrawer.dart';
import 'package:flutter/material.dart';
//import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'AppSettings.dart';

class TempPage extends StatefulWidget {
  const TempPage({Key key}) : super(key: key);

  @override
  _TempPageState createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String strMessage = "Temp Page For TEST";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSettings.formsBackgroundColor,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppSettings.titlesBackgroundColor,
        foregroundColor: AppSettings.titlesForegroundColor,
        brightness: AppSettings.nightMode ? Brightness.dark : Brightness.light,
        actions: [
          IconButton(
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
                //Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu)),
          IconButton(
              color: AppSettings.titlesForegroundColor,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu_open_outlined))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(strMessage,
                style: TextStyle(
                    color: AppSettings.formsForegroundColor,
                    fontSize: AppSettings.messageBodyFontSize)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      AppSettings.saveNightMode(!AppSettings.nightMode);
                    });
                  },
                  icon: Icon(
                    AppSettings.nightMode
                        ? Icons.nightlight_outlined
                        : Icons.wb_sunny_outlined,
                  ),
                  iconSize: 35,
                  color: AppSettings.titlesForegroundColor,
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
/*
        byte[] initVectorBytes = Encoding.UTF8.GetBytes(initVector);
        byte[] plainTextBytes = Encoding.UTF8.GetBytes(plainText);
        PasswordDeriveBytes password = new PasswordDeriveBytes(passPhrase, null);
        byte[] keyBytes = password.GetBytes(keysize / 8);
        RijndaelManaged symmetricKey = new RijndaelManaged();
        symmetricKey.Mode = CipherMode.CBC;
        ICryptoTransform encryptor = symmetricKey.CreateEncryptor(keyBytes, initVectorBytes);
        MemoryStream memoryStream = new MemoryStream();
        CryptoStream cryptoStream = new CryptoStream(memoryStream, encryptor, CryptoStreamMode.Write);
        cryptoStream.Write(plainTextBytes, 0, plainTextBytes.Length);
        cryptoStream.FlushFinalBlock();
        byte[] cipherTextBytes = memoryStream.ToArray();
        memoryStream.Close();
        cryptoStream.Close();
        return Convert.ToBase64String(cipherTextBytes);
*/
                        //String hashedPassword = sha256.convert(data).toString();
                        String strPass = "Salam bache";
                        String keyPhrase = "ApMe1400";
                        String encrypted = "xkVrB5as8RIlQ/hMANbPSA==";
                        // var bytes = utf8.encode(strPass); // data being hashed
                        // var key = utf8.encode(keyPhrase);
                        // var digest = sha256.convert(bytes);
                        var key = utf8.encode(strPass);
                        var bytes = utf8.encode(keyPhrase);

                        /*  var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
                       var digest = hmacSha256.convert(bytes);
                        encrypted = utf8.decode(digest.bytes);
                        print("HMAC digest as bytes: ${digest.bytes}");
                        print("HMAC digest as hex string: $digest");
                        print("HMAC digest as string: $encrypted");*/
                      });
                    },
                    icon: Icon(Icons.get_app_rounded),
                    iconSize: 35,
                    color: AppSettings.titlesForegroundColor),
                IconButton(
                    onPressed: () {
                      setState(() {
                        setupList();
                      });
                    },
                    icon: Icon(Icons.dashboard),
                    iconSize: 35,
                    color: AppSettings.titlesForegroundColor),
                IconButton(
                    onPressed: () {
                      setState(() {
                        settings = [];
                      });
                    },
                    icon: Icon(Icons.delete),
                    iconSize: 35,
                    color: AppSettings.titlesForegroundColor),
              ],
            ),
            _buildList(settings),
          ],
        ),
      ),
      endDrawer: FriendsPageDrawer.sideDrawer(this),
    );
  }

  List<AppSetting> settings = [];

  void setupList() async {
    //var _items = await AppSettings.fetchSettings();
    var _items = await AppSettings.getAllSettings(100);
    setState(() {
      settings = _items;
    });
  }

  TextStyle myStyle() {
    return TextStyle(
      fontSize: 12,
      color: AppSettings.formsForegroundColor,
    );
  }

  Widget _buildList(List<AppSetting> settingsList) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: settingsList.length,
        itemBuilder: (BuildContext context, int index) {
          return Row(
            children: <Widget>[
              Expanded(
                flex: 30,
                child: Column(
                  children: <Widget>[
                    Text('Name', style: myStyle()),
                    Text(settingsList[index].settingName.toString(),
                        style: myStyle()),
                  ],
                ),
              ),
              Expanded(
                flex: 30,
                child: Column(
                  children: <Widget>[
                    Text('Value', style: myStyle()),
                    Text(settingsList[index].settingValue, style: myStyle()),
                  ],
                ),
              ),
              Expanded(
                flex: 10,
                child: Material(
                  child: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {},
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: Material(
                  child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          );
        },
        reverse: false,
      ),
    );
  }
}
