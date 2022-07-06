// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quizz_app/constants.dart';
import 'package:quizz_app/models/models.dart';
import 'package:quizz_app/services/auth.dart';
import 'package:quizz_app/services/db.dart';
import 'package:quizz_app/shared/loading.dart';
import 'package:quizz_app/utils/upload_image.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

var uuid = const Uuid();

class EditQuizScreen extends StatefulWidget {
  final Quiz quiz;
  const EditQuizScreen({Key? key, required this.quiz}) : super(key: key);

  @override
  State<EditQuizScreen> createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  final ImagePicker _imagepicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _dbService = DBService();

  List<Question> _questions = [];

  String _title = '';
  String _description = '';
  List<Question> _selectedQuestions = [];
  dynamic _pickedImage = defaultCoverPath;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    getAllQuestions();

    setState(() {
      _title = widget.quiz.title;
      _description = widget.quiz.description;
      _selectedQuestions = widget.quiz.questions;
      _pickedImage = widget.quiz.img;
    });
  }

  void getAllQuestions() async {
    try {
      setState(() => _loading = true);
      var questions = await _dbService.getAllQuestions() ?? [];
      setState(() => _questions = questions);
    } catch (_) {
      _showSnackBar('Cannot get the questions', Colors.redAccent);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _pickImage() async {
    try {
      final image = await _imagepicker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      setState(() => _pickedImage = image);
    } catch (_) {
      rethrow;
    }
  }

  void _updateQuiz() async {
    if (_formKey.currentState?.validate() == true) {
      if (_selectedQuestions.isEmpty) {
        _showSnackBar("Please select at least one question", Colors.yellowAccent,
            colorText: Colors.black);
        return;
      }

      try {
        setState(() => _loading = true);

        String img = defaultCoverPath;
        if (_pickedImage is! String) {
          img = await uploadImage(_pickedImage);
        }

        final quiz = Quiz(
          id: widget.quiz.id,
          title: _title,
          description: _description,
          img: img,
          questions: _selectedQuestions,
        );

        await _dbService.updateQuiz(quiz);

        _showSnackBar("Quiz updated succesfully!", Colors.greenAccent, colorText: Colors.black);
      } catch (_) {
        _showSnackBar("Error updating quiz!", Colors.redAccent);
        rethrow;
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  void _showMultiSelect() async {
    final List<Question>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(
          items: _questions,
          selectedItems: _selectedQuestions,
        );
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _selectedQuestions = results;
      });
    }
  }

  void _showSnackBar(String message, Color color, {Color colorText = Colors.white}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
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

    return _loading
        ? const Loading()
        : Scaffold(
            appBar: AppBar(
              title: const Text('Edit a quiz'),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(
                        user?.photoURL ??
                            'https://avatars.dicebear.com/api/adventurer/${user?.uid}.png',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: !_loading
                ? FloatingActionButton(
                    onPressed: _updateQuiz,
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.edit),
                  )
                : null,
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10.0),
                      TextFormField(
                        initialValue: _title,
                        onChanged: (value) => setState(() => _title = value),
                        validator: (value) =>
                            value?.isEmpty == true ? "Please enter a title" : null,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: "Title"),
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        initialValue: _description,
                        onChanged: (value) => setState(() => _description = value),
                        validator: (value) =>
                            value?.isEmpty == true ? "Please enter a description" : null,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: "Description"),
                      ),
                      const SizedBox(height: 10.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.blueGrey),
                        onPressed: _showMultiSelect,
                        child: const Text("Select questions"),
                      ),
                      Wrap(
                        spacing: 10.0,
                        children: _selectedQuestions
                            .map((e) => Chip(
                                  label: Text(e.text),
                                ))
                            .toList(),
                      ),
                      Text(
                        "Quiz picture (Tap to change)",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10.0),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image: _pickedImage is String
                                    ? AssetImage(_pickedImage)
                                    : FileImage(File(_pickedImage.path)) as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

class MultiSelect extends StatefulWidget {
  final List<Question> items;
  final List<Question> selectedItems;
  const MultiSelect({Key? key, required this.items, required this.selectedItems}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  List<Question> _selectedQuestions = const [];

  void _itemChange(Question itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedQuestions.add(itemValue);
      } else {
        _selectedQuestions.removeWhere((element) => element.id == itemValue.id);
      }
    });
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _submit() {
    Navigator.pop(context, _selectedQuestions);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedQuestions = widget.selectedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Topics'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => CheckboxListTile(
                    contentPadding: const EdgeInsets.all(0),
                    value:
                        _selectedQuestions.firstWhereOrNull((element) => element.id == item.id) !=
                                null
                            ? true
                            : false,
                    title: Text(item.text),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) => _itemChange(item, isChecked!),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
