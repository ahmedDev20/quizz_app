import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizz_app/models/models.dart';
import 'package:quizz_app/services/auth.dart';

class DBService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

// User
  Future<List<QuizUser>?> getAllUsers() async {
    try {
      var ref = _db.collection('users');
      var snapshot = await ref.get();
      var data = snapshot.docs.map((s) => s.data());
      var users = data.map((d) => QuizUser.fromJson(d));
      return users.toList();
    } catch (_) {
      rethrow;
    }
  }

  Future<QuizUser> getCurrentUser() async {
    var result = await _db.collection('users').doc(AuthService().user?.uid).get();
    var user = QuizUser.fromJson(result.data()!);

    return user;
  }

  Future updateUser(QuizUser user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toJson());
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

// Topic
  Future<List<Topic>?> getAllTopics() async {
    try {
      var ref = _db.collection('topics');
      var snapshot = await ref.get();
      var data = snapshot.docs.map((s) => s.data());
      var topics = data.map((d) => Topic.fromJson(d));
      return topics.toList();
    } catch (_) {
      rethrow;
    }
  }

  Future updateTopic(Topic topic) async {
    try {
      await _db.collection('topics').doc(topic.id).set(topic.toJson());
      for (var quiz in topic.quizzes) {
        await _db.collection('quizzes').doc(quiz.id).update({"topicId": quiz.topicId});
      }
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future deleteTopic(String id) async {
    try {
      return await _db.collection('topics').doc(id).delete();
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

// Quiz
  Future<Quiz> getQuiz(String quizId) async {
    var ref = _db.collection('quizzes').doc(quizId);
    var snapshot = await ref.get();
    return Quiz.fromJson(snapshot.data() ?? {});
  }

  Future<List<Quiz>?> getAllQuizzes() async {
    try {
      var ref = _db.collection('quizzes');
      var snapshot = await ref.get();
      var data = snapshot.docs.map((s) => s.data());
      var quizzes = data.map((d) => Quiz.fromJson(d));
      return quizzes.toList();
    } catch (_) {
      rethrow;
    }
  }

  Future updateQuiz(Quiz quiz) async {
    try {
      await _db.collection('quizzes').doc(quiz.id).set(quiz.toJson());
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future deleteQuiz(String id) async {
    try {
      return await _db.collection('quizzes').doc(id).delete();
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

// Question
  Future<List<Question>?> getAllQuestions() async {
    try {
      var ref = _db.collection('questions');
      var snapshot = await ref.get();
      var data = snapshot.docs.map((s) => s.data());
      var quizzes = data.map((d) => Question.fromJson(d));
      return quizzes.toList();
    } catch (_) {
      rethrow;
    }
  }

  Future updateQuestion(Question question) async {
    try {
      return await _db.collection('questions').doc(question.id).set(question.toJson());
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future deleteQuestion(String id) async {
    try {
      return await _db.collection('questions').doc(id).delete();
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

// Report
  Stream<Report> streamReport() {
    var user = AuthService().user;

    if (user != null) {
      var ref = _db.collection('reports').doc(user.uid);

      return ref.snapshots().map((doc) {
        return doc.exists ? Report.fromJson(doc.data()!) : Report();
      });
    } else {
      return Stream.fromIterable([Report()]);
    }
  }

  /// Updates the current user's report document after completing quiz
  Future<void> updateUserReport(Quiz quiz) {
    var user = AuthService().user!;
    var ref = _db.collection('reports').doc(user.uid);

    var data = {
      'total': FieldValue.increment(1),
      'topics': {
        quiz.topicId: FieldValue.arrayUnion([quiz.id])
      }
    };

    return ref.set(data, SetOptions(merge: true));
  }
}
