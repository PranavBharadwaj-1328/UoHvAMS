import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'package:device_info_plus/device_info_plus.dart';

class SqlDatabaseService {
  // singleton boilerplate
  static final SqlDatabaseService _cameraServiceService =
      SqlDatabaseService._internal();

  factory SqlDatabaseService() {
    return _cameraServiceService;
  }
  SqlDatabaseService._internal();

  /// CONNECTS TO DB
  Future<MySqlConnection> connect() async {
    print("conn");
    return await MySqlConnection.connect(
      ConnectionSettings(
        // host: 'scislearn3.uohyd.ac.in',
        // port: 3306,
        // user: 'ams1user1',
        // db: 'ams1',
        // password: 'Nksscis#1',
        host: 'remotemysql.com',
        port: 3306,
        user: 'cVLw2NAjNX',
        db: 'cVLw2NAjNX',
        password: '7I3RP65o9I',
      ),
    );
  }

  /// Device Id
  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
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
    MySqlConnection conn = await connect();

    var devId = await _getId();
    print(devId);
    // TODO: put id into mobile id table

    var result = await conn.query(
      'insert into User_table (emp_id, name, email, password) values (?, ?, ?, ?)',
      [empId, user, email, password],
    );
    print('Inserted row id=${result.insertId}');

    await conn.close();
    print("signup done");
    return;
  }

  /// SIGN UP (old user)

  Future<String> signUpOldUser(String empId, String pwd) async {
    print("signup- old user");
    MySqlConnection conn = await connect();

    var result = await conn.query(
      'SELECT * from User_table WHERE emp_id=(?) AND password=(?)',
      [empId, pwd],
    );

    var status = '';
    for (var row in result) status = row[2];

    await conn.close();
    print('old user:' + status + ' sign up done');

    return status;
  }

  /// SIGN IN
  Future<void> signIn(String empId, String user, String io) async {
    print("signin");
    MySqlConnection conn = await connect();

    var result = await conn.query(
      'insert into Logs (emp_id, name, in_out) values (?, ?, ?)',
      [empId, user, io],
    );

    print('Inserted row id=${result.insertId}');

    await conn.close();
    print("Sign in done");
    return;
  }

  /// GEO FENCING LOGS

  Future<void> logGeoFence(
      String empId, String user, String entryId, String entryOrExit) async {
    print("logging geo-fence updates");
    MySqlConnection conn = await connect();

    var result = await conn.query(
      'insert into Geo_logs (emp_id, name, loc_id, in_out) values (?, ?, ?, ?)',
      [empId, user, entryId, entryOrExit],
    );

    print('Inserted row id=${result.insertId}');
    await conn.close();
    return;
  }

  /// CHECK IF EMP ID EXISTS

  Future<dynamic> checkEmpID(String empId) async {
    print("Checking for emp id");
    MySqlConnection conn = await connect();

    var result = await conn.query(
      'SELECT name from User_table WHERE emp_id=(?)',
      [empId],
    );

    var status = '';
    for (var row in result) status = row[0];

    await conn.close();
    print(status);
    return status == '' ? null : status;
  }
}
