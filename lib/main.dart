import 'package:shadoweet/chat.dart';
import 'package:shadoweet/dog_watch.dart';
import 'package:flutter/material.dart';

void main() async {
  // 初期化
  //SharedPreferences prefs = await SharedPreferences.getInstance();
  //// user_id設定
  //if (prefs.getString('user_id').length ==  0 ?? false) {
  //  String uuid = new Uuid().v4();
  //  prefs.setString('user_id', uuid);
  //}
  //runApp(new MyApp(hasRegistered: prefs.getBool("hasRegistered") ?? false));
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  //const MyApp({Key key, this.hasRegistered}) : super(key: key);
  const MyApp({Key key}) : super(key: key);
  //final bool hasRegistered;

  @override
  Widget build(BuildContext context) {
    // This widget is the root of your application.
    Widget initScreen;
    // if (!hasRegistered) {
    //   initScreen = new ChatScreen();
    // } else {
    //   initScreen = new ChatScreen();
    // }
    initScreen = new MainPager(title: "Main画面");

    return new MaterialApp(
      title: "app",
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

class MainPager extends StatefulWidget {
  MainPager({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MainPager createState() => new _MainPager();
}

class _MainPager extends State<MainPager> with TickerProviderStateMixin {
  final List<Tab> _tabs = <Tab>[
    new Tab(text: "tab1"),
    new Tab(text: "tab2"),
    new Tab(text: "わんこの部屋"),
  ];
  final List<Widget> _pages = <Widget>[
    new ChatScreen(),
    new ChatScreen(),
    new DogWatchScreen(),
  ];

  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: _tabs.length, vsync: this, initialIndex: 1);
    tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(_tabs[tabController.index].text)
      ),
      body: new Column(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        children: <Widget>[
          new Flexible(
              child: new TabBarView(
                children: _pages,
                controller: tabController,
                physics: new NeverScrollableScrollPhysics(),
              ),
          ),
          new TabBar(
            tabs: _tabs,
            isScrollable: false,
            controller: tabController,
            labelColor: Colors.black
          )
        ]
      ),
    );
  }
}
