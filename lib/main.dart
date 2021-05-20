import 'package:face_net_authentication/pages/db/database.dart';
import 'package:face_net_authentication/pages/home.dart';
import 'pages/intro.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DataBaseService _dataBaseService = DataBaseService();
  bool loading = true;
  bool dbExists;

  @override
  void initState() {
    super.initState();
    _startUp();
  }

  _startUp() async {
    bool check = await _dataBaseService.checkDB();

    setState(() {
      this.dbExists = check;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: MyHomePage(),
      home: !loading
          ? dbExists
              ? MyHomePage()
              : IntroPage()
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
