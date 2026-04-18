// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rcOfferingsHash() => r'a7a8593186350fd24c38f9b1d933f4ae9a89ab00';

/// See also [rcOfferings].
@ProviderFor(rcOfferings)
final rcOfferingsProvider = AutoDisposeFutureProvider<Offerings?>.internal(
  rcOfferings,
  name: r'rcOfferingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rcOfferingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RcOfferingsRef = AutoDisposeFutureProviderRef<Offerings?>;
String _$entitlementNotifierHash() =>
    r'ff7e214dd1de4ce50ff2fdf8678dcc9548204644';

/// See also [EntitlementNotifier].
@ProviderFor(EntitlementNotifier)
final entitlementNotifierProvider =
    AutoDisposeAsyncNotifierProvider<EntitlementNotifier, bool>.internal(
      EntitlementNotifier.new,
      name: r'entitlementNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$entitlementNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EntitlementNotifier = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
