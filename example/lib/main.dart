import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bugly/flutter_bugly.dart';

void main() async{
  runApp(const MyApp());
  await FlutterBugly.instance.initCrashReport(
    appIdIOS: "a4af0b7797",
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion = "";
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              SizedBox(height: 30,),
              InkWell(
                onTap: (){
                  try{
                    throw Exception("csss");
                  } catch (e, trace) {
                    print(e.toString());
                    FlutterBugly.instance.postException(error: e.toString(), stackTrace: trace);
                  }
                  // FlutterBugly.instance.testIOSCrash();
                  // FlutterBugly.instance.putUserData(value: "testValue",key: "testKey");
                },
                child: Container(
                  height: 50,
                  color: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
                  child: Center(
                    child: Text(
                      "测试 ios 异常"
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
