// ignore_for_file: unnecessary_const

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quizz_app/models/models.dart';
import 'package:quizz_app/screens/admin/drawer.dart';
import 'package:quizz_app/screens/admin/topics/edit_topic.dart';
import 'package:quizz_app/services/auth.dart';
import 'package:quizz_app/services/db.dart';
import 'package:quizz_app/shared/loading.dart';

class AdminTopicsScreen extends StatefulWidget {
  const AdminTopicsScreen({Key? key}) : super(key: key);

  @override
  State<AdminTopicsScreen> createState() => _AdminTopicsScreenState();
}

class _AdminTopicsScreenState extends State<AdminTopicsScreen> {
  final _dbService = DBService();
  QuizUser _userData = QuizUser();

  List<Topic> _topics = [];

  getAllTopics() async {
    var topics = await _dbService.getAllTopics() ?? [];
    setState(() => _topics = topics);
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
    getAllTopics();
    getUserData();
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
  Widget build(BuildContext context) {
    var user = AuthService().user;

    return Scaffold(
      drawer: _userData.isAdmin! ? const AdminDrawer() : null,
      appBar: AppBar(
        title: const Text('Manage topics'),
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
          onPressed: () => Navigator.pushNamed(context, '/admin/add_topic'),
          backgroundColor: Colors.deepOrange,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          )),
      body: FutureBuilder(
          future: _dbService.getAllTopics(),
          builder: ((context, snapshot) {
            if (snapshot.hasData && !snapshot.hasError) {
              return RefreshIndicator(
                onRefresh: () {
                  return getAllTopics();
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: _topics.isEmpty
                      ? const ListTile(
                          title: Text(
                            "No topics at the moment 🙄",
                            style: TextStyle(fontSize: 18.0),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _topics.length,
                          itemBuilder: (context, index) {
                            final topic = _topics[index];

                            return Dismissible(
                              key: Key(topic.id),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                try {
                                  await _dbService.deleteTopic(topic.id);
                                  _showSnackBar('Topic Deleted', Colors.yellowAccent,
                                      colorText: Colors.black);

                                  setState(() {
                                    _topics.removeAt(index);
                                  });
                                  return Future.value(true);
                                } catch (e) {
                                  _showSnackBar('Cannot delete topic', Colors.redAccent);
                                  return Future.value(false);
                                }
                              },
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditTopicScreen(topic: topic),
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
                                            image: topic.img.startsWith('http')
                                                ? NetworkImage(topic.img) as ImageProvider
                                                : AssetImage(topic.img),
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                          topic.title,
                                          style: const TextStyle(fontSize: 18.0),
                                        ),
                                        subtitle: Text(topic.description),
                                        trailing: Text(
                                          "${topic.quizzes.length} ${Intl.plural(topic.quizzes.length, one: "quiz", other: "quizzes")}",
                                        ),
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
