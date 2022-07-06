// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizUser _$QuizUserFromJson(Map<String, dynamic> json) => QuizUser(
      uid: json['uid'] as String? ?? '',
      isAdmin: json['isAdmin'] as bool? ?? false,
    );

Map<String, dynamic> _$QuizUserToJson(QuizUser instance) => <String, dynamic>{
      'uid': instance.uid,
      'isAdmin': instance.isAdmin,
    };

Topic _$TopicFromJson(Map<String, dynamic> json) => Topic(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      img: json['img'] as String? ?? defaultCoverPath,
      quizzes: (json['quizzes'] as List<dynamic>?)
              ?.map((e) => Quiz.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'img': instance.img,
      'quizzes': instance.quizzes.map((e) => e.toJson()).toList(),
    };

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
      id: json['id'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => Option.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      text: json['text'] as String? ?? '',
    );

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'options': instance.options.map((e) => e.toJson()).toList(),
    };

Option _$OptionFromJson(Map<String, dynamic> json) => Option(
      id: json['id'] as String? ?? '',
      value: json['value'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
      correct: json['correct'] as bool? ?? false,
    );

Map<String, dynamic> _$OptionToJson(Option instance) => <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
      'detail': instance.detail,
      'correct': instance.correct,
    };

Quiz _$QuizFromJson(Map<String, dynamic> json) => Quiz(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      id: json['id'] as String? ?? '',
      topicId: json['topicId'] as String? ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => Question.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      img: json['img'] as String? ?? defaultCoverPath,
    );

Map<String, dynamic> _$QuizToJson(Quiz instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'topicId': instance.topicId,
      'questions': instance.questions.map((e) => e.toJson()).toList(),
      'img': instance.img,
    };

Report _$ReportFromJson(Map<String, dynamic> json) => Report(
      uid: json['uid'] as String? ?? '',
      topics: json['topics'] as Map<String, dynamic>? ?? const {},
      total: json['total'] as int? ?? 0,
    );

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
      'uid': instance.uid,
      'total': instance.total,
      'topics': instance.topics,
    };
