
import 'dart:io';
import 'package:face_net_authentication/pages/db/database.dart';
import 'package:face_net_authentication/pages/models/user.model.dart';
import 'package:face_net_authentication/pages/profile.dart';
import 'package:face_net_authentication/pages/widgets/app_button.dart';
import 'package:face_net_authentication/services/camera.service.dart';
import 'package:face_net_authentication/services/facenet.service.dart';
import '../db/sqldb.dart';
import 'package:flutter/material.dart';
import '../home.dart';
import 'app_text_field.dart';
import 'package:geolocator/geolocator.dart';

class AuthActionButton extends StatefulWidget {
  AuthActionButton(this._initializeControllerFuture,
      {Key key, @required this.onPressed, @required this.isLogin, this.reload});
  final Future _initializeControllerFuture;
  final Function onPressed;
  final bool isLogin;
  final Function reload;
  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  /// service injection
  final FaceNetService _faceNetService = FaceNetService();
  final DataBaseService _dataBaseService = DataBaseService();
  final CameraService _cameraService = CameraService();
  final SqlDatabaseService _sqlDatabaseService = SqlDatabaseService();

  final TextEditingController _userTextEditingController =
      TextEditingController(text: '');
  final TextEditingController _passwordTextEditingController =
      TextEditingController(text: '');
  final TextEditingController _userIdEditingController =
      TextEditingController(text: '');
  final TextEditingController _userEmailEditingController =
      TextEditingController(text: '');
  User predictedUser;

  List<Map<String, dynamic>> geoRegions = [
      {
        "latitude": 17.4301783,
        "longitude": 78.5421611,
        "radius": 20.0,
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
      }
    ];

  /// GET LOCATION USING GEO LOCATOR
  Future<Map<String, dynamic>> getCurrentLocation() async {
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

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    var lati = position.latitude;
    var longi = position.longitude;

    for (Map<String, dynamic> geoRegion in geoRegions)
    {
      if (Geolocator.distanceBetween(lati, longi ,geoRegion["latitude"],geoRegion["longitude"]) < geoRegion["radius"]) {
        _sqlDatabaseService.logGeoFence(this.predictedUser.user, geoRegion["id"], "i");

        // TODO clean this
        return (geoRegion);
      }
    }

    return null;
    // return ("$lati:$longi");
  }

  Future _signUp(context) async {
    /// gets predicted data from facenet service (user face detected)
    List predictedData = _faceNetService.predictedData;
    String user = _userTextEditingController.text;
    String password = _passwordTextEditingController.text;
    String email = _userEmailEditingController.text;
    String empid = _userIdEditingController.text;

    /// creates a new user in the 'database'
    await _dataBaseService.saveData(user, password, predictedData);

    /// SIGN UP
    await _sqlDatabaseService.signUp(empid, user, email, password);

    /// resets the face stored in the face net sevice
    this._faceNetService.setPredictedData(null);
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => MyHomePage()));
  }

  Future _signIn(context) async {
    String password = _passwordTextEditingController.text;

    if (this.predictedUser.password == password) {

      /// fetching data from geolocator
      // var loc = await getCurrentLocation();
      var geoRegion = await getCurrentLocation();
      // print(loc);
      // var lat = loc.split(":")[0];
      // var lon = loc.split(":")[1];

      /// SIGN IN
      /// DOUBT DOUBT
      // await _sqlDatabaseService.signIn(this.predictedUser.user, lon, lat);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => Profile(
            this.predictedUser.user,
            // loc,
            geoRegion,
            imagePath: _cameraService.imagePath,
          ),
        ),
      );
    }
    else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Wrong password!'),
          );
        },
      );
    }
  }

  String _predictUser() {
    String userAndPass = _faceNetService.predict();
    return userAndPass ?? null;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          await widget._initializeControllerFuture;
          // onShot event (takes the image and predict output)
          bool faceDetected = await widget.onPressed();

          if (faceDetected) {
            if (widget.isLogin) {
              var userAndPass = _predictUser();
              if (userAndPass != null) {
                this.predictedUser = User.fromDB(userAndPass);
              }
            }
            PersistentBottomSheetController bottomSheetController =
                Scaffold.of(context)
                    .showBottomSheet((context) => signSheet(context));

            bottomSheetController.closed.whenComplete(() => widget.reload());
          }
        } catch (e) {
          // If an error occurs, log the error to the console.
          print(e);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFF0F0BDB),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CAPTURE',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.camera_alt, color: Colors.white)
          ],
        ),
      ),
    );
  }

  signSheet(context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.isLogin && predictedUser != null
              ? Container(
                  padding: EdgeInsets.only(top: 10.0, bottom: 30.0),
                  child: Text(
                    'Welcome back, ' + predictedUser.user + '!',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : widget.isLogin
                  ? Container(
                      child: Text(
                      'User not found 😞',
                      style: TextStyle(fontSize: 20),
                    ))
                  : Container(),
          Container(
            child: Column(
              children: [
                !widget.isLogin
                    ? Column(
                        children: [
                          Text(
                            'Hi!',
                            style: TextStyle(
                              fontSize: 25.0,
                            ),
                          ),
                          SizedBox(height: 20),
                          AppTextField(
                            controller: _userTextEditingController,
                            labelText: "Your Name",
                          ),
                          SizedBox(height: 10),
                          AppTextField(
                            controller: _userIdEditingController,
                            labelText: "Employee ID",
                          ),
                          SizedBox(height: 10),
                          AppTextField(
                            controller: _userEmailEditingController,
                            labelText: "Your Email",
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                      )
                    : Container(),
                SizedBox(height: 10),
                widget.isLogin && predictedUser == null
                    ? Container()
                    : AppTextField(
                        controller: _passwordTextEditingController,
                        labelText: "Password",
                        isPassword: true,
                      ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                widget.isLogin && predictedUser != null
                    ? AppButton(
                        text: 'LOGIN',
                        onPressed: () async {
                          _signIn(context);
                        },
                        icon: Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                      )
                    : !widget.isLogin
                        ? AppButton(
                          text: 'SIGN UP',
                          onPressed: () async {
                            await _signUp(context);
                          },
                          icon: Icon(
                            Icons.person_add,
                            color: Colors.white,
                          ),
                        )
                        : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
