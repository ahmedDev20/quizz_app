//import db.dart';
// ignore: unused_import
import 'package:quizz_app/services/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('getAllUser should return a list of users', () async {
    DBService db = DBService();
    final users = await db.getAllUsers();
    expect(users, isA<List<User>>());
  });
}
