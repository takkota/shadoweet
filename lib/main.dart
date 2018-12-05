import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shadoweet/provider/BlocProviderUtil.dart';
import 'dart:core';

const String AD_MOB_APP_ID = 'app_id';

void main() async {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  //const MyApp({Key key, this.hasRegistered}) : super(key: key);
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This widget is the root of your application.
    Widget initScreen;
    initScreen = new DefaultAssetBundle(bundle: rootBundle, child: BlocProviderUtil.buildDogWatchScreen());
    return  new MaterialApp(
      title: "DogChat",
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: initScreen,
      // routes: <String, WidgetBuilder> {"aa": bb} と同じ
      //routes: <String, WidgetBuilder> {
      //  "/chat": (BuildContext context) => initScreen
      //}
    );
  }
}

