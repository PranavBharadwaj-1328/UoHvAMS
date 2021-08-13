import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class DataBaseService {
  // singleton boilerplate
  static final DataBaseService _cameraServiceService =
      DataBaseService._internal();

  factory DataBaseService() {
    return _cameraServiceService;
  }
  // singleton boilerplate
  DataBaseService._internal();

  /// file that stores the data on filesystem
  File jsonFile;

  /// Data learned on memory
  Map<String, dynamic> _db = Map<String, dynamic>();
  Map<String, dynamic> get db => this._db;

  /// checks if json file exists or not
  Future checkDB() async {
    var tempDir = await getApplicationDocumentsDirectory();
    String _embPath = tempDir.path + '/emb.json';
    jsonFile = new File(_embPath);

    if (jsonFile.existsSync()) {
      return json.decode(jsonFile.readAsStringSync()).toString() == "{}" ? false : true;
    } else return false;
  }

  /// loads a simple json file.
  Future loadDB() async {
    var tempDir = await getApplicationDocumentsDirectory();
    String _embPath = tempDir.path + '/emb.json';
    jsonFile = new File(_embPath);

    if (jsonFile.existsSync()) {
      _db = json.decode(jsonFile.readAsStringSync());
      print(_db);
    }
  }
  /// [Name]: name of the new user
  /// [Data]: Face representation for Machine Learning model
  Future saveData(String empid, String user, String password, List modelData) async {
    String userAndPass = empid + ':' + user + ':' + password;
    _db[userAndPass] = modelData;
    jsonFile.writeAsStringSync(json.encode(_db));
  }

  /// deletes the created users
  cleanDB() {
    this._db = Map<String, dynamic>();
    jsonFile.writeAsStringSync(json.encode({}));
  }
}
