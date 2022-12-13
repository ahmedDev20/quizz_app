import 'package:quizz_app/screens/quiz/quiz_state.dart';
import 'package:flutter_test/test.dart';

void main() {
  test('State progress should be 10', () {
    final state = QuizState();

    state.progress = 1;

    expect(state.progress, 10);
  });
}