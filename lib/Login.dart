import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class Login extends StatefulWidget {
  const Login() : super();

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _canCheckBiometric = false;
  List<BiometricType> _availableBiometrics = [];
  String _autherized = "Not Autherized";
  LocalAuthentication auth = LocalAuthentication();

  Future<void> _checkBiometrics() async {
    bool canCheckBiometric = false;
    try {
      canCheckBiometric = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print("Error: $e");
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometric = canCheckBiometric;
    });
  }

  Future<void> _getAvailableBiometric() async {
    List<BiometricType> availableBiometrics = [];
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;

    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: "Scanyour Finger",
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
    setState(() {
      _autherized =
          authenticated ? "Autherized success" : "Failed to Autherize";
      print(_autherized);
    });
  }

  @override
  void initState() {
    _checkBiometrics();
    _getAvailableBiometric();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.grey[700],
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Text(
              "Login",
              style: TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            )),
            Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/fingerprint.png',
                      width: 120,
                    ),
                    Text(
                      "Authenticate with Fingerprint",
                      style: TextStyle(color: Colors.white, height: 1.5),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      width: double.infinity,
                      child: RaisedButton(
                        elevation: 0.0,
                        color: Colors.lightBlue[300],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        onPressed: _authenticate,
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 24),
                            child: Text(
                              "Authenticate",
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    ));
  }
}
