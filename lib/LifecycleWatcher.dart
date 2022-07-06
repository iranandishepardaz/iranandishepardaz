import 'AppParameters.dart';
import 'package:flutter/widgets.dart';

class LifecycleWatcher extends StatefulWidget {
  // const LifecycleWatcher({ key }) : super(key: key);

  @override
  State<LifecycleWatcher> createState() => _LifecycleWatcherState();
}

class _LifecycleWatcherState extends State<LifecycleWatcher>
    with WidgetsBindingObserver {
  late AppLifecycleState _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      switch (state) {
        case AppLifecycleState.paused:
          // AppParameters.pausedTime = DateTime.now();
          break;
        case AppLifecycleState.resumed:
          /*  AppParameters.pausedSeconds = DateTime
              .now()
              .difference(AppParameters.pausedTime)
              .inSeconds;*/
          if (AppParameters.pausedSeconds >
              AppParameters.pausePermittedSeconds) {
            Navigator.of(context).pop();
          } else {
            strMessage +=
                "\nResume seconds: " + AppParameters.pausedSeconds.toString();
          }
          break;

        case AppLifecycleState.inactive:

        case AppLifecycleState.detached:
      }
      _lastLifecycleState = state;
    });
  }

  String strMessage = "";

  @override
  Widget build(BuildContext context) {
    if (_lastLifecycleState == null)
      strMessage += '\nEmpty lifecycle.';
    else
      strMessage += '\nlifecycle: $_lastLifecycleState.';
    return Text(
      strMessage,
      textScaleFactor: .4,
    );
  }
}
