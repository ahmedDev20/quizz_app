import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quizz_app/models/models.dart';
import 'package:quizz_app/screens/admin/drawer.dart';
import 'package:quizz_app/screens/admin/quizzes/edit_quiz.dart';
import 'package:quizz_app/services/auth.dart';
import 'package:quizz_app/services/db.dart';
import 'package:quizz_app/shared/loading.dart';

class AdminQuizzesScreen extends StatefulWidget {
  const AdminQuizzesScreen({Key? key}) : super(key: key);

  @override
  State<AdminQuizzesScreen> createState() => _AdminQuizzesScreenState();
}

class _AdminQuizzesScreenState extends State<AdminQuizzesScreen> {
  final _dbService = DBService();
  QuizUser _userData = QuizUser();
  List<Quiz> _quizzes = [];

  getAllQuizzes() async {
    var quizzes = await _dbService.getAllQuizzes() ?? [];
    setState(() => _quizzes = quizzes);
  }

  getUserData() async {
    var userData = await DBService().getCurrentUser();
    setState(() {
      _userData = userData;
    });
  }

  void _showSnackBar(String message, Color color, {Color colorText = Colors.white}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1500),
        backgroundColor: color,
        content: Text(
          message,
          style: TextStyle(color: colorText),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getAllQuizzes();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    var user = AuthService().user;

    return Scaffold(
      drawer: _userData.isAdmin! ? const AdminDrawer() : null,
      appBar: AppBar(
        title: const Text('Manage quizzes'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(
                  user?.photoURL ?? 'https://avatars.dicebear.com/api/adventurer/${user?.uid}.png',
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/admin/add_quiz'),
          backgroundColor: Colors.deepOrange,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          )),
      body: FutureBuilder(
          future: _dbService.getAllQuizzes(),
          builder: ((context, snapshot) {
            if (snapshot.hasData && !snapshot.hasError) {
              return RefreshIndicator(
                onRefresh: () {
                  return getAllQuizzes();
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: _quizzes.isEmpty
                      ? const ListTile(
                          title: Text(
                            "No quizzes at the moment 🙄",
                            style: TextStyle(fontSize: 18.0),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _quizzes.length,
                          itemBuilder: (context, index) {
                            final quiz = _quizzes[index];

                            return Dismissible(
                              key: Key(quiz.id),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                try {
                                  await _dbService.deleteQuiz(quiz.id);
                                  _showSnackBar('Quiz Deleted', Colors.yellowAccent,
                                      colorText: Colors.black);

                                  setState(() {
                                    _quizzes.removeAt(index);
                                  });
                                  return Future.value(true);
                                } catch (e) {
                                  _showSnackBar('Cannot delete quiz', Colors.redAccent);
                                  return Future.value(false);
                                }
                              },
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditQuizScreen(quiz: quiz),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 15.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 150,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: quiz.img.startsWith('http')
                                                ? NetworkImage(quiz.img) as ImageProvider
                                                : AssetImage(quiz.img),
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                          quiz.title,
                                          style: const TextStyle(fontSize: 18.0),
                                        ),
                                        subtitle: Text(quiz.description),
                                        trailing: Text(
                                            "${quiz.questions.length} ${Intl.plural(quiz.questions.length, one: "question", other: "questions")}"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              );
            } else {
              return const Loading();
            }
          })),
    );
  }
}
