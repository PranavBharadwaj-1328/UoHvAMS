import 'dart:io';
import 'package:face_net_authentication/pages/widgets/app_button.dart';
import 'package:flutter/material.dart';
import './db/sqldb.dart';
import '../services/georegion.service.dart';
import '../services/notification.service.dart';
import 'home.dart';
import 'dart:math' as math;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:intl/intl.dart';

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

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  final SqlDatabaseService _sqlDatabaseService = SqlDatabaseService();
  final GeoRegionInitialize _geoRegionInitialize = GeoRegionInitialize();
  NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    _notificationService = NotificationService(flutterLocalNotificationsPlugin);
    _notificationService.notificationInitialize();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
    Geofence.initialize();
    Geofence.requestPermissions();

    _geoRegionInitialize.addGeoRegions();

    await Geofence.startListeningForLocationChanges();
    Geofence.backgroundLocationUpdated.stream.listen((event) async {
      print(event.toString());
      _notificationService.scheduleNotification(
        "You moved significantly",
        "a significant location change just happened.",
      );
    });

    Geofence.startListening(GeolocationEvent.entry, (entry) async {
      print(entry.id);
      _notificationService.scheduleNotification("Entry of a georegion", "Welcome to: ${entry.id}");

      await _sqlDatabaseService.logGeoFence(widget.username, entry.id, "i");
    });

    Geofence.startListening(GeolocationEvent.exit, (entry) async {
      print(entry.id);
      _notificationService.scheduleNotification("Exit of a georegion", "Byebye to: ${entry.id}");

      await _sqlDatabaseService.logGeoFence(widget.username, entry.id, "o");

//      Navigator.push(
//        context,
//        MaterialPageRoute(builder: (context) => MyHomePage()),
//      );
    });

    setState(() {});
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
                          widget.location,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    )
                  ],
                ),
              ),
              AppButton(
                text: "get current location",
                onPressed: (){
                  Geofence.getCurrentLocation().then((coordinate) {
                    _notificationService.scheduleNotification ("Your latitude is ${coordinate.latitude}", "and longitude is ${coordinate.longitude}");
                  });
                },
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
