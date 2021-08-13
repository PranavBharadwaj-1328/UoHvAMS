import 'package:flutter/material.dart';

class User {
  String user;
  String empId;
  String password;

  User({@required this.empId, @required this.user, @required this.password});

  static User fromDB(String dbuser) {
    return new User(empId:dbuser.split(':')[0], user: dbuser.split(':')[1], password: dbuser.split(':')[2]);
  }
}
