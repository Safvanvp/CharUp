import 'package:chatup/services/auth/auth_service.dart';
import 'package:chatup/components/my_button.dart';
import 'package:chatup/components/my_textfield.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwordController = TextEditingController();

  //tap to go to register page
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  //login
  void login(BuildContext context) async {
    //auth service
    final authService = AuthService();

    //try to login

    try {
      await authService.signInWithEmailPassWord(
        _emailController.text,
        _pwordController.text,
      );

      //catch any errors
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(e.toString()),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            Container(
              height: 250,
              width: 250,
              child: Image.asset(
                'Images/logo.png',
              ),
            ),

            //wellcome text
            Text("Welcome back, you've been missed!",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                )),
            SizedBox(height: 20),
            //email text field
            MyTextfield(
              hintText: "Email",
              obscureText: false,
              controller: _emailController,
            ),
            SizedBox(height: 15),
            //password text field
            MyTextfield(
              hintText: "Password",
              obscureText: true,
              controller: _pwordController,
            ),
            SizedBox(height: 25),
            //login button
            MyButton(
              text: 'Login',
              onTap: () => login(context),
            ),
            SizedBox(height: 25),

            //register now

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Not a member? ",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    )),
                GestureDetector(
                  onTap: onTap,
                  child: Text("Register now",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
