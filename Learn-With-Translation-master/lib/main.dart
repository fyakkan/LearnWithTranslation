import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

import 'dart:isolate';
import 'dart:ui';

import 'package:learn_with_translation/shared_preferences/sign_in_data.dart';
import 'package:learn_with_translation/models/constants.dart';
import 'package:learn_with_translation/screens/create_account.dart';
import 'package:learn_with_translation/screens/log_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learn_with_translation/sqflite/db_helper.dart';
import 'package:provider/provider.dart';

import 'models/user_manager_state.dart';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:learn_with_translation/services//local_notifications.dart'
    as notify;

// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

// /// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SignInData.initialize();

  // craete database:
  DatabaseHelper.instance.database;

  // Register the UI isolate's SendPort to allow for communication from the
  // background isolate.
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );

  notify.initNotifications();

  AndroidAlarmManager.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({
    Key? key,
  }) : super(key: key);

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserManagerState>(
            create: (context) => UserManagerState(),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(primaryColor: purple, backgroundColor: background),
          home: FutureBuilder(
            future: _initialization,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Something went wrong"));
              } else if (snapshot.hasData) {
                return const MyHomePage();
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();

  // // The background
  static SendPort? uiSendPort;

  Future<void> showNotification(data) async {
    DateTime now = DateTime.now().toUtc().add(const Duration(seconds: 1));

    await notify.singleNotification(
      now,
      "Hello ",
      "This is invitation message from LearnWithTranslation\n"
          "Come and take a quiz!",
      1,
    );
  }

  // The callback for our alarm
  static Future<void> callback() async {
    print('Alarm fired!');
    // // This will be null if we're running in the background.
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send("hi");
  }

  @override
  void initState() {
    super.initState();

    initConnectivity();

    port.listen((data) async => await showNotification(data));

    runAlarm();
  }

  void runAlarm() async {
    await AndroidAlarmManager.periodic(
      const Duration(seconds: 8),
      0,
      callback,
      rescheduleOnReboot: true,
      exact: true,
      wakeup: true,
    );
    print("OK");
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        colors: [
          Colors.purple,
          Colors.deepPurple,
          Colors.white,
          Colors.deepPurple,
          Colors.purple
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors
            .transparent, //const Color.fromRGBO(250, 240, 240, 1.0),//Theme.of(context).backgroundColor,
        body: SingleChildScrollView(
          // SingleChildScrollView--> To Solve: when coming back from Create Account, the keyboard cause error.
          child: Center(
              child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: buildLogoWithinBox(size),
              ),
              const SizedBox(
                height: 25,
              ),
              buildWelcomes(size),
              const SizedBox(
                height: 25,
              ),
              buildCreateAccountButton(context, size),
              const SizedBox(
                height: 25,
              ),
              buildLogInButton(context, size),
              const SizedBox(
                height: 15,
              ),
              Center(
                  child: Text(
                      'Connection Status: ${_connectionStatus.toString()}')),
              const SizedBox(
                height: 10,
              ),
            ],
          )),
        ),
      ),
    );
  }

  Widget buildLogoWithinBox(size) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        image: const DecorationImage(
          image: ExactAssetImage(
            'assets/images/logo.png',
          ),
          fit: BoxFit.cover,
        ),
        border: Border.all(
          color: Colors.black,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget buildWelcomes(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20.0, 5, 20, 20),
          padding: const EdgeInsets.all(3.0),
          width: size.width * 0.32,
          height: size.height * 0.12,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(100),
                topLeft: Radius.circular(100),
                topRight: Radius.circular(100)),
            border: Border.all(color: Colors.black, width: 5),
          ),
          child: const Center(
              child: Text(
            "Welcome",
            style: TextStyle(
              color: purple,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          )),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(20.0, 5, 20, 20),
          padding: const EdgeInsets.all(3.0),
          width: size.width * 0.32,
          height: size.height * 0.12,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(100),
                topLeft: Radius.circular(100),
                topRight: Radius.circular(100)),
            border: Border.all(color: Colors.black, width: 5),
          ),
          child: const Center(
              child: Text(
            "Hoşgeldiniz",
            style: TextStyle(
              color: purple,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          )),
        ),
      ],
    );
  }

  Widget buildCreateAccountButton(BuildContext context, Size size) {
    return ElevatedButton(
      child: const Text(
        "Create Account",
        style: TextStyle(fontSize: 28, color: Color(0xFFAA00FF)),
      ),
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        fixedSize: Size(size.width * .7, size.height * .1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        side: const BorderSide(
            width: 2, color: Colors.black, style: BorderStyle.solid),
        elevation: 5,
      ),
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CreateAccount()));
      },
    );
  }

  Widget buildLogInButton(BuildContext context, Size size) {
    return ElevatedButton(
      child: const Text(
        "Log in",
        style: TextStyle(
          fontSize: 28,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: const Color(
            0xFF6200EE), //Theme.of(context).primaryColor,//const Color(0xFFAA00FF), // Colors.deepPurple.shade400
        fixedSize: Size(size.width * .7, size.height * .1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        elevation: 10,
      ),
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const LogIn()));
      },
    );
  }
}
