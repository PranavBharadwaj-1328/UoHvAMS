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

class Profile extends StatefulWidget {
  /// doubt doubt
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
      "radius": 20.0,
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
    },
    {
      "latitude": 17.402356305545407,
      "longitude": 78.44378929717998,
      "radius": 50.0,
      "id": "Salman sir",
    },
    {
      "latitude": 17.487547926446105,
      "longitude": 78.31434161006122,
      "radius": 50.0,
      "id": "Satish sir",
    },
  ];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  final SqlDatabaseService _sqlDatabaseService = SqlDatabaseService();
  NotificationService _notificationService;

  /// Logout function
  Future<void> _logout() async {
    await _sqlDatabaseService.signIn(widget.username, "o");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
    return;
  }

  /// LIVE LOCATION AND GEOFENCING FUNCTION

  void _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    double campus_latitude = 17.456900943260322;
    double campus_longitude = 78.3263732689548;
    double campus_radius = 30000.0;
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
      intervalDuration: Duration(seconds: 15),
    ).listen(
      (Position position) async {
        if (position == null) {
          print('Unknown');
          setState(() {
            this.position = "Unknown";
          });
        } else {
          if (Geolocator.distanceBetween(position.latitude, position.longitude,
                  campus_latitude, campus_longitude) <
              campus_radius) {
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
                await _sqlDatabaseService.logGeoFence(
                    widget.username, oldLoc, "o");
                _notificationService.scheduleNotification(
                  "Exit $oldLoc!",
                  "You just left $oldLoc.",
                );
              } else {
                await _sqlDatabaseService.logGeoFence(
                    widget.username, newLoc, "i");
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
          else{
            _logout();
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
                          (widget.location == null
                              ? "Unknown location"
                              : widget.location["id"]),
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
                  _logout();
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
