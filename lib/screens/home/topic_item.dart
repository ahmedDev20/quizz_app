import 'package:flutter/material.dart';
import 'package:quizz_app/models/models.dart';
import 'package:quizz_app/screens/home/quiz_list.dart';
import 'package:quizz_app/shared/progress_bar.dart';

class TopicItem extends StatelessWidget {
  final Topic topic;
  const TopicItem({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: topic.id,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => TopicScreen(topic: topic),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 3,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: topic.img.startsWith('http')
                          ? NetworkImage(topic.img) as ImageProvider
                          : AssetImage(topic.img),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Text(
                    topic.title,
                    style: const TextStyle(
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ),
              Flexible(
                child: TopicProgress(topic: topic),
              ),
              const SizedBox(height: 5.0)
            ],
          ),
        ),
      ),
    );
  }
}

class TopicScreen extends StatelessWidget {
  final Topic topic;

  const TopicScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          Hero(
            tag: topic.id,
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: topic.img.startsWith('http')
                      ? NetworkImage(topic.img) as ImageProvider
                      : AssetImage(topic.img),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  style: const TextStyle(height: 2, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  topic.description,
                  style: const TextStyle(
                    height: 2,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 10.0),
                const Text(
                  "Quiz list",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                QuizList(topic: topic)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
