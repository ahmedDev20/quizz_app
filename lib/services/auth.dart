import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:github_sign_in/github_sign_in.dart';
import 'package:quizz_app/models/models.dart';
import 'package:quizz_app/services/db.dart';

class AuthService {
  final userStream = FirebaseAuth.instance.authStateChanges();
  final user = FirebaseAuth.instance.currentUser;

  final String _clientID = 'de803ed2d01b39983528';
  final String _clientSecret = 'f9a2682d7ac3460eb1e468ec5e0a3c4491e31dc9';

  Future<UserCredential?> anonLogin(context) async {
    try {
      return await FirebaseAuth.instance.signInAnonymously();
    } on FirebaseAuthException catch (_) {
      rethrow;
    }
  }

  Future<void> googleLogin(context) async {
    try {
      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      var result = await FirebaseAuth.instance.signInWithCredential(authCredential);

      if (result.user != null) {
        var user = QuizUser(uid: result.user?.uid);
        await DBService().updateUser(user);
      }
    } on FirebaseAuthException catch (_) {
      rethrow;
    }
  }

  Future<UserCredential?> githubLogin(context) async {
    final GitHubSignIn gitHubSignIn = GitHubSignIn(
        clientId: _clientID,
        clientSecret: _clientSecret,
        redirectUrl: 'https://quiz-app-be632.firebaseapp.com/__/auth/handler');

    final result = await gitHubSignIn.signIn(context);

    // Create a credential from the access token
    final githubAuthCredential = GithubAuthProvider.credential(result.token ?? '');

    // Once signed in, return the UserCredential
    var credentials = await FirebaseAuth.instance.signInWithCredential(githubAuthCredential);

    if (credentials.user != null) {
      var user = QuizUser(uid: credentials.user?.uid);
      await DBService().updateUser(user);
    }

    return credentials;
  }

  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
