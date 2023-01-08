import 'package:quizz_app/screens/quiz/quiz_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizz_app/services/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizz_app/screens/admin/questions/add_question.dart';
import 'package:flutter/material.dart';

void main() {
  test('State progress should be 10', () {
    final state = QuizState();

    state.progress = 10;

    expect(state.progress, 10);
  });

  test('State progress should be -5', () {
    final state = QuizState();

    state.progress = -5;

    expect(state.progress, -5);
  });

  test('getAllUser should return a list of users', () async {
    DBService db = DBService();
    final users = await db.getAllUsers();
    expect(users, isA<List<User>>());
  });

  testWidgets('AddQuestion should have a title', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AddQuestionScreen()));
    expect(find.text('Add Question'), findsOneWidget);
  });
}
