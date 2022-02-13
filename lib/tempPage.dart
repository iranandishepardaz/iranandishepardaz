import 'package:ap_me/AppParameters.dart';
import 'package:ap_me/FriendsPageDrawer.dart';
import 'package:flutter/material.dart';

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
      backgroundColor: AppParameters.formsBackgroundColor,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppParameters.titlesBackgroundColor,
        foregroundColor: AppParameters.titlesForegroundColor,
        actions: [
          IconButton(
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
                //Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu)),
          IconButton(
              color: AppParameters.titlesForegroundColor,
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
                style: TextStyle(fontSize: AppSettings.messageBodyFontSize)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      AppSettings.nightMode = !AppSettings.nightMode;
                      AppSettings.saveNightMode(true);
                    });
                  },
                  icon: Icon(Icons.settings_backup_restore_rounded),
                  iconSize: 35,
                  color: AppParameters.titlesForegroundColor,
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        AppSettings.nightMode = false;
                        AppSettings.readNightMode();
                      });
                    },
                    icon: Icon(Icons.get_app_rounded),
                    iconSize: 35,
                    color: AppParameters.titlesForegroundColor),
                IconButton(
                    onPressed: () {
                      setState(() {
                        setupList();
                      });
                    },
                    icon: Icon(Icons.dashboard),
                    iconSize: 35,
                    color: AppParameters.titlesForegroundColor),
                IconButton(
                    onPressed: () {
                      setState(() {
                        settings = [];
                      });
                    },
                    icon: Icon(Icons.delete),
                    iconSize: 35,
                    color: AppParameters.titlesForegroundColor),
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
      color: AppParameters.formsForegroundColor,
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
                child: Column(
                  children: <Widget>[
                    Text('Name', style: myStyle()),
                    Text(settingsList[index].settingName.toString(),
                        style: myStyle()),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text('Value', style: myStyle()),
                    Text(settingsList[index].settingValue, style: myStyle()),
                  ],
                ),
              ),
              Expanded(
                child: Material(
                  child: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {},
                  ),
                ),
              ),
              Expanded(
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
