// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:quizz_app/models/models.dart';
import 'package:quizz_app/services/auth.dart';
import 'package:quizz_app/services/db.dart';
import 'package:quizz_app/shared/loading.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

var uuid = const Uuid();

class EditQuestionScreen extends StatefulWidget {
  final Question question;
  const EditQuestionScreen({Key? key, required this.question}) : super(key: key);

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbService = DBService();

  String _text = '';
  List<Option> _options = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _text = widget.question.text;
    _options = widget.question.options;
  }

  void _updateQuestion() async {
    if (_formKey.currentState?.validate() == true) {
      if (_options.isEmpty) {
        _showSnackBar("You need at least one option", Colors.yellowAccent, colorText: Colors.black);
        return;
      }

      if (_options.firstWhereOrNull((element) => element.correct) == null) {
        _showSnackBar("You need at least one correct option", Colors.yellowAccent,
            colorText: Colors.black);
        return;
      }

      if (_options.isNotEmpty && _options.takeWhile((value) => value.correct).length > 1) {
        _showSnackBar('Only one option should be correct!', Colors.redAccent);
        return;
      }

      try {
        setState(() => _loading = true);

        final question = Question(id: widget.question.id, text: _text, options: _options);

        await _dbService.updateQuestion(question);

        _showSnackBar("Question updated succesfully!", Colors.greenAccent, colorText: Colors.black);
      } catch (_) {
        _showSnackBar("Error updating question!", Colors.redAccent);
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

  void _showModalBottomSheet(BuildContext context, {Option? option, bool edit = false}) async {
    var result = await showModalBottomSheet<Option>(
      context: context,
      builder: (context) {
        return _BottomSheetContent(
          option: option,
          edit: edit,
        );
      },
    );

    if (result != null) {
      // for editing the option
      if (edit) {
        setState(() {
          var index = _options.indexWhere((element) => element.id == result.id);
          _options[index] = result;
        });
        return;
      }

      setState(() {
        _options.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = AuthService().user;

    return _loading
        ? const Loading()
        : Scaffold(
            appBar: AppBar(
              title: const Text('Edit a question'),
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
                    onPressed: _updateQuestion,
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
                        initialValue: _text,
                        onChanged: (value) => setState(() => _text = value),
                        validator: (value) => value?.isEmpty == true ? "Please enter a text" : null,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: "Text"),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () => _showModalBottomSheet(context),
                        style: ElevatedButton.styleFrom(primary: Colors.blueGrey),
                        child: const Text("Add options"),
                      ),
                      const SizedBox(height: 10.0),
                      const Text("Options", style: TextStyle(fontSize: 17.0)),
                      const SizedBox(height: 5.0),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _options.length,
                        itemBuilder: (context, index) {
                          var option = _options[index];
                          return ListTile(
                            onTap: () => _showModalBottomSheet(context, option: option, edit: true),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            selectedTileColor: Colors.blueGrey,
                            selected: true,
                            title: Text(
                              "${option.value} ${option.correct ? "(Correct)" : ""}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () => setState(() => _options.removeAt(index)),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(height: 10.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

class _BottomSheetContent extends StatefulWidget {
  final Option? option;
  final bool edit;

  const _BottomSheetContent({this.option, this.edit = false});

  @override
  State<_BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<_BottomSheetContent> {
  final _formKey = GlobalKey<FormState>();
  late final Option _option;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _option);
    }
  }

  @override
  void initState() {
    super.initState();
    _option = Option(
        id: widget.option?.id ?? '',
        value: widget.option?.value ?? '',
        detail: widget.option?.detail ?? '',
        correct: widget.option?.correct ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.edit ? "Edit option" : "Add option",
                    style: const TextStyle(fontSize: 20.0)),
                const SizedBox(height: 10.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _option.value,
                        validator: (value) =>
                            value?.isEmpty == true ? "Please enter a value" : null,
                        onChanged: (value) {
                          setState(() {
                            _option.value = value;
                          });
                        },
                        decoration: const InputDecoration(label: Text("Enter a value")),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        initialValue: _option.detail,
                        onChanged: (value) {
                          setState(() {
                            _option.detail = value;
                          });
                        },
                        maxLines: 2,
                        decoration: const InputDecoration(label: Text("Enter a detail")),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Correct", style: TextStyle(fontSize: 18.0)),
                          Switch(
                            value: _option.correct,
                            onChanged: (value) {
                              setState(() {
                                _option.correct = value;
                              });
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        onPressed: _submit,
                        child: Text(widget.edit ? "Edit option" : "Add option")),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.grey),
                      child: const Text("Cancel"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
