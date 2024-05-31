import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../SignIn & SignUp/sign_in.dart';
import '../utils/dashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SignInPage();
          }
          return const Dashboard();
        });
  }
}
