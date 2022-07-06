import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizz_app/services/auth.dart';
import 'package:quizz_app/shared/loading.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;

  void _toggleLoading() {
    setState(() => loading = !loading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Loading()
          : Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/door1.jpg'),
                ),
              ),
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                    child:
                        Container(decoration: BoxDecoration(color: Colors.white.withOpacity(0.0))),
                  ),
                  Column(
                    children: [
                      const Image(
                        image: AssetImage('assets/logo.png'),
                        height: 100,
                        width: 100,
                      ),
                      Text(
                        "Welcome!",
                        style: TextStyle(
                          fontFamily: GoogleFonts.pacifico().fontFamily,
                          fontSize: 60.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        "Get ready to learn more about Morocco",
                        style: TextStyle(fontSize: 18.0),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  LoginButton(
                    text: 'Sign in with Google',
                    icon: FontAwesomeIcons.google,
                    color: Colors.blue,
                    loginMethod: AuthService().googleLogin,
                    changeLoadingState: _toggleLoading,
                  ),
                  LoginButton(
                    text: 'Sign in with Github',
                    icon: FontAwesomeIcons.github,
                    color: const Color.fromARGB(255, 92, 91, 91),
                    loginMethod: AuthService().githubLogin,
                    changeLoadingState: _toggleLoading,
                  ),
                  LoginButton(
                    icon: FontAwesomeIcons.userSecret,
                    text: 'Continue as Guest',
                    color: Colors.deepPurple,
                    loginMethod: AuthService().anonLogin,
                    changeLoadingState: _toggleLoading,
                  ),
                ],
              ),
            ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final Function loginMethod;
  final Function changeLoadingState;

  const LoginButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.loginMethod,
    required this.changeLoadingState,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(20),
        backgroundColor: color,
      ),
      onPressed: () async {
        try {
          changeLoadingState();
          await loginMethod(context);
        } catch (_) {
          changeLoadingState();
        }
      },
      label: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}
