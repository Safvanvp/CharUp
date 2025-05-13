import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  //instance of the Auth

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //get current user

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  //

  //sign in

  Future<UserCredential> signInWithEmailPassWord(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      //save user info if it does not exist
      _firestore.collection('Users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': email.split('@')[0],
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  //sign up

  Future<UserCredential> signUpWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //save user info in a saprate doc
      _firestore.collection('Users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': email.split('@')[0],
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  //sign in with google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Begin the interactive sign-in process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      // User cancelled the sign-in
      if (gUser == null) return null;

      // Obtain auth details from the request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in with Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Get user
      final User? user = userCredential.user;

      if (user != null) {
        // Check if user exists in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // Save new user to Firestore
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .set({
            'uid': user.uid,
            'email': user.email,
            'name': user.displayName ?? user.email?.split('@')[0],
            'photoUrl': user.photoURL,
          });
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(getErrorMessage(e.code));
    } catch (e) {
      throw Exception(
          "An error occurred during Google sign-in: ${e.toString()}");
    }
  }

  //sign out

  Future<void> signOut() async {
    await _auth.signOut();
  }

  //errors
  String getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'An undefined Error happened.';
    }
  }
}
