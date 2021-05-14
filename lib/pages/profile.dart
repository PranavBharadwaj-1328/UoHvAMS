import 'dart:io';
import 'dart:math';

import 'package:face_net_authentication/pages/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home.dart';
import 'dart:math' as math;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:intl/intl.dart';

// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Profile extends StatefulWidget {
  const Profile(this.username, this.location, {Key key, this.imagePath})
      : super(key: key);
  final String username;
  final String location;
  final String imagePath;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _platformVersion = 'Unknown';
  double _latitude = 17.4301783;
  double _longitude = 78.5421611;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initPlatformState();

// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS =
        IOSInitializationSettings(onDidReceiveLocalNotification: null);
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: null,
    );
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
    Geofence.initialize();
    Geofence.requestPermissions();

    // Geofence.getCurrentLocation().then((coordinate) {
    //   print(
    //       "Your latitude is ${coordinate.latitude} and longitude ${coordinate.longitude}");
    // });

    Geofence.startListening(GeolocationEvent.entry, (entry) async {
      print(entry.id);
      scheduleNotification("Entry of a georegion", "Welcome to: ${entry.id}");

      // TODO send to db
    });

    Geofence.startListening(GeolocationEvent.exit, (entry) async {
      print(entry.id);
      scheduleNotification("Exit of a georegion", "Byebye to: ${entry.id}");

      // TODO send to db
    });

    Geolocation sirLocation = Geolocation(
        latitude: _latitude, longitude: _longitude, radius: 10, id: "NKS home");

    // rohan home for demo reasons
    Geolocation location = Geolocation(
      latitude: 17.5036619,
      longitude: 78.3568218,
      radius: 10.0,
      id: "Rohan Home",
    );

    Geofence.addGeolocation(location, GeolocationEvent.entry).then((onValue) {
    // Geofence.addGeolocation(sirLocation, GeolocationEvent.entry).then((onValue) {
      print("great success");
      scheduleNotification(
        "Georegion added",
        "Your geofence has been added!",
      );
    }).catchError((onError) {
      print("great failure");
    });

    Geofence.startListeningForLocationChanges();
    Geofence.backgroundLocationUpdated.stream.listen((event) async {
      print(event.toString());
      scheduleNotification(
        "You moved significantly",
        "a significant location change just happened.",
      );
    });

    setState(() {});
  }
  //
  // void scheduleNotification(String title, String subtitle) {
  //   print("scheduling one with $title and $subtitle");
  //   var rng = new Random();
  //   Future.delayed(Duration(seconds: 5)).then((result) async {
  //     var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //         'your channel id', 'your channel name', 'your channel description',
  //         importance: Importance.high,
  //         priority: Priority.high,
  //         ticker: 'ticker');
  //     var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  //     var platformChannelSpecifics = NotificationDetails(
  //         android: androidPlatformChannelSpecifics,
  //         iOS: iOSPlatformChannelSpecifics);
  //     await flutterLocalNotificationsPlugin.show(
  //         rng.nextInt(100000), title, subtitle, platformChannelSpecifics,
  //         payload: 'item x');
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final double mirror = math.pi;
    return Scaffold(
      backgroundColor: Color(0XFFFFFFFFF),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(File(widget.imagePath)),
                      ),
                    ),
                    margin: EdgeInsets.all(20),
                    width: 50,
                    height: 50,
                    // child: Transform(
                    //     alignment: Alignment.center,
                    //     child: FittedBox(
                    //       fit: BoxFit.cover,
                    //       child: Image.file(File(imagePath)),
                    //     ),
                    //     transform: Matrix4.rotationY(mirror)),
                  ),
                  Text(
                    'Hi ' + widget.username + '!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFFEFFC1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.done,
                      size: 30,
                      color: Color(0xFF64DD17),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Your attendance has been registered at the following location: ' +
                          widget.location,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    )
                  ],
                ),
              ),
              Column(
                children: [
                  ElevatedButton(
                    child: Text("Listen to background updates"),
                    onPressed: () {
                      Geofence.startListeningForLocationChanges();
                      Geofence.backgroundLocationUpdated.stream.listen((event) {
                        scheduleNotification("You moved significantly",
                            "a significant location change just happened.");
                      });
                    },
                  ),
                  ElevatedButton(
                    child: Text("Stop listening to background updates"),
                    onPressed: () {
                      Geofence.stopListeningForLocationChanges();
                    },
                  ),
                  ElevatedButton(
                    child: Text("Checking to see if notifications are working"),
                    onPressed: () {
                      scheduleNotification("Demo",
                            "demo message");
                    },
                  ),
                ],
              ),
              Spacer(),
              AppButton(
                text: "Leave",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
                },
                icon: Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                color: Color(0xFFFF6161),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );


  }
  void scheduleNotification(String title, String subtitle) {
    print("scheduling one with $title and $subtitle");
    var rng = new Random();
    Future.delayed(Duration(seconds: 5)).then((result) async {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'your channel id', 'your channel name', 'your channel description',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker');
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          rng.nextInt(100000), title, subtitle, platformChannelSpecifics,
          payload: 'item x');
    });
  }
}
