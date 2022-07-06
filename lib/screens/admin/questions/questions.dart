import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quizz_app/models/models.dart';
import 'package:quizz_app/screens/admin/drawer.dart';
import 'package:quizz_app/screens/admin/questions/edit_question.dart';
import 'package:quizz_app/services/auth.dart';
import 'package:quizz_app/services/db.dart';
import 'package:quizz_app/shared/loading.dart';

class AdminQuestionsScreen extends StatefulWidget {
  const AdminQuestionsScreen({Key? key}) : super(key: key);

  @override
  State<AdminQuestionsScreen> createState() => _AdminQuestionsScreenState();
}

class _AdminQuestionsScreenState extends State<AdminQuestionsScreen> {
  final _dbService = DBService();
  QuizUser _userData = QuizUser();
  List<Question> _questions = [];

  getAllQuestions() async {
    var questions = await _dbService.getAllQuestions() ?? [];
    setState(() => _questions = questions);
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

  getUserData() async {
    var userData = await DBService().getCurrentUser();
    setState(() {
      _userData = userData;
    });
  }

  @override
  void initState() {
    super.initState();
    getAllQuestions();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    var user = AuthService().user;

    return Scaffold(
      drawer: _userData.isAdmin! ? const AdminDrawer() : null,
      appBar: AppBar(
        title: const Text('Manage questions'),
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
          onPressed: () => Navigator.pushNamed(context, '/admin/add_question'),
          backgroundColor: Colors.deepOrange,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          )),
      body: FutureBuilder(
        future: _dbService.getAllQuestions(),
        builder: ((context, snapshot) {
          if (snapshot.hasData && !snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: () {
                return getAllQuestions();
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: _questions.isEmpty
                    ? const ListTile(
                        title: Text(
                          "No questions at the moment 🙄",
                          style: TextStyle(fontSize: 18.0),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _questions.length,
                        itemBuilder: (context, index) {
                          final question = _questions[index];

                          return Dismissible(
                            key: Key(question.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              try {
                                await _dbService.deleteQuiz(question.id);
                                _showSnackBar('Question Deleted', Colors.yellowAccent,
                                    colorText: Colors.black);

                                setState(() {
                                  _questions.removeAt(index);
                                });
                                return Future.value(true);
                              } catch (e) {
                                _showSnackBar('Cannot delete question', Colors.redAccent);
                                return Future.value(false);
                              }
                            },
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditQuestionScreen(question: question),
                                  ),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 15.0),
                                child: ListTile(
                                  title: Text(
                                    question.text,
                                    style: const TextStyle(fontSize: 18.0),
                                  ),
                                  subtitle: Text(
                                      "${question.options.length} ${Intl.plural(question.options.length, one: "option", other: "options")}"),
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
        }),
      ),
    );
  }
}
