import 'package:mysql1/mysql1.dart';

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
        host: 'remotemysql.com',
        port: 3306,
        user: 'cVLw2NAjNX',
        db: 'cVLw2NAjNX',
        password: '7I3RP65o9I',
      ),
    );
  }

  /// SIGN UP
  Future<void> signUp(String empid, String user, String email, String password ) async {
    print("signup");
    MySqlConnection conn = await connect();

    var result = await conn.query(
      'insert into User_table (emp_id, name, email, password) values (?, ?, ?, ?)',
      [empid, user, email, password],
    );
    print('Inserted row id=${result.insertId}');

    await conn.close();
    print("signup done");
    return;
  }

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
