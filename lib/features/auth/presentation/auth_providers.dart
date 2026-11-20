import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => FirebaseAuthRepository());

final uidProvider = StreamProvider<String?>((ref) {
  return ref.watch(authRepositoryProvider).watchUid();
});

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final uid = ref.watch(uidProvider).value;
  if (uid == null) return Stream.value(null);
  return ref.watch(authRepositoryProvider).watchUser(uid);
});

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      if (!isAllowedEmail(email)) {
        throw Exception('Use your IBA email (${allowedDomains.join(' or ')})');
      }
      return ref.read(authRepositoryProvider).signIn(email, password);
    });
  }

  Future<void> signUp(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      if (name.trim().isEmpty) throw Exception('Enter your name');
      if (!isAllowedEmail(email)) {
        throw Exception('Use your IBA email (${allowedDomains.join(' or ')})');
      }
      return ref.read(authRepositoryProvider).signUp(name, email, password);
    });
  }

  Future<void> signOut() => ref.read(authRepositoryProvider).signOut();
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(AuthController.new);
