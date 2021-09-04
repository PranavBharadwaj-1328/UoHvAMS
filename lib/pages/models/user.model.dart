import 'package:flutter/material.dart';

class User {
  String user;
  String empId;
  String password;
  String clientId;

  User({@required this.empId, @required this.user, @required this.password, @required this.clientId});

  static User fromDB(String dbuser) {
    return new User(empId:dbuser.split(':')[0], user: dbuser.split(':')[1], password: dbuser.split(':')[2], clientId: dbuser.split(':')[3]);
  }
}
