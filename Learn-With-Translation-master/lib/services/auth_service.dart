import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //log in method
  Future<dynamic> signIn(String email, String password) async {
    try {
      var user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return user.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "User not found";
      } else if (e.code == 'invalid-email') {
        return 'Wrong email provided for that user.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
    } catch (e) {
      print(" hata: $e");
    }
  }

  //log out method
  signOut() async {
    return await _auth.signOut();
  }

  //register method
  Future<dynamic> createPerson(
      String name, String email, String password) async {
    try {
      var user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _firestore
          .collection("users")
          .doc(user.user!.uid)
          .set({'username': name, 'email': email, 'dailygoal':5, 'score':0,});

      return user.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
    } catch (e) {
      print(e);
    }
  }

  //log in method
  Future<dynamic> getCurrentUser(String email, String password) async {
    var user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      null;
    }
  }
}
