import 'package:flutter/material.dart';
import 'AppParameters.dart';
import 'AppSettings.dart';

class ApcoUtils {
  /* static String formatDateTime(DateTime inputDate, int format) {
    String _output = "";
    try {
      switch (format) {
        case 0:
          _output = inputDate.hour.toString() +
              ":" +
              inputDate.minute.toString() +
              ":" +
              inputDate.second.toString();
          break;
        case 1:
          _output = inputDate.year.toString() +
              "/" +
              inputDate.month.toString() +
              "/" +
              inputDate.day.toString() +
              "  " +
              inputDate.hour.toString() +
              ":" +
              inputDate.minute.toString() +
              ":" +
              inputDate.second.toString();
          break;
        default:
          _output = "?";
      }
    } catch (e) {
      _output = e.toString();
    }
    return _output;
  }
*/
  static void showSnackMessage(String messageToShow, BuildContext context,
      {int durationSeconds = 1}) {
    /* if (durationSeconds == null) {
      durationSeconds = 1;
    }*/
    Duration duration = Duration(seconds: durationSeconds);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
        messageToShow,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: AppSettings.messageBodyFontSize,
        ),
      ),
      duration: duration,
      backgroundColor: AppSettings.titlesBackgroundColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppSettings.titlesForegroundColor)),
    ));
    //setState(() {});
  }

  static Future<ResultEnums> apcoShowDialog(
      BuildContext buildContext, String dialogTitle,
      {String? yesKeyText, String? noKeyText}) async {
    ResultEnums output = ResultEnums.Unknown;
    AlertDialog dialog = AlertDialog(
      backgroundColor: AppSettings.titlesBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
            width: 2.0, color: AppSettings.sentDeliveredMessageForeColor),
      ),
      elevation: 16,
      title: Text(
        dialogTitle,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: AppSettings.titlesForegroundColor,
            backgroundColor: AppSettings.titlesBackgroundColor,
            fontSize: AppSettings.messageBodyFontSize * 1.2),
      ),
      content: Container(
        height: 70,
        child: Container(
          color: AppSettings.titlesBackgroundColor,
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: AppSettings.formsForegroundColor),
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Material(
                  elevation: 20,
                  borderRadius: BorderRadius.circular(40),
                  color: AppSettings.formsBackgroundColor,
                  child: InkWell(
                    onTap: () {
                      output = ResultEnums.Yes;
                      Navigator.of(buildContext).pop();
                    },
                    child: Container(
                      height: 50,
                      width: 80,
                      child: Center(
                        child: Text(
                          yesKeyText == null ? "بلی" : yesKeyText,
                          style: TextStyle(
                              fontFamily: "Vazir",
                              color: AppSettings.formsForegroundColor,
                              fontSize: AppSettings.messageBodyFontSize * 1.2),
                        ),
                      ),
                    ),
                  ),
                ),
                Material(
                  elevation: 20,
                  borderRadius: BorderRadius.circular(40),
                  color: AppSettings.formsBackgroundColor,
                  child: InkWell(
                    onTap: () {
                      output = ResultEnums.No;
                      Navigator.of(buildContext).pop();
                    },
                    child: Container(
                      height: 50,
                      width: 80,
                      child: Center(
                        child: Text(
                          "خیر",
                          style: TextStyle(
                              fontFamily: "Vazir",
                              color: AppSettings.formsForegroundColor,
                              fontSize: AppSettings.messageBodyFontSize * 1.2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await showDialog(
        context: buildContext,
        barrierDismissible: false,
        builder: (_) => dialog);
    return output;
  }
}
