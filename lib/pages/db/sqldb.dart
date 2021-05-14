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
  }

  /// SIGN IN
  Future<void> signIn(String user, String lon, String lat ) async {
    print("signin");
    MySqlConnection conn = await connect();

    var result = await conn.query(
      'insert into Logs (name, lon, lat) values (?, ?, ?)',
      [user, lon, lat],
    );

    print('Inserted row id=${result.insertId}');

    await conn.close();
    print("signin done");
  }

}
