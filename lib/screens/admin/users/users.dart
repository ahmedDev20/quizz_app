import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:quizz_app/models/models.dart';
import 'package:quizz_app/screens/admin/drawer.dart';
import 'package:quizz_app/services/auth.dart';
import 'package:quizz_app/services/db.dart';
import 'package:quizz_app/shared/loading.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _dbService = DBService();
  QuizUser _userData = QuizUser();

  List<QuizUser> _users = [];

  getAllTopics() async {
    var users = await _dbService.getAllUsers() ?? [];
    setState(() => _users = users);
  }

  void _showModalBottomSheet(BuildContext context, QuizUser user) async {
    var result = await showModalBottomSheet<QuizUser>(
      context: context,
      builder: (context) {
        return _BottomSheetContent(user: user);
      },
    );

    if (result != null) {
      setState(() {
        var index = _users.indexWhere((element) => element.uid == result.uid);
        _users[index] = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllTopics();
    getUserData();
  }

  getUserData() async {
    var userData = await DBService().getCurrentUser();
    setState(() {
      _userData = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = AuthService().user;

    return Scaffold(
      drawer: _userData.isAdmin! ? const AdminDrawer() : null,
      appBar: AppBar(
        title: const Text('Manage users'),
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
          future: _dbService.getAllTopics(),
          builder: ((context, snapshot) {
            if (snapshot.hasData && !snapshot.hasError) {
              return RefreshIndicator(
                onRefresh: () {
                  return getAllTopics();
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: _users.isEmpty
                      ? const ListTile(
                          title: Text(
                            "No users at the moment 🙄",
                            style: TextStyle(fontSize: 18.0),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final usr = _users[index];

                            return InkWell(
                              onTap: () {
                                _showModalBottomSheet(context, usr);
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 15.0),
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Text(
                                        user?.displayName == 'Ahmed Balady' ? 'You' : '',
                                        style: const TextStyle(fontSize: 20.0),
                                      ),
                                      const SizedBox(width: 5.0),
                                      usr.isAdmin!
                                          ? const Chip(
                                              label: Text(
                                                "Admin",
                                                style: TextStyle(fontSize: 13.0),
                                              ),
                                              backgroundColor: Colors.deepOrange,
                                            )
                                          : const SizedBox()
                                    ],
                                  ),
                                  subtitle: Text(user?.email ?? ''),
                                  trailing: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    backgroundImage: NetworkImage(
                                      user?.photoURL ??
                                          'https://avatars.dicebear.com/api/adventurer/${user?.uid}.png',
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              );
            } else {
              return const Loading();
            }
          })),
    );
  }
}

class _BottomSheetContent extends StatefulWidget {
  final QuizUser? user;

  const _BottomSheetContent({required this.user});

  @override
  State<_BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<_BottomSheetContent> {
  final _formKey = GlobalKey<FormState>();
  late final QuizUser _user;
  bool loading = false;

  void _showSnackBar(String message, Color color, {Color colorText = Colors.white}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1500),
        backgroundColor: color,
        content: Text(
          message,
          style: TextStyle(color: colorText),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => loading = true);
        await DBService().updateUser(_user);
        // ignore: use_build_context_synchronously
        Navigator.pop(context, _user);
        _showSnackBar("User updated", Colors.green, colorText: Colors.black);
      } catch (_) {
        _showSnackBar("Could no update user", Colors.red, colorText: Colors.black);
        rethrow;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _user = QuizUser(
        uid: widget.user?.uid,
        isAdmin: widget.user?.isAdmin,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = AuthService().user;

    return SizedBox(
      height: 200.0,
      child: loading
          ? const SpinKitCubeGrid(
              color: Colors.white,
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Edit user", style: TextStyle(fontSize: 20.0)),
                      const SizedBox(height: 15.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName as String,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Admin"),
                                Switch(
                                  value: _user.isAdmin!,
                                  onChanged: (value) {
                                    setState(() {
                                      _user.isAdmin = value;
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
                          ElevatedButton(onPressed: _submit, child: const Text("Edit user")),
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
