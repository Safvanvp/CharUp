import 'package:chatup/services/auth/auth_service.dart';
import 'package:chatup/components/my_button.dart';
import 'package:chatup/components/my_textfield.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwordController = TextEditingController();
  final TextEditingController _confirmPwordController = TextEditingController();

  //tap to go to login page
  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  void register(BuildContext context) async {
    final _auth = AuthService();

    if (_pwordController.text == _confirmPwordController.text) {
      try {
        _auth.signUpWithEmailPassword(
            _emailController.text, _pwordController.text);
      } catch (e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(e.toString()),
                ));
      }
    }
    //password does not match
    else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Passwords do not match!"),
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
            Text("Let's create an account for you!",
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
              obscureText: false,
              controller: _pwordController,
            ),
            SizedBox(height: 15),
            //confirm password text field
            MyTextfield(
              hintText: "Confirm Password",
              obscureText: true,
              controller: _confirmPwordController,
            ),
            SizedBox(height: 25),

            //register button
            MyButton(
              text: 'Register',
              onTap: () => register(context),
            ),
            SizedBox(height: 25),

            //login now

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Allready a member? ",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    )),
                GestureDetector(
                  onTap: onTap,
                  child: Text("Login now",
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
