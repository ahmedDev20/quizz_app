import 'package:flutter/material.dart';
import 'package:quizz_app/services/auth.dart';

class AdminDrawer extends StatefulWidget {
  const AdminDrawer({Key? key}) : super(key: key);

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.deepOrange,
            ),
            child: Column(
              children: const [
                Image(
                  height: 80,
                  width: 80,
                  image: AssetImage('assets/logo.png'),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  'Welcome!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Users'),
            onTap: () => Navigator.pushReplacementNamed(context, '/admin/users'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.topic),
            title: const Text('Topics'),
            onTap: () => Navigator.pushReplacementNamed(context, '/admin/topics'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text('Quizzes'),
            onTap: () => Navigator.pushReplacementNamed(context, '/admin/quizzes'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.question_mark),
            title: const Text('Questions'),
            onTap: () => Navigator.pushReplacementNamed(context, '/admin/questions'),
          ),
          Expanded(child: Container()),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: ListTile(
              onTap: () async {
                await _auth.signOut();
              },
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Logout"),
            ),
          )
        ],
      ),
    );
  }
}
