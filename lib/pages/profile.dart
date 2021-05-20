import 'dart:async';
import 'dart:io';
import 'package:face_net_authentication/pages/widgets/app_button.dart';
import 'package:flutter/material.dart';
import './db/sqldb.dart';
import '../services/notification.service.dart';
import 'home.dart';
import 'dart:math' as math;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class Profile extends StatefulWidget {
  /// doubt doubt
  // const Profile(this.username, this.location, this.geoRegion {Key key, this.imagePath})
  const Profile(this.username, this.location, {Key key, this.imagePath})
      : super(key: key);
  final String username;
  final String imagePath;
  final Map<String, dynamic> location;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _platformVersion = 'Unknown';
  String position = "Unknown";
  List<Map<String, dynamic>> geoRegions = [
    {
      "latitude": 17.4301783,
      "longitude": 78.5421611,
      "radius": 25.0,
      "id": "NKS home",
    },
    {
      "latitude": 17.397909,
      "longitude": 78.5199671,
      "radius": 5.0,
      "id": "PB Home",
    },
    {
      "latitude": 17.503565,
      "longitude": 78.356778,
      "radius": 20.0,
      "id": "Rohan Home",
    },
    {
      "latitude": 17.504054,
      "longitude": 78.357531,
      "radius": 20.0,
      "id": "Rohan Neighbour",
    }
  ];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  final SqlDatabaseService _sqlDatabaseService = SqlDatabaseService();
  NotificationService _notificationService;


  /// LIVE LOCATION AND GEOFENCING FUNCTION

  void _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    String oldLoc = "Unknown";
    String newLoc = "Unknown";
    Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      // timeLimit: Duration(seconds: 2),
    ).listen(
      (Position position) async {
        if (position == null) {
          print('Unknown');
          setState(() {
            this.position = "Unknown";
          });
        } else {

          bool flag = true;
          for (Map<String, dynamic> geoRegion in geoRegions) {
            if (Geolocator.distanceBetween(
                position.latitude,
                position.longitude,
                geoRegion["latitude"],
                geoRegion["longitude"]) <
                geoRegion["radius"]) {
              newLoc = geoRegion["id"];
              flag = false;
              break;
            }
          }
          if (flag) {
            newLoc = "Unknown";
          }

          if (oldLoc != newLoc) {
            if (newLoc == "Unknown") {
              await _sqlDatabaseService.logGeoFence(widget.username, oldLoc, "o");
              _notificationService.scheduleNotification(
                "Exit $oldLoc!",
                "You just left $oldLoc.",
              );
            } else {
              await _sqlDatabaseService.logGeoFence(widget.username, newLoc, "i");
              _notificationService.scheduleNotification(
                "Entered $newLoc!",
                "Your attendance at $newLoc has been noted!",
              );
            }
            oldLoc = newLoc;
            setState(() {
              this.position = newLoc;
            });
          }
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _notificationService = NotificationService(flutterLocalNotificationsPlugin);
    _notificationService.notificationInitialize();

    _determinePosition();
  }

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
                      'Your attendance has been registered at ' +
                          (widget.location == null ? "Unknown location" : widget.location["id"]),
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Your current location: ' + this.position,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    )
                  ],
                ),
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
}
