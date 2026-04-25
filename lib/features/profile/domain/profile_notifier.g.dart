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

String _$userProfileNotifierHash() =>
    r'25afd2d17d07ba8bda5a864688c3d8c852e8add0';

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
