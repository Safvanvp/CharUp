// import 'package:chatup/services/auth/auth_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_login/flutter_login.dart';

// class Register extends StatelessWidget {
//   Register({super.key});

//   final AuthService _authService = AuthService();

//   Future<String?> onLogin(LoginData data) async {
//     try {
//       await _authService.signInWithEmailPassWord(data.name, data.password);
//       return null;
//     } catch (e) {
//       return e.toString();
//     }

//       Future<String?> onSignup(SignupData data) async {
//         try {
//           await _authService.signUpWithEmailPassword(
//             data.name ?? '',
//             data.password ?? '',
//           );
//           return null;
//         } catch (e) {
//           return e.toString();
//         }
//       }
    
//       Future<String?> recoverPassword(String name) async {
//         await Future.delayed(Duration(microseconds: 200));
//         try {
//           // recovery logic here
//           return null;
//         } catch (e) {
//           return e.toString();
//         }
//       }
//     }
  
//     @override
//     Widget build(BuildContext context) {
//       return Scaffold(
//         body: FlutterLogin(
//           onLogin: onLogin,
//           onRecoverPassword: recoverPassword,
//           onSignup: onSignup,
//           hideForgotPasswordButton: true,
//           disableCustomPageTransformer: false,
//           theme: LoginTheme(
//             primaryColor: Colors.teal,
//             cardTheme: const CardTheme(
//               color: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(15.0)),
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//   }
// }
