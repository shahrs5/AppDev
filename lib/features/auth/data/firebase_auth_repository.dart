import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  @override
  Stream<String?> watchUid() => _auth.authStateChanges().map((u) => u?.uid);

  @override
  Stream<AppUser?> watchUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return AppUser(
        uid: doc.id,
        name: data['name'] as String? ?? '',
        email: data['email'] as String? ?? '',
        role: data['role'] as String? ?? 'student',
      );
    });
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? e.code);
    }
  }

  @override
  Future<void> signUp(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': 'student',
      });
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? e.code);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
