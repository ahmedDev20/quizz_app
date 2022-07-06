import 'package:quizz_app/screens/admin/questions/add_question.dart';
import 'package:quizz_app/screens/admin/questions/questions.dart';
import 'package:quizz_app/screens/admin/quizzes/add_quiz.dart';
import 'package:quizz_app/screens/admin/quizzes/quizzes.dart';
import 'package:quizz_app/screens/admin/topics/add_topic.dart';
import 'package:quizz_app/screens/admin/topics/topics.dart';
import 'package:quizz_app/screens/admin/users/users.dart';
import 'package:quizz_app/screens/auth/login.dart';
import 'package:quizz_app/screens/home/home.dart';
import 'package:quizz_app/screens/home/profile.dart';

var appRoutes = {
  '/': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/admin/users': (context) => const AdminUsersScreen(),
  '/admin/topics': (context) => const AdminTopicsScreen(),
  '/admin/add_topic': (context) => const AddTopicScreen(),
  '/admin/quizzes': (context) => const AdminQuizzesScreen(),
  '/admin/add_quiz': (context) => const AddQuizScreen(),
  '/admin/questions': (context) => const AdminQuestionsScreen(),
  '/admin/add_question': (context) => const AddQuestionScreen(),
};
