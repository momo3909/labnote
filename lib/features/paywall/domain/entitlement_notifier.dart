import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entitlement_notifier.g.dart';

const _entitlementId = 'pro';

// RevenueCat API key (iOS)
const _rcApiKeyIos = 'YOUR_REVENUECAT_IOS_API_KEY';

@riverpod
class EntitlementNotifier extends _$EntitlementNotifier {
  @override
  Future<bool> build() async {
    return _fetchIsPro();
  }

  Future<bool> _fetchIsPro() async {
    if (kDebugMode) return true;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(_entitlementId);
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchIsPro);
  }

  Future<bool> purchase(Package package) async {
    if (kDebugMode) {
      state = const AsyncData(true);
      return true;
    }
    try {
      final info = await Purchases.purchasePackage(package);
      final isPro = info.entitlements.active.containsKey(_entitlementId);
      state = AsyncData(isPro);
      return isPro;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) return false;
      rethrow;
    }
  }

  Future<bool> restore() async {
    try {
      final info = await Purchases.restorePurchases();
      final isPro = info.entitlements.active.containsKey(_entitlementId);
      state = AsyncData(isPro);
      return isPro;
    } catch (_) {
      return false;
    }
  }
}

@riverpod
Future<Offerings?> rcOfferings(Ref ref) async {
  try {
    return await Purchases.getOfferings();
  } catch (_) {
    return null;
  }
}

Future<void> initRevenueCat() async {
  await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);
  final config = PurchasesConfiguration(_rcApiKeyIos);
  await Purchases.configure(config);
}
