//creer test pour widget addQuestion
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizz_app/screens/admin/questions/add_question.dart';

void main() {
  testWidgets('AddQuestion should have a title', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AddQuestionScreen()));
    expect(find.text('Add Question'), findsOneWidget);
  });
}
