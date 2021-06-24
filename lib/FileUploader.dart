import 'dart:async';

import 'package:ap_me/AppParameters.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' ;
import 'package:image_picker/image_picker.dart';
 
class FileUploader extends StatefulWidget {
  FileUploader() : super();
 
  final String title = "Upload Image Demo";
 
  @override
  FileUploaderState createState() => FileUploaderState();
}
 
class FileUploaderState extends State<FileUploader> {
  
  //static final String uploadEndPoint = AppParameters.mainSiteURL+;      
  Future<File> file;
  String status = '';
  String base64Image;
  File tmpFile;
  String errMessage = 'Error Uploading Image';
  static String url = AppParameters.mainSiteURL;
  static  String serviceName = "MesServices.asmx";
  static  String operation ="UploadFile";
 static Future<Response> uploadFile(List<String> parameters, String base64File) async {
    String result = "";
   
    Response response ;

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
      for (int i = 0; i < parameters.length; i++)
        soap += "<string>" + parameters[i] + "</string>";
      soap += "</Parameters>";
    }
    if (base64File.length > 0) {
      soap += "<f>";
      soap+= base64File;
      soap += "</f>";
    }
    soap += "</$operation>";
    soap += "</soap:Body>";
    soap += "</soap:Envelope>";


    try {
        response = await post(
        url + serviceName,
        headers: headers,
        body: utf8.encode(soap),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Check Connection");
      }
      );        
     /* if (response.statusCode == 200) {
        //successful
        int index = response.body.indexOf("<" + operation + "Result>");
        if (index > 0) {
          result = response.body.substring(index + operation.length + 8);
          index = result.indexOf("</" + operation + "Result>");
          result = result.substring(0, index);
        } else {}
      } else {
        //return ("Error:" + response.statusCode.toString());
      }*/
    } catch (e) {
      print("O my god site is down : " + e.toString());
    }
    return response;
    //return result;
  }


  chooseImage() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.gallery);
    });
    setStatus('');
  }
 
  setStatus(String message) {
    setState(() {
      status = message;
    });
  }
 
  startUpload() {
    setStatus('Uploading Image...');
    if (null == tmpFile) {
      setStatus(errMessage);
      return;
    }
    String fileName = tmpFile.path.split('/').last;
    upload(fileName);
  }
 
  upload(String fileName) async{

   Response result = await uploadFile([
      fileName,
      AppParameters.currentUser,
      AppParameters.currentPassword,
      AppParameters.currentFriend,
      "File Message"
    ], base64Image);
    /*post(uploadEndPoint, body: {
      "image": base64Image,
      "name": fileName,
    }).then((result) {*/
     String output = errMessage;
     if(result.statusCode == 200 )
    {int index = result.body.indexOf("<" + operation + "Result>");
        if (index > 0) {
          output = result.body.substring(index + operation.length + 8);
          index = output.indexOf("</" + operation + "Result>");
          output = output.substring(0, index);
          if(output.indexOf("501;^;0;^;")>=0)
            output="OK Sent";
        } else {
          output = "Error!";
        }
    }
      setStatus(output);
   /* }).catchError((error) {
      setStatus(error);
    });*/
  }
 
  Widget showImage() {
    return FutureBuilder<File>(
      future: file,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          tmpFile = snapshot.data;
          base64Image = base64Encode(snapshot.data.readAsBytesSync());
          return Flexible(
            child: Image.file(
              snapshot.data,
              fit: BoxFit.contain,
            ),
          );
        } else if (null != snapshot.error) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return const Text(
            'No Image Selected',
            textAlign: TextAlign.center,
          );
        }
      },
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload File"),
      ),
      body: Container(
        padding: EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            
            showImage(),
           
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   OutlineButton(
                onPressed: chooseImage,
                child: Text('Choose Image'),
              ),
                  SizedBox(
                    width: 10.0,
                  ),
                  OutlineButton(
                    onPressed: startUpload,
                    child: Text('Upload Image'),
                  ),                  
                ],
              ),
            ),
            Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
                fontSize: 20.0,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}