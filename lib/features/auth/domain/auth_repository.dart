import 'app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  Future<AppUser> signInAnonymously();
  Future<void> linkWithApple();
  Future<void> linkWithGoogle();
  Future<void> signOut();
}
