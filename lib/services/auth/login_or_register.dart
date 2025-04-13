import 'package:chatup/pages/login_page.dart';
import 'package:chatup/pages/register_page.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  //intialy set to login
  bool showLoginPAge = true;
  //toggle between login and register
  void togglPages() {
    setState(() {
      showLoginPAge = !showLoginPAge;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPAge) {
      return LoginPage(
        onTap: togglPages,
      );
    } else {
      return RegisterPage(
        onTap: togglPages,
      );
    }
  }
}
