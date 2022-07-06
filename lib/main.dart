import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:quizz_app/firebase_options.dart';
import 'package:quizz_app/models/models.dart';
import 'package:quizz_app/routes.dart';
import 'package:quizz_app/screens/auth/login.dart';
import 'package:quizz_app/services/db.dart';
import 'package:quizz_app/shared/loading.dart';
import 'package:quizz_app/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _initialization =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(home: Loading());
          } else if (snapshot.connectionState == ConnectionState.done) {
            return StreamProvider(
              initialData: Report(),
              create: (_) => DBService().streamReport(),
              catchError: (_, err) => Report(),
              child: MaterialApp(
                initialRoute: "/",
                debugShowCheckedModeBanner: false,
                routes: appRoutes,
                theme: appTheme,
              ),
            );
          } else {
            return const MaterialApp(home: LoginScreen());
          }
        });
  }
}
