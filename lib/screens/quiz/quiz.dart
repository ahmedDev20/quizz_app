import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quizz_app/constants.dart';
import 'package:quizz_app/models/models.dart';
import 'package:quizz_app/screens/quiz/quiz_state.dart';
import 'package:quizz_app/services/db.dart';
import 'package:quizz_app/shared/loading.dart';
import 'package:quizz_app/shared/progress_bar.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key, required this.quizId});
  final String quizId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizState(),
      child: FutureBuilder<Quiz>(
        future: DBService().getQuiz(quizId),
        builder: (context, snapshot) {
          var state = Provider.of<QuizState>(context);

          if (!snapshot.hasData || snapshot.hasError) {
            return const Loading();
          } else {
            var quiz = snapshot.data!;

            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                bottom: PreferredSize(
                    preferredSize: const Size(double.infinity, 0),
                    child: AnimatedProgressbar(value: state.progress)),
                leading: IconButton(
                  icon: const Icon(FontAwesomeIcons.xmark),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: PageView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                controller: state.controller,
                onPageChanged: (int idx) => state.progress = (idx / (quiz.questions.length + 1)),
                itemBuilder: (BuildContext context, int idx) {
                  if (idx == 0) {
                    return StartPage(quiz: quiz);
                  } else if (idx == quiz.questions.length + 1) {
                    return CongratsPage(quiz: quiz);
                  } else {
                    return QuestionPage(question: quiz.questions[idx - 1]);
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class StartPage extends StatelessWidget {
  final Quiz quiz;
  const StartPage({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<QuizState>(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Image(
                  image: quiz.img.startsWith('http')
                      ? NetworkImage(quiz.img) as ImageProvider
                      : AssetImage(quiz.img)),
            ),
          ),
          const SizedBox(height: 20.0),
          Text(quiz.title, style: Theme.of(context).textTheme.headline4),
          const Divider(),
          Expanded(
              child: Text(
            quiz.description,
            textAlign: TextAlign.center,
          )),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                primary: Colors.deepOrange, minimumSize: const Size.fromHeight(50.0)),
            onPressed: state.nextPage,
            label: const Text(
              'Start Quiz!',
              style: TextStyle(fontSize: 18.0),
            ),
            icon: const Icon(Icons.quiz),
          )
        ],
      ),
    );
  }
}

class CongratsPage extends StatefulWidget {
  final Quiz quiz;
  const CongratsPage({super.key, required this.quiz});

  @override
  State<CongratsPage> createState() => _CongratsPageState();
}

class _CongratsPageState extends State<CongratsPage> {
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 10));

  final AudioPlayer player = AudioPlayer();

  playCorrect() async {
    await player.play(AssetSource(winSFXPath));
  }

  @override
  void initState() {
    super.initState();

    playCorrect();
    Timer(const Duration(milliseconds: 100), () => _confettiController.play());
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Congrats!',
            style: TextStyle(fontSize: 24.0),
          ),
          Text(
            'You completed the ${widget.quiz.title} quiz',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20.0),
          ),
          const SizedBox(height: 20.0),
          ConfettiWidget(
            numberOfParticles: 50,
            shouldLoop: true,
            blastDirectionality: BlastDirectionality.explosive,
            confettiController: _confettiController,
            blastDirection: pi / 2,
          ),
          ElevatedButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            icon: const Icon(FontAwesomeIcons.check),
            label: const Text(' Mark Complete!'),
            onPressed: () {
              DBService().updateUserReport(widget.quiz);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class QuestionPage extends StatelessWidget {
  final Question question;
  final AudioPlayer player = AudioPlayer();

  QuestionPage({super.key, required this.question});

  playCorrect() async {
    await player.play(AssetSource(correctSFXPath));
  }

  playWrong() async {
    await player.play(AssetSource(wrongSFXPath));
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<QuizState>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Text(
              question.text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20.0),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: question.options.map((opt) {
              return Container(
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () {
                    state.selected = opt;
                    _bottomSheet(context, opt, state);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                            state.selected == opt
                                ? FontAwesomeIcons.circleCheck
                                : FontAwesomeIcons.circle,
                            size: 30),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 16),
                            child: Text(
                              opt.value,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  /// Bottom sheet shown when Question is answered
  _bottomSheet(BuildContext context, Option opt, QuizState state) {
    bool correct = opt.correct;

    if (correct) {
      playCorrect();
    } else {
      playWrong();
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                correct ? 'Good Job!' : 'Wrong',
                style: const TextStyle(fontSize: 20.0),
              ),
              Text(
                opt.detail,
                style: const TextStyle(fontSize: 18, color: Colors.white54),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: correct ? Colors.green : Colors.red,
                    minimumSize: const Size.fromHeight(40.0)),
                child: Text(
                  correct ? 'Next!' : 'Try Again',
                  style: const TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  if (correct) {
                    state.nextPage();
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
