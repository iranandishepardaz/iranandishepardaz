/*
import 'AppSettings.dart';

class Settings {
//static get nightMode =>_nMode==null ? (_nMode =await getNightMode()): _nMode;
  static bool _nMode = null;
  static get nightMode => () async {
        if (_nMode != null) return _nMode;
        try {
          AppSetting tmpSetting = await AppSettings.getSetting("nightMode");
          _nMode = tmpSetting.settingValue.toLowerCase() == 'true' ||
              tmpSetting.settingValue.toLowerCase() == '1';
        } catch (e) {
          AppSetting(settingName: "nightMode", settingValue: _nMode.toString())
              .insert();
        }
        return _nMode;
      };
}*/
