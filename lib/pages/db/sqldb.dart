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
  // singleton boilerplate
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
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }
  /// SIGN UP
  Future<void> signUp(String empid, String user, String email, String password ) async {
    print("signup");
    MySqlConnection conn = await connect();
    var dev_id = await _getId();
    print(dev_id);
    var result = await conn.query(
      'insert into User_table (mobile_id, emp_id, name, email, password) values (?, ?, ?, ?, ?)',
      [dev_id, empid, user, email, password],
    );
    print('Inserted row id=${result.insertId}');

    await conn.close();
    print("signup done");
    return;
  }
  //TODO : fetch dev_id in front-end
  /// SIGN IN
  Future<void> signIn(String user, String io) async {
    print("signin");
    MySqlConnection conn = await connect();

    var result = await conn.query(
      'insert into Logs (name, in_out) values (?, ?)',
      [user, io],
    );

    print('Inserted row id=${result.insertId}');

    await conn.close();
    print("signin done");
    return;
  }

  /// GEO FENCING LOGS

  Future<void> logGeoFence(String user, String entryId, String entryOrExit) async {
    print("logging geo-fence updates");
    MySqlConnection conn = await connect();

    var result = await conn.query(
      'insert into Geo_logs (name, loc_id, in_out) values (?, ?, ?)',
      [user, entryId, entryOrExit],
    );

    print('Inserted row id=${result.insertId}');
    await conn.close();
    return;
  }
}
