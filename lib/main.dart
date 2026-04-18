import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/paywall/domain/entitlement_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase初期化（GoogleService-Info.plist 設定後に有効になる）
  try {
    await Firebase.initializeApp();
    await FirebaseAuthRepository().signInAnonymously();
  } catch (_) {}

  // RevenueCat初期化（API key設定後に有効になる）
  try {
    await initRevenueCat();
  } catch (_) {}

  runApp(const ProviderScope(child: LabNoteApp()));
}

class LabNoteApp extends StatelessWidget {
  const LabNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LabNote',
      theme: appTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
