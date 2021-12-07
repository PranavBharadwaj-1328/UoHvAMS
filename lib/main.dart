import 'package:face_net_authentication/pages/home.dart';
import 'pages/sign-in.dart';
import 'pages/sign-up.dart';
import 'pages/profile.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => MyHomePage(),
        // '/signIn': (context) => SignIn(),
        // '/signUp': (context) => SignUp(),
        // '/profile': (context) => Profile()
      },
      home: IntroPage(),

      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
