// import 'dart:html';

import 'package:face_net_authentication/pages/db/database.dart';
import 'package:face_net_authentication/pages/models/user.model.dart';
import 'package:face_net_authentication/pages/profile.dart';
import 'package:face_net_authentication/pages/widgets/app_button.dart';
import 'package:face_net_authentication/pages/widgets/registration_steps.dart';
import 'package:face_net_authentication/services/camera.service.dart';
import 'package:face_net_authentication/services/facenet.service.dart';
import 'package:face_net_authentication/pages/db/sqldb.dart';
import 'package:flutter/material.dart';
import 'package:face_net_authentication/pages/widgets/app_text_field.dart';
import 'package:geolocator/geolocator.dart';

class AuthActionButton extends StatefulWidget {
  AuthActionButton(this._initializeControllerFuture,
      {Key key,
      @required this.onPressed,
      @required this.isLogin,
      this.reload,
      @required this.captureButtonLoading});
  final Future _initializeControllerFuture;
  final Function onPressed;
  final bool isLogin;
  final Function reload;
  final bool captureButtonLoading;
  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  /// service injection
  final FaceNetService _faceNetService = FaceNetService();
  final DataBaseService _dataBaseService = DataBaseService();
  final CameraService _cameraService = CameraService();
  final SqlDatabaseService _sqlDatabaseService = SqlDatabaseService();

  final TextEditingController userTextEditingController =
      TextEditingController(text: '');
  final TextEditingController passwordTextEditingController =
      TextEditingController(text: '');
  final TextEditingController userIdEditingController =
      TextEditingController(text: '');
  final TextEditingController userEmailEditingController =
      TextEditingController(text: '');

  PersistentBottomSheetController bottomSheetController;
  User predictedUser;
  String lat;
  String lon;
  bool buttonLoading = false;

  List<Map<String, dynamic>> geoRegions = [
    {
      "latitude": 17.456900943260322,
      "longitude": 78.3263732689548,
      "radius": 30000.0,
      "id": "Campus",
    },
  ];

  /// GET LOCATION USING GEO LOCATOR
  Future<Map<String, dynamic>> getCurrentLocation(BuildContext context) async {
    LocationPermission permission;

    // checking app permissions to access location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Allow location permission'),
              content: Text(
                  'Location services were denied. To continue, please allow permission to access location'),
              actions: <Widget>[
                TextButton(
                  onPressed: () async => {
                    await Geolocator.openAppSettings(),
                    Navigator.pop(context, 'Ok'),
                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          },
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');

      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Allow location permission'),
            content: Text(
                'To continue, please allow permission to access location. This will make it easier to mark your attendance'),
            actions: <Widget>[
              TextButton(
                onPressed: () async => {
                  await Geolocator.openAppSettings(),
                  Navigator.pop(context, 'Open settings'),
                },
                child: const Text('Open settings'),
              ),
            ],
          );
        },
      );
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    var lati = position.latitude;
    var longi = position.longitude;
    lat = lati.toString();
    lon = longi.toString();
    for (Map<String, dynamic> geoRegion in geoRegions) {
      if (Geolocator.distanceBetween(
              lati, longi, geoRegion["latitude"], geoRegion["longitude"]) <
          geoRegion["radius"]) {
        return (geoRegion);
      }
    }

    return null;
  }

  changeButtonLoadingState(bool value) {
    bottomSheetController.setState(() {
      buttonLoading = value;
    });
  }

  Future _signUp(context) async {
    /// gets predicted data from facenet service (user face detected)
    List predictedData = _faceNetService.predictedData;
    String user = userTextEditingController.text;
    String password = passwordTextEditingController.text;
    String email = userEmailEditingController.text;
    String empid = userIdEditingController.text;

    if (user == '' || password == '' || email == '' || empid == '') {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Please fill in all the fields!'),
          );
        },
      );
      return;
    }

    /// creates a new user in the 'database'
    await _dataBaseService.saveData(empid, user, password, predictedData);

    // TODO primary key???

    /// SIGN UP
    try {
      await _sqlDatabaseService.signUp(empid, user, email, password);
    } catch (e) {
      print(e.message);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Employee id already exists!'),
          );
        },
      );
      return;
    }

    /// resets the face stored in the face net service
    this._faceNetService.setPredictedData(null);
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  Future _signIn(context) async {
    String password = passwordTextEditingController.text;
    var geoRegion = await getCurrentLocation(context);
    if (geoRegion == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Not in campus!'),
          );
        },
      );
    } else {
      if (this.predictedUser.password == password) {
        await _sqlDatabaseService.signIn(
            this.predictedUser.empId, this.predictedUser.user, "i");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => Profile(
              this.predictedUser.empId,
              this.predictedUser.user,
              geoRegion,
              imagePath: _cameraService.imagePath,
            ),
          ),
        );
      } else {
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

            bottomSheetController = Scaffold.of(context)
                .showBottomSheet((context) => signSheet(context));

            bottomSheetController.closed.whenComplete(() => widget.reload());
          }
        } catch (e) {
          // If an error occurs, log the error to the console.
          print(e);
        }
      },
      child: widget.captureButtonLoading
          ? CircularProgressIndicator()
          : Container(
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
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.isLogin && predictedUser != null
                // Headers
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
                        ),
                      )
                    : Container(
                        child: Text(
                          'Hi!',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),

            SizedBox(height: 10),

            // Body
            Container(
              child: Column(
                children: [
                  widget.isLogin && predictedUser != null
                      ? AppTextField(
                          controller: passwordTextEditingController,
                          labelText: "Password",
                          isPassword: true,
                        )
                      : Container(),
                  !widget.isLogin
                      ? RegistrationSteps(userTextEditingController, passwordTextEditingController, userEmailEditingController, userIdEditingController)
                      : Container(),
                ],
              ),
            ),

            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),

            // button
            widget.isLogin && predictedUser != null
                ? buttonLoading
                    ? CircularProgressIndicator()
                    : AppButton(
                        text: 'LOGIN',
                        onPressed: () async {
                          changeButtonLoadingState(true);
                          await _signIn(context);
                          changeButtonLoadingState(false);
                        },
                        icon: Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                      )
                : !widget.isLogin
                    ? buttonLoading
                        ? CircularProgressIndicator()
                        : AppButton(
                            text: 'SIGN UP',
                            onPressed: () async {
                              changeButtonLoadingState(true);
                              await _signUp(context);
                              changeButtonLoadingState(false);
                            },
                            icon: Icon(
                              Icons.person_add,
                              color: Colors.white,
                            ),
                          )
                    // wont reach this condition
                    : Container(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
