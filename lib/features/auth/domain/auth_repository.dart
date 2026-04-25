import 'app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  Future<AppUser> signInAnonymously();
  Future<AppUser> signInWithGoogle();
  Future<void> signOut();
}
