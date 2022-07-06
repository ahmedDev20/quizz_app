// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quizz_app/constants.dart';
import 'package:quizz_app/models/models.dart';
import 'package:quizz_app/screens/admin/quizzes/edit_quiz.dart';
import 'package:quizz_app/services/auth.dart';
import 'package:quizz_app/services/db.dart';
import 'package:quizz_app/shared/loading.dart';
import 'package:quizz_app/utils/upload_image.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

var uuid = const Uuid();

class EditTopicScreen extends StatefulWidget {
  final Topic topic;
  const EditTopicScreen({Key? key, required this.topic}) : super(key: key);

  @override
  State<EditTopicScreen> createState() => _EditTopicScreenState();
}

class _EditTopicScreenState extends State<EditTopicScreen> {
  final ImagePicker _imagepicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _dbService = DBService();

  List<Quiz> _selectedQuizzes = [];

  String _title = '';
  String _description = '';
  dynamic _pickedImage = '';
  List<Quiz> _quizzes = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    getAllQuizzes();

    setState(() {
      _title = widget.topic.title;
      _description = widget.topic.description;
      _pickedImage = widget.topic.img;
      _selectedQuizzes = widget.topic.quizzes;
    });
  }

  getAllQuizzes() async {
    var quizzes = await _dbService.getAllQuizzes() ?? [];
    setState(() {
      _quizzes = quizzes;
      if (_quizzes.isEmpty) {
        _selectedQuizzes = [];
      }
    });
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

  void _editTopic() async {
    if (_formKey.currentState?.validate() == true) {
      if (_selectedQuizzes.isEmpty) {
        _showSnackBar("Please select at least one quiz", Colors.yellowAccent,
            colorText: Colors.black);
        return;
      }

      try {
        setState(() => _loading = true);

        var img = _pickedImage;

        if (_pickedImage is! String) {
          img = await uploadImage(_pickedImage);
        }

        final topic = Topic(
          id: widget.topic.id,
          title: _title,
          description: _description,
          quizzes: _selectedQuizzes
              .map(
                (e) => Quiz(
                  id: e.id,
                  title: e.title,
                  description: e.description,
                  img: e.img,
                  questions: e.questions,
                  topicId: widget.topic.id,
                ),
              )
              .toList(),
          img: img,
        );

        await _dbService.updateTopic(topic);

        _showSnackBar("Topic updated succesfully!", Colors.greenAccent, colorText: Colors.black);
      } catch (_) {
        _showSnackBar("Error updating topic!", Colors.redAccent);
        rethrow;
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  void _showMultiSelect() async {
    final List<Quiz>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(
          items: _quizzes,
          selectedItems: _selectedQuizzes,
        );
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _selectedQuizzes = results;
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
              title: const Text('Edit a topic'),
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
                    onPressed: _editTopic,
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.edit),
                  )
                : null,
            body: SingleChildScrollView(
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
                        maxLines: 4,
                        initialValue: _description,
                        onChanged: (value) => setState(() => _description = value),
                        validator: (value) =>
                            value?.isEmpty == true ? "Please enter a description" : null,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: "Description"),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        _quizzes.isEmpty ? "No quizzes" : "Quiz list",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 5.0),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _quizzes.isEmpty ? 0 : _selectedQuizzes.length,
                        itemBuilder: (context, index) {
                          var quiz = _selectedQuizzes[index];
                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditQuizScreen(quiz: quiz),
                                ),
                              );
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            selectedTileColor: Colors.blueGrey,
                            selected: true,
                            title: Text(
                              quiz.title,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () => setState(() => _selectedQuizzes.removeAt(index)),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(height: 10.0),
                      ),
                      const SizedBox(height: 5.0),
                      ElevatedButton(
                        onPressed: _showMultiSelect,
                        style: ElevatedButton.styleFrom(primary: Colors.blueGrey),
                        child: const Text("Add quizzes"),
                      ),
                      Text(
                        "Topic picture (Tap to change)",
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
                                image: _pickedImage is XFile
                                    ? FileImage(File(_pickedImage.path))
                                    : _pickedImage.startsWith('http')
                                        ? NetworkImage(_pickedImage) as ImageProvider
                                        : AssetImage(_pickedImage),
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
  final List<Quiz> items;
  final List<Quiz> selectedItems;
  const MultiSelect({Key? key, required this.items, required this.selectedItems}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  void _itemChange(Quiz itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        widget.selectedItems.add(itemValue);
      } else {
        widget.selectedItems.removeWhere((element) => element.id == itemValue.id);
      }
    });
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _submit() {
    Navigator.pop(context, widget.selectedItems);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Quizzes'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => CheckboxListTile(
                    contentPadding: const EdgeInsets.all(0),
                    value:
                        widget.selectedItems.firstWhereOrNull((element) => element.id == item.id) !=
                                null
                            ? true
                            : false,
                    title: Text(item.title),
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
