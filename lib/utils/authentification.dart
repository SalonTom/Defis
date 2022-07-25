import 'package:firebase_auth/firebase_auth.dart';

class Authentification {
  final FirebaseAuth _authentificationFirebase = FirebaseAuth.instance;

  Future<String> connexion(String username, String password) async {
    UserCredential data = await _authentificationFirebase.signInWithEmailAndPassword(email: username, password: password);
    return '${data.user?.uid}';
  }

  Future<String> inscription(String username, String password) async {
    UserCredential data = await _authentificationFirebase.createUserWithEmailAndPassword(email: username, password: password);
    return '${data.user?.uid}';
  }

  Future<void> deconnexion() async {
    await _authentificationFirebase.signOut();
  }

  Future<User?> lireUtilisateur() async {
    return _authentificationFirebase.currentUser;
  }
}