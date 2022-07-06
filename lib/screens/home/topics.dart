import 'package:flutter/material.dart';
import 'package:quizz_app/models/models.dart';
import 'package:quizz_app/screens/admin/drawer.dart';
import 'package:quizz_app/screens/home/topic_item.dart';
import 'package:quizz_app/services/auth.dart';
import 'package:quizz_app/services/db.dart';
import 'package:quizz_app/shared/loading.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  QuizUser _userData = QuizUser();

  getUserData() async {
    var userData = await DBService().getCurrentUser();
    setState(() {
      _userData = userData;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    final dbService = DBService();
    final user = AuthService().user;

    return Scaffold(
      drawer: _userData.isAdmin! ? const AdminDrawer() : null,
      appBar: AppBar(
        title: const Text('Topics'),
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
      body: FutureBuilder(
        future: dbService.getAllTopics(),
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.hasError) {
            List<Topic> topics = snapshot.data as List<Topic>;

            if (topics.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("No topics at the moment 🙄"),
                    Text("Please come back later 🙏🏻"),
                  ],
                ),
              );
            }

            return GridView.count(
              primary: false,
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
              crossAxisSpacing: 10.0,
              crossAxisCount: 2,
              children: topics.map((topic) => TopicItem(topic: topic)).toList(),
            );
          } else {
            return const Loading();
          }
        },
      ),
    );
  }
}
