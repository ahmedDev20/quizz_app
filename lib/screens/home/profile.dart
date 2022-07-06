import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_app/models/models.dart';
import 'package:quizz_app/screens/auth/login.dart';
import 'package:quizz_app/services/auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    Report report = Provider.of<Report>(context);
    var user = AuthService().user;

    if (user != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(user.displayName ?? 'Guest'),
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(top: 50),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3.0),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      user.photoURL ??
                          'https://avatars.dicebear.com/api/adventurer/${user.uid}.png',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Text(user.displayName ?? 'Guest', style: Theme.of(context).textTheme.headline6),
              const SizedBox(
                height: 30.0,
              ),
              Text('Quizzes Completed', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10.0),
              Text("${report.total}", style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              ElevatedButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.deepOrange,
                ),
                onPressed: () async {
                  await AuthService().signOut();
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  }
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      );
    } else {
      return const LoginScreen();
    }
  }
}
