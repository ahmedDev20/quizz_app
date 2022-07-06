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

var uuid = const Uuid();

class AddTopicScreen extends StatefulWidget {
  const AddTopicScreen({Key? key}) : super(key: key);

  @override
  State<AddTopicScreen> createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen> {
  final ImagePicker _imagepicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _dbService = DBService();

  List<Quiz> _selectedQuizzes = [];

  String _title = '';
  String _description = '';
  dynamic _pickedImage = defaultCoverPath;
  List<Quiz> _quizzes = [];
  bool _loading = false;

  void _pickImage() async {
    try {
      final image = await _imagepicker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      setState(() => _pickedImage = image);
    } catch (_) {
      rethrow;
    }
  }

  void _addTopic() async {
    if (_formKey.currentState?.validate() == true) {
      if (_selectedQuizzes.isEmpty) {
        _showSnackBar("Please select at least one quiz", Colors.yellowAccent,
            colorText: Colors.black);
        return;
      }

      try {
        setState(() => _loading = true);

        String img = defaultCoverPath;
        if (_pickedImage is! String) img = await uploadImage(_pickedImage);

        var id = uuid.v4();
        final topic = Topic(
          id: id,
          title: _title,
          description: _description,
          img: img,
          quizzes: _selectedQuizzes
              .map(
                (e) => Quiz(
                    id: e.id,
                    title: e.title,
                    description: e.description,
                    img: e.img,
                    questions: e.questions,
                    topicId: id),
              )
              .toList(),
        );

        await _dbService.updateTopic(topic);

        _resetForm();
        _showSnackBar("Topic added succesfully!", Colors.greenAccent, colorText: Colors.black);
      } catch (_) {
        _showSnackBar("Error adding topic!", Colors.redAccent);
        rethrow;
      } finally {
        setState(() => _loading = false);
      }
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

  void _resetForm() {
    setState(() {
      _title = '';
      _description = '';
      _pickedImage = defaultCoverPath;
    });
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

  getAllQuizzes() async {
    var quizzes = await _dbService.getAllQuizzes() ?? [];
    setState(() => _quizzes = quizzes);
  }

  @override
  void initState() {
    super.initState();
    getAllQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    var user = AuthService().user;

    return _loading
        ? const Loading()
        : Scaffold(
            appBar: AppBar(
              title: const Text('Add a topic'),
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
                    onPressed: _addTopic,
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.add),
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
                        onChanged: (value) => setState(() => _title = value),
                        validator: (value) =>
                            value?.isEmpty == true ? "Please enter a title" : null,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: "Title"),
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        maxLines: 3,
                        onChanged: (value) => setState(() => _description = value),
                        validator: (value) =>
                            value?.isEmpty == true ? "Please enter a description" : null,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: "Description"),
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        "Quiz list ${_quizzes.isEmpty ? "(Empty)" : ""}",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 5.0),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedQuizzes.length,
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
                      const SizedBox(height: 10.0),
                      ElevatedButton(
                        onPressed: _showMultiSelect,
                        style: ElevatedButton.styleFrom(primary: Colors.blueGrey),
                        child: const Text("Add quizzes"),
                      ),
                      const SizedBox(height: 10.0),
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
        widget.selectedItems.remove(itemValue);
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
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Quizzes'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => CheckboxListTile(
                    contentPadding: const EdgeInsets.all(0),
                    value: widget.selectedItems.contains(item),
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
