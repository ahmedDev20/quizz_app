import 'package:json_annotation/json_annotation.dart';
import 'package:quizz_app/constants.dart';
part 'models.g.dart';

@JsonSerializable()
class QuizUser {
  String? uid;
  bool? isAdmin;

  QuizUser({
    this.uid = '',
    this.isAdmin = false,
  });

  factory QuizUser.fromJson(Map<String, dynamic> json) => _$QuizUserFromJson(json);
  Map<String, dynamic> toJson() => _$QuizUserToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Topic {
  final String id;
  final String title;
  final String description;
  final String img;
  final List<Quiz> quizzes;

  Topic({
    this.id = '',
    this.title = '',
    this.description = '',
    this.img = defaultCoverPath,
    this.quizzes = const [],
  });

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);
  Map<String, dynamic> toJson() => _$TopicToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Question {
  String id;
  String text;
  List<Option> options;

  Question({this.id = '', this.options = const [], this.text = ''});

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}

@JsonSerializable()
class Option {
  String id;
  String value;
  String detail;
  bool correct;

  Option({
    this.id = '',
    this.value = '',
    this.detail = '',
    this.correct = false,
  });

  factory Option.fromJson(Map<String, dynamic> json) => _$OptionFromJson(json);
  Map<String, dynamic> toJson() => _$OptionToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Quiz {
  final String id;
  final String title;
  final String description;
  final String topicId;
  List<Question> questions;
  final String img;

  Quiz({
    this.title = '',
    this.description = '',
    this.id = '',
    this.topicId = '',
    this.questions = const [],
    this.img = defaultCoverPath,
  });
  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);
  Map<String, dynamic> toJson() => _$QuizToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Report {
  String uid;
  int total;
  Map topics;

  Report({this.uid = '', this.topics = const {}, this.total = 0});
  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
  Map<String, dynamic> toJson() => _$ReportToJson(this);
}
