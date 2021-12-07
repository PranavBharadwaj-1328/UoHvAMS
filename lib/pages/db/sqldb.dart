import 'dart:io';
// import 'package:mysql1/mysql1.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;

class SqlDatabaseService {
  // singleton boilerplate
  static final SqlDatabaseService _cameraServiceService =
      SqlDatabaseService._internal();
  factory SqlDatabaseService() {
    return _cameraServiceService;
  }
  SqlDatabaseService._internal();
  // var serverIp = 'scislearn3.uohyd.ac.in:8090';
  var serverIp = '10.5.0.47:8090';

  /// CONNECTS TO DB
  // Future<MySqlConnection> connect() async {
  //   print("conn");
  //   return await MySqlConnection.connect(
  //     ConnectionSettings(
  //       host: 'scislearn3.uohyd.ac.in',
  //       port: 3306,
  //       user: 'phpmyadmin',
  //       password: 'passwd@123',
  //       db: 'uohvams',
  //       // host: 'remotemysql.com',
  //       // port: 3306,
  //       // user: 'cVLw2NAjNX',
  //       // db: 'cVLw2NAjNX',
  //       // password: '7I3RP65o9I',
  //
  //
  //     ),
  //   );
  // }

  /// Device Id
  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  /// SIGN UP (new user)
  Future<void> signUp(
      String empId, String user, String email, String password) async {
    print("signup");
    // MySqlConnection conn = await connect();
    var url = Uri.http(serverIp, '/signup',
        {'emp_id': empId, 'name': user, 'email': email, 'password': password});
    var response = await http.get(url);
    print(response);
    var devId = await _getId();
    print(devId);
    // TODO: put id into mobile id table

    // var result = await conn.query(
    //   'insert into User_table (emp_id, name, email, password) values (?, ?, ?, ?)',
    //   [empId, user, email, password],
    // );
    // print('Inserted row id=${result.insertId}');

    // await conn.close();
    print("signup done");
    return;
  }

  /// SIGN UP (old user)

  Future<String> signUpOldUser(String empId, String pwd) async {
    print("signup- old user");
    var url = Uri.http(
        serverIp, '/signup_olduser', {'emp_id': empId, 'password': pwd});
    var response = await http.get(url);
    var status = response.body;

    print(status);

    return status == "Wrong password" ? null : status;

    //   MySqlConnection conn = await connect();
    //
    //   var result = await conn.query(
    //     'SELECT * from User_table WHERE emp_id=(?) AND password=(?)',
    //     [empId, pwd],
    //   );
    //
    //   var status = '';
    //   for (var row in result) status = row[2];
    //
    //   await conn.close();
    // print('old user: sign up done');
    // return status;
  }

  /// SIGN IN
  Future<void> signIn(String empId, String user, String io) async {
    print("signin");
    var url = Uri.http(
        serverIp, '/signin', {'emp_id': empId, 'name': user, 'in_out': io});
    var response = await http.get(url);
    print(response);
    // MySqlConnection conn = await connect();

    // var result = await conn.query(
    //   'insert into Logs (emp_id, name, in_out) values (?, ?, ?)',
    //   [empId, user, io],
    // );
    //
    // print('Inserted row id=${result.insertId}');
    //
    // await conn.close();
    print("Sign in done");
    return;
  }

  /// GEO FENCING LOGS

  Future<void> logGeoFence(
      String empId, String user, String entryId, String io) async {
    print("logging geo-fence updates");
    var url = Uri.http(serverIp, '/geolog',
        {'emp_id': empId, 'name': user, 'loc_id': entryId, 'in_out': io});
    var response = await http.get(url);
    print(response);
    // MySqlConnection conn = await connect();
    //
    // var result = await conn.query(
    //   'insert into Geo_logs (emp_id, name, loc_id, in_out) values (?, ?, ?, ?)',
    //   [empId, user, entryId, entryOrExit],
    // );
    //
    // print('Inserted row id=${result.insertId}');
    // await conn.close();
    return;
  }

  /// CHECK IF EMP ID EXISTS

  Future<dynamic> checkEmpID(String empId) async {
    print("Checking for emp id");
    // MySqlConnection conn = await connect();

    // var result = await conn.query(
    //   'SELECT name from User_table WHERE emp_id=(?)',
    //   [empId],
    // );
    //
    // var status = '';
    // for (var row in result) status = row[0];
    //
    // await conn.close();
    // print(status);
    // return status == '' ? null : status;
    // print("jvjfb");
    var url = Uri.http(serverIp, '/getname', {'id': empId});
    var response = await http.get(url);
    var status = response.body;
    print(status);
    return status == "New User" ? null : status;
  }
}
