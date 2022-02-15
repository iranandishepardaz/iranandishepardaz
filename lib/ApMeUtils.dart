import 'dart:async';
import 'dart:convert';

import 'AppParameters.dart';
import 'package:http/http.dart';

//Parameters:
//0:Op Code
//1:UserName
//2:Password
//3:PartnerId
//4:MessageBody
//5:Sent at
//6:Delivired at
//7:Seen at
//8:MessageType
//9:URL

//Op Codes:
//101 : User Login
//102 : Get All Undelivered Messages (of Current User)
//103 : Send Message to
//104 : Get All Messages (of Current User)
//105 : Get Friends List (of Current User)
//106 : Change Password
//107 : Set Delivered Messages (Sync Messages)
//108 :
//109 :
//110 :

class ApMeUtils {
  static String url = AppParameters.mainSiteURL;
  static String serviceName = "MesServices.asmx";

  static Future transactWithSite(
      String operation, List<String> parameters) async {
    return await transactWithSiteFull(operation, parameters, "");
  }

  static Future transactWithSiteFull(
      String operation, List<String> parameters, String base64File) async {
    AppParameters.networkOK = false;
    String result = "";
    Map<String, String> headers = {
      'Content-Type': 'text/xml; charset=utf-8',
      'SOAPAction': 'http://tempuri.org/$operation'
    };

    String soap = "<?xml version=\"1.0\" encoding=\"utf-8\"?>";
    soap +=
        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" ";
    soap += "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" ";
    soap += "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">";
    soap += "<soap:Body>";
    soap += "<$operation xmlns=\"http://tempuri.org/\">";
    if (parameters.length > 0) {
      soap += "<Parameters>";
      for (int i = 0; i < parameters.length; i++) {
//        String tmpParam =utf8.encode( parameters[i]);
        //  var pdfText = await json.decode(json.encode(parameters[i]));
        var pdfText = parameters[i];
        soap += "<string>" + pdfText + "</string>";
      }
      soap += "</Parameters>";
    }
    if (base64File.length > 0) {
      soap += "<f>";
      soap += base64File;
      soap += "</f>";
    }
    soap += "</$operation>";
    soap += "</soap:Body>";
    soap += "</soap:Envelope>";
    //var bbody = json.encode(utf8.encode(soap));
    try {
      Response response = await post(
        url + serviceName,
        headers: headers,
        body: utf8.encode(soap),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Check Connection");
      }
          // ).timeout(const Duration(seconds: 10),onTimeout: () {
          //   throw TimeoutException("Connection timed out");
          // }
          );

      if (response.statusCode == 200) {
        //successful
        int index = response.body.indexOf("<" + operation + "Result>");
        if (index > 0) {
          result = response.body.substring(index + operation.length + 8);
          index = result.indexOf("</" + operation + "Result>");
          result = result.substring(0, index);
          AppParameters.networkOK = true;
        } else {}
      } else {
        return ("Web request error:" + response.statusCode.toString());
      }
    } catch (e) {
      print("Oh my god site is down : " + e.toString());
    }
    return result;
  }

  static List<List<String>> decodeServerMessage(String serverMessage) {
    int rows = serverMessage.allMatches(";^;\n;^;").length;
    rows = ";^;\n;^;".allMatches(serverMessage).length;
//var allRecords = List.generate(rows, (index) => "-");
    List<List<String>> records = List.generate(
        rows,
        (index) => [
              "-",
              "-",
              "-",
              "-",
              "-",
              "-",
              "-",
              "-",
              "-",
              "-",
              "-",
              "-",
            ]);
    int recordEndIndex = serverMessage.indexOf(";^;\n;^;");
    int i = 0;
    int j = 0;
    while (recordEndIndex >= 0) {
      String recordBuffer = serverMessage.substring(0, recordEndIndex + 3);
      int fieldEndIndex = serverMessage.indexOf(";^;");
      //fields.clear();
      while (fieldEndIndex >= 0) {
        records[i][j] = recordBuffer.substring(0, fieldEndIndex);
        //fields.add(recordBuffer.substring(0, fieldEndIndex));
        recordBuffer = recordBuffer.substring(fieldEndIndex + 3);
        fieldEndIndex = recordBuffer.indexOf(";^;");
        j++;
      }
      //records.add(fields);
      serverMessage = serverMessage.substring(recordEndIndex + 7);
      recordEndIndex = serverMessage.indexOf(";^;\n;^;");
      i++;
      j = 0;
    }
    return records;
  }

  static Future<List<List<String>>> fetchData(List<String> parameters) async {
    String serverResponse = await transactWithSite("MeSer", parameters);
    List<List<String>> records = decodeServerMessage(serverResponse);
    return records;
  }

  static Future<List<List<String>>> fetchDataFileMessage(
      List<String> parameters, String base64File) async {
    String serverResponse =
        await transactWithSiteFull("UploadFile", parameters, base64File);
    List<List<String>> records = decodeServerMessage(serverResponse);
    return records;
  }

  static Future<List<String>> getUserInfo() async {
    if (AppParameters.currentUser.length < 4 ||
        AppParameters.currentPassword.length < 4) {
      return ["-3"];
    }
    List<List<String>> _records = await fetchData(
        ["101", AppParameters.currentUser, AppParameters.currentPassword]);
    try {
      if (_records[0][1] == "0")
        return _records[1];
      else
        return ["-1"];
    } catch (e) {
      return ["-2"];
    }
  }
}

class MesUtil {
  static String formatDateTime(DateTime inputDate, int format) {
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
}
