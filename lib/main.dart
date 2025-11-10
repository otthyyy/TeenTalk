import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'src/core/localization/app_localizations.dart';
import 'src/core/providers/crashlytics_provider.dart';
import 'src/core/providers/feed_cache_provider.dart';
import 'src/core/services/feed_cache_service.dart';
import 'src/core/router/app_router.dart';
import 'src/core/services/crashlytics_service.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/theme/theme_provider.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Hive.initFlutter();

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      if (!kIsWeb) {
        FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
      }
    } catch (e) {
      print('Firebase init error: $e');
    }

    final crashlyticsService = CrashlyticsService();
    await crashlyticsService.initialize();

    final feedCacheService = await _initializeFeedCache();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      unawaited(crashlyticsService.recordFlutterError(details));
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(crashlyticsService.recordError(error, stack, fatal: true));
      return true;
    };

    runApp(
      ProviderScope(
        overrides: [
          crashlyticsServiceProvider.overrideWithValue(crashlyticsService),
          if (feedCacheService != null)
            feedCacheServiceProvider.overrideWithValue(feedCacheService),
        ],
        child: const TeenTalkApp(),
      ),
    );
  }, (error, stackTrace) {
    unawaited(
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true),
    );
  });
}

Future<FeedCacheService?> _initializeFeedCache() async {
  try {
    final cacheService = FeedCacheService();
    await cacheService.initialize();
    return cacheService;
  } catch (e) {
    print('Failed to initialize feed cache: $e');
    return null;
  }
}

class TeenTalkApp extends ConsumerWidget {
  const TeenTalkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(crashlyticsSyncProvider);
    
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'TeenTalk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
      ],
    );
  }
}
