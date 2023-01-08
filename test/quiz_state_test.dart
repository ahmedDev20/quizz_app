import 'package:quizz_app/screens/quiz/quiz_state.dart';
import 'package:flutter_test/flutter_test.dart';


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
}
