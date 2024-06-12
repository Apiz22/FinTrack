import 'package:FinTrack/SignIn%20&%20SignUp/sign_in.dart';
import 'package:FinTrack/SignIn%20&%20SignUp/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
//initailly show login page
  bool showLoginPage = true;

  //toggle between login and register page
  void tooglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return SignInPage(
        onTap: tooglePages,
      );
    } else {
      return SignUpPage(
        onTap: tooglePages,
      );
    }
    // return registerpage;
  }
}
