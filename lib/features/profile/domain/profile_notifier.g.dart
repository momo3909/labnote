// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentProfileHash() => r'9b63799891e382f4fb838bc5a65ba7eb1703636b';

/// 現在ログイン中ユーザーのプロフィールを監視する
///
/// Copied from [currentProfile].
@ProviderFor(currentProfile)
final currentProfileProvider = AutoDisposeFutureProvider<UserProfile?>.internal(
  currentProfile,
  name: r'currentProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentProfileRef = AutoDisposeFutureProviderRef<UserProfile?>;
String _$userRankingHash() => r'86508ada2a0a7eb721bce8eec234b91f5ba6bc60';

/// ユーザーランキング（いいね数降順）
///
/// Copied from [userRanking].
@ProviderFor(userRanking)
final userRankingProvider =
    AutoDisposeFutureProvider<List<UserProfile>>.internal(
      userRanking,
      name: r'userRankingProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userRankingHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRankingRef = AutoDisposeFutureProviderRef<List<UserProfile>>;
String _$ownTemplatesHash() => r'32338b744e016a03235c810f58c7e5f692bb4e69';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 特定ユーザーが投稿したギャラリーテンプレート一覧
///
/// Copied from [ownTemplates].
@ProviderFor(ownTemplates)
const ownTemplatesProvider = OwnTemplatesFamily();

/// 特定ユーザーが投稿したギャラリーテンプレート一覧
///
/// Copied from [ownTemplates].
class OwnTemplatesFamily extends Family<AsyncValue<List<GalleryTemplate>>> {
  /// 特定ユーザーが投稿したギャラリーテンプレート一覧
  ///
  /// Copied from [ownTemplates].
  const OwnTemplatesFamily();

  /// 特定ユーザーが投稿したギャラリーテンプレート一覧
  ///
  /// Copied from [ownTemplates].
  OwnTemplatesProvider call(String uid) {
    return OwnTemplatesProvider(uid);
  }

  @override
  OwnTemplatesProvider getProviderOverride(
    covariant OwnTemplatesProvider provider,
  ) {
    return call(provider.uid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'ownTemplatesProvider';
}

/// 特定ユーザーが投稿したギャラリーテンプレート一覧
///
/// Copied from [ownTemplates].
class OwnTemplatesProvider
    extends AutoDisposeFutureProvider<List<GalleryTemplate>> {
  /// 特定ユーザーが投稿したギャラリーテンプレート一覧
  ///
  /// Copied from [ownTemplates].
  OwnTemplatesProvider(String uid)
    : this._internal(
        (ref) => ownTemplates(ref as OwnTemplatesRef, uid),
        from: ownTemplatesProvider,
        name: r'ownTemplatesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$ownTemplatesHash,
        dependencies: OwnTemplatesFamily._dependencies,
        allTransitiveDependencies:
            OwnTemplatesFamily._allTransitiveDependencies,
        uid: uid,
      );

  OwnTemplatesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uid,
  }) : super.internal();

  final String uid;

  @override
  Override overrideWith(
    FutureOr<List<GalleryTemplate>> Function(OwnTemplatesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OwnTemplatesProvider._internal(
        (ref) => create(ref as OwnTemplatesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uid: uid,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<GalleryTemplate>> createElement() {
    return _OwnTemplatesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OwnTemplatesProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OwnTemplatesRef on AutoDisposeFutureProviderRef<List<GalleryTemplate>> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _OwnTemplatesProviderElement
    extends AutoDisposeFutureProviderElement<List<GalleryTemplate>>
    with OwnTemplatesRef {
  _OwnTemplatesProviderElement(super.provider);

  @override
  String get uid => (origin as OwnTemplatesProvider).uid;
}

String _$followingProfilesHash() => r'b6c62ad553a443df776ac13cfd3fac3ba0606750';

/// See also [followingProfiles].
@ProviderFor(followingProfiles)
const followingProfilesProvider = FollowingProfilesFamily();

/// See also [followingProfiles].
class FollowingProfilesFamily extends Family<AsyncValue<List<UserProfile>>> {
  /// See also [followingProfiles].
  const FollowingProfilesFamily();

  /// See also [followingProfiles].
  FollowingProfilesProvider call(String uid) {
    return FollowingProfilesProvider(uid);
  }

  @override
  FollowingProfilesProvider getProviderOverride(
    covariant FollowingProfilesProvider provider,
  ) {
    return call(provider.uid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'followingProfilesProvider';
}

/// See also [followingProfiles].
class FollowingProfilesProvider
    extends AutoDisposeFutureProvider<List<UserProfile>> {
  /// See also [followingProfiles].
  FollowingProfilesProvider(String uid)
    : this._internal(
        (ref) => followingProfiles(ref as FollowingProfilesRef, uid),
        from: followingProfilesProvider,
        name: r'followingProfilesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$followingProfilesHash,
        dependencies: FollowingProfilesFamily._dependencies,
        allTransitiveDependencies:
            FollowingProfilesFamily._allTransitiveDependencies,
        uid: uid,
      );

  FollowingProfilesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uid,
  }) : super.internal();

  final String uid;

  @override
  Override overrideWith(
    FutureOr<List<UserProfile>> Function(FollowingProfilesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FollowingProfilesProvider._internal(
        (ref) => create(ref as FollowingProfilesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uid: uid,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<UserProfile>> createElement() {
    return _FollowingProfilesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FollowingProfilesProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FollowingProfilesRef on AutoDisposeFutureProviderRef<List<UserProfile>> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _FollowingProfilesProviderElement
    extends AutoDisposeFutureProviderElement<List<UserProfile>>
    with FollowingProfilesRef {
  _FollowingProfilesProviderElement(super.provider);

  @override
  String get uid => (origin as FollowingProfilesProvider).uid;
}

String _$followerProfilesHash() => r'f48cc99628654ce034809ec7bae0884aea58e557';

/// See also [followerProfiles].
@ProviderFor(followerProfiles)
const followerProfilesProvider = FollowerProfilesFamily();

/// See also [followerProfiles].
class FollowerProfilesFamily extends Family<AsyncValue<List<UserProfile>>> {
  /// See also [followerProfiles].
  const FollowerProfilesFamily();

  /// See also [followerProfiles].
  FollowerProfilesProvider call(String uid) {
    return FollowerProfilesProvider(uid);
  }

  @override
  FollowerProfilesProvider getProviderOverride(
    covariant FollowerProfilesProvider provider,
  ) {
    return call(provider.uid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'followerProfilesProvider';
}

/// See also [followerProfiles].
class FollowerProfilesProvider
    extends AutoDisposeFutureProvider<List<UserProfile>> {
  /// See also [followerProfiles].
  FollowerProfilesProvider(String uid)
    : this._internal(
        (ref) => followerProfiles(ref as FollowerProfilesRef, uid),
        from: followerProfilesProvider,
        name: r'followerProfilesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$followerProfilesHash,
        dependencies: FollowerProfilesFamily._dependencies,
        allTransitiveDependencies:
            FollowerProfilesFamily._allTransitiveDependencies,
        uid: uid,
      );

  FollowerProfilesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uid,
  }) : super.internal();

  final String uid;

  @override
  Override overrideWith(
    FutureOr<List<UserProfile>> Function(FollowerProfilesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FollowerProfilesProvider._internal(
        (ref) => create(ref as FollowerProfilesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uid: uid,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<UserProfile>> createElement() {
    return _FollowerProfilesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FollowerProfilesProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FollowerProfilesRef on AutoDisposeFutureProviderRef<List<UserProfile>> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _FollowerProfilesProviderElement
    extends AutoDisposeFutureProviderElement<List<UserProfile>>
    with FollowerProfilesRef {
  _FollowerProfilesProviderElement(super.provider);

  @override
  String get uid => (origin as FollowerProfilesProvider).uid;
}

String _$isFollowingHash() => r'25f29fae81ff3918c84427e02cf33be20c445d65';

/// 現在ユーザーが targetUid をフォローしているか
///
/// Copied from [isFollowing].
@ProviderFor(isFollowing)
const isFollowingProvider = IsFollowingFamily();

/// 現在ユーザーが targetUid をフォローしているか
///
/// Copied from [isFollowing].
class IsFollowingFamily extends Family<AsyncValue<bool>> {
  /// 現在ユーザーが targetUid をフォローしているか
  ///
  /// Copied from [isFollowing].
  const IsFollowingFamily();

  /// 現在ユーザーが targetUid をフォローしているか
  ///
  /// Copied from [isFollowing].
  IsFollowingProvider call(String targetUid) {
    return IsFollowingProvider(targetUid);
  }

  @override
  IsFollowingProvider getProviderOverride(
    covariant IsFollowingProvider provider,
  ) {
    return call(provider.targetUid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isFollowingProvider';
}

/// 現在ユーザーが targetUid をフォローしているか
///
/// Copied from [isFollowing].
class IsFollowingProvider extends AutoDisposeFutureProvider<bool> {
  /// 現在ユーザーが targetUid をフォローしているか
  ///
  /// Copied from [isFollowing].
  IsFollowingProvider(String targetUid)
    : this._internal(
        (ref) => isFollowing(ref as IsFollowingRef, targetUid),
        from: isFollowingProvider,
        name: r'isFollowingProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isFollowingHash,
        dependencies: IsFollowingFamily._dependencies,
        allTransitiveDependencies: IsFollowingFamily._allTransitiveDependencies,
        targetUid: targetUid,
      );

  IsFollowingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.targetUid,
  }) : super.internal();

  final String targetUid;

  @override
  Override overrideWith(
    FutureOr<bool> Function(IsFollowingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsFollowingProvider._internal(
        (ref) => create(ref as IsFollowingRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        targetUid: targetUid,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _IsFollowingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsFollowingProvider && other.targetUid == targetUid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, targetUid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsFollowingRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `targetUid` of this provider.
  String get targetUid;
}

class _IsFollowingProviderElement extends AutoDisposeFutureProviderElement<bool>
    with IsFollowingRef {
  _IsFollowingProviderElement(super.provider);

  @override
  String get targetUid => (origin as IsFollowingProvider).targetUid;
}

String _$followingFeedHash() => r'5f9c98dcd1a842a71ff73582ea48c9d5a49a2fd8';

/// フォロー中ユーザーの投稿テンプレート一覧
///
/// Copied from [followingFeed].
@ProviderFor(followingFeed)
final followingFeedProvider =
    AutoDisposeFutureProvider<List<GalleryTemplate>>.internal(
      followingFeed,
      name: r'followingFeedProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$followingFeedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FollowingFeedRef = AutoDisposeFutureProviderRef<List<GalleryTemplate>>;
String _$userProfileNotifierHash() =>
    r'ff3535ebb8a2a9fa873fe80e0c8114f95dd9ec72';

abstract class _$UserProfileNotifier
    extends BuildlessAutoDisposeAsyncNotifier<UserProfile?> {
  late final String uid;

  FutureOr<UserProfile?> build(String uid);
}

/// 自分のプロフィール編集用 Notifier
///
/// Copied from [UserProfileNotifier].
@ProviderFor(UserProfileNotifier)
const userProfileNotifierProvider = UserProfileNotifierFamily();

/// 自分のプロフィール編集用 Notifier
///
/// Copied from [UserProfileNotifier].
class UserProfileNotifierFamily extends Family<AsyncValue<UserProfile?>> {
  /// 自分のプロフィール編集用 Notifier
  ///
  /// Copied from [UserProfileNotifier].
  const UserProfileNotifierFamily();

  /// 自分のプロフィール編集用 Notifier
  ///
  /// Copied from [UserProfileNotifier].
  UserProfileNotifierProvider call(String uid) {
    return UserProfileNotifierProvider(uid);
  }

  @override
  UserProfileNotifierProvider getProviderOverride(
    covariant UserProfileNotifierProvider provider,
  ) {
    return call(provider.uid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userProfileNotifierProvider';
}

/// 自分のプロフィール編集用 Notifier
///
/// Copied from [UserProfileNotifier].
class UserProfileNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          UserProfileNotifier,
          UserProfile?
        > {
  /// 自分のプロフィール編集用 Notifier
  ///
  /// Copied from [UserProfileNotifier].
  UserProfileNotifierProvider(String uid)
    : this._internal(
        () => UserProfileNotifier()..uid = uid,
        from: userProfileNotifierProvider,
        name: r'userProfileNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userProfileNotifierHash,
        dependencies: UserProfileNotifierFamily._dependencies,
        allTransitiveDependencies:
            UserProfileNotifierFamily._allTransitiveDependencies,
        uid: uid,
      );

  UserProfileNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uid,
  }) : super.internal();

  final String uid;

  @override
  FutureOr<UserProfile?> runNotifierBuild(
    covariant UserProfileNotifier notifier,
  ) {
    return notifier.build(uid);
  }

  @override
  Override overrideWith(UserProfileNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: UserProfileNotifierProvider._internal(
        () => create()..uid = uid,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uid: uid,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<UserProfileNotifier, UserProfile?>
  createElement() {
    return _UserProfileNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileNotifierProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserProfileNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<UserProfile?> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _UserProfileNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          UserProfileNotifier,
          UserProfile?
        >
    with UserProfileNotifierRef {
  _UserProfileNotifierProviderElement(super.provider);

  @override
  String get uid => (origin as UserProfileNotifierProvider).uid;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
