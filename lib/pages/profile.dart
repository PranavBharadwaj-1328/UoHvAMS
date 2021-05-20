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
  const Profile(this.username, this.geoRegion, {Key key, this.imagePath})
      : super(key: key);
  final String username;
  // final String location;
  final String imagePath;

  // TODO
  final Map<String, dynamic> geoRegion;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _platformVersion = 'Unknown';
  String position = "";

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  final SqlDatabaseService _sqlDatabaseService = SqlDatabaseService();
  NotificationService _notificationService;

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

    // StreamSubscription<Position> positionStream =
    Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      // timeLimit: Duration(seconds: 2),
    ).listen(
      (Position position) {
        if (position == null) {
          print('Unknown');
        } else {
          print(
            position.latitude.toString() + ', ' + position.longitude.toString(),
          );
          setState(() {
            this.position = position.latitude.toString() +
                ', ' +
                position.longitude.toString();
          });

          if (Geolocator.distanceBetween(position.latitude, position.longitude,
                  widget.geoRegion["latitude"], widget.geoRegion["longitude"]) >
              widget.geoRegion["radius"]) {
            _sqlDatabaseService.logGeoFence(
                widget.username, widget.geoRegion["id"], "o");

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          }

        }
      },
    );

    //
    // void _entry(Map<String, dynamic> geoRegion) {
    //   /// push into logs later
    //
    //
    // }

    // return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();

    _notificationService = NotificationService(flutterLocalNotificationsPlugin);
    _notificationService.notificationInitialize();
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
                          widget.geoRegion["id"],
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 10,),
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
