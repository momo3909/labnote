import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    String? displayName,
    String? email,
    @Default(true) bool isAnonymous,
  }) = _AppUser;
}
