import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quizz_app/models/models.dart';
import 'package:quizz_app/screens/quiz/quiz.dart';

class QuizList extends StatelessWidget {
  final Topic topic;
  const QuizList({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: topic.quizzes.map(
        (quiz) {
          return Card(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => QuizScreen(quizId: quiz.id),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    quiz.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  subtitle: Text(
                    quiz.description,
                    overflow: TextOverflow.fade,
                  ),
                  leading: QuizBadge(topic: topic, quizId: quiz.id),
                ),
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}

class QuizBadge extends StatelessWidget {
  final String quizId;
  final Topic topic;

  const QuizBadge({super.key, required this.quizId, required this.topic});

  @override
  Widget build(BuildContext context) {
    Report report = Provider.of<Report>(context);
    List completed = report.topics[topic.id] ?? [];
    if (completed.contains(quizId)) {
      return const Icon(Icons.check, color: Colors.green);
    } else {
      return const Icon(FontAwesomeIcons.solidCircle, color: Colors.grey);
    }
  }
}
