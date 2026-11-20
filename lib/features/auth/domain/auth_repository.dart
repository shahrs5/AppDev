import 'app_user.dart';

const allowedDomains = ['iba.edu.pk', 'khi.iba.edu.pk'];

bool isAllowedEmail(String email) {
  final e = email.trim().toLowerCase();
  return allowedDomains.any((d) => e.endsWith('@$d'));
}

abstract class AuthRepository {
  Stream<String?> watchUid();

  Stream<AppUser?> watchUser(String uid);

  Future<void> signIn(String email, String password);

  Future<void> signUp(String name, String email, String password);

  Future<void> signOut();
}
