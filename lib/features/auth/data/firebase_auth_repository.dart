import 'package:firebase_auth/firebase_auth.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Stream<AppUser?> get authStateChanges =>
      _auth.authStateChanges().map((user) => user == null ? null : _toAppUser(user));

  @override
  Future<AppUser> signInAnonymously() async {
    final result = await _auth.signInAnonymously();
    return _toAppUser(result.user!);
  }

  @override
  Future<void> linkWithApple() => throw UnimplementedError('v2で実装');

  @override
  Future<void> linkWithGoogle() => throw UnimplementedError('v2で実装');

  @override
  Future<void> signOut() => _auth.signOut();

  AppUser _toAppUser(User user) => AppUser(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        isAnonymous: user.isAnonymous,
      );
}
