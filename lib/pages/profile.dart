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
  const Profile(this.empId, this.username, this.location,
      {Key key, this.imagePath})
      : super(key: key);
  final String empId;
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
    // north campus
    {
      "latitude": 17.460088835720907,
      "longitude": 78.33429144469663,
      "radius": 100.0,
      "id": "UoH Admin block",
    },
    {
      "latitude": 17.465523085180703,
      "longitude": 78.32763147054699,
      "radius": 15.0,
      "id": "UCESS",
    },
    {
      "latitude": 17.4552911,
      "longitude": 78.3326162,
      "radius": 30.0,
      "id": "SCIS Annex",
    },
    {
      "latitude": 17.455353580081628,
      "longitude": 78.33218325448995,
      "radius": 50.0,
      "id": "SCIS",
    },
    {
      "latitude": 17.455254922666313,
      "longitude": 78.33146588241979,
      "radius": 20.0,
      "id": "Student's Canteen",
    },
    {
      "latitude": 17.456129792411453,
      "longitude": 78.32821012656873,
      "radius": 60.0,
      "id": "Zakir Hussain (UPE)",
    },
    {
      "latitude": 17.454093586886074,
      "longitude": 78.32960817507471,
      "radius": 30.0,
      "id": "DST Auditorium",
    },
    {
      "latitude": 17.456221828477208,
      "longitude": 78.32987851276606,
      "radius": 100.0,
      "id": "Science Complex",
    },
    // white rocks
    {
      "latitude": 17.453543270778734,
      "longitude": 78.32021966064161,
      "radius": 90.0,
      "id": "Aminity Center",
    },
    // south campus
    {
      "latitude": 17.452951251828658,
      "longitude": 78.31541247438054,
      "radius": 50.0,
      "id": "ACRHEM (Advanced Centre of Research in High Energy Materials)",
    },
    {
      "latitude": 17.454029653512475,
      "longitude": 78.31524384291443,
      "radius": 50.0,
      "id": "Center for Nanotechnology",
    },
    {
      "latitude": 17.45397561058677,
      "longitude": 78.31383415174568,
      "radius": 70.0,
      "id": "CIS (College for Integrated Studies)",
    },
    {
      "latitude": 17.454944653657957,
      "longitude": 78.3139295098544,
      "radius": 30.0,
      "id":
          "School of Engineering Science & Technology (Study India Program Building)",
    },
    {
      "latitude": 17.456301490035756,
      "longitude": 78.31518530394179,
      "radius": 84.0,
      "id": "SLS (New)",
    },
  ];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  final SqlDatabaseService _sqlDatabaseService = SqlDatabaseService();
  NotificationService _notificationService;
  StreamSubscription<Position> _geolocatorStream;

  /// Logout function
  Future<void> _logout() async {
    await _sqlDatabaseService.signIn(widget.empId, widget.username, "o");
    await _sqlDatabaseService.logGeoFence(
        widget.empId, widget.username, position, "o");
    _geolocatorStream.cancel();
    _notificationService.scheduleNotification(
      "Exit Campus!",
      "You left the campus premises.",
    );
    Navigator.popUntil(context, ModalRoute.withName('/home'));
    return;
  }

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
    double campusLatitude = 17.456900943260322;
    double campusLongitude = 78.3263732689548;
    double campusRadius = 30000.0;

    /// Not asking location permissions cuz
    /// asked in previous screen

    String oldLoc = "Unknown";
    String newLoc = "Unknown";
    _geolocatorStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      //intervalDuration: Duration(seconds: 15),
    ).listen(
      (Position position) async {
        if (position == null) {
          print('Unknown');
          setState(() {
            this.position = "Unknown";
          });
        } else {
          if (Geolocator.distanceBetween(position.latitude, position.longitude,
                  campusLatitude, campusLongitude) <
              campusRadius) {
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
                    widget.empId, widget.username, oldLoc, "o");
                _notificationService.scheduleNotification(
                  "Exit $oldLoc!",
                  "You just left $oldLoc.",
                );
              } else {
                await _sqlDatabaseService.logGeoFence(
                    widget.empId, widget.username, newLoc, "i");
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
          } else {
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
