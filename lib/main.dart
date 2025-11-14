import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'src/core/localization/app_localizations.dart';
import 'src/core/providers/crashlytics_provider.dart';
import 'src/core/providers/feed_cache_provider.dart';
import 'src/core/router/app_router.dart';
import 'src/core/services/crashlytics_service.dart';
import 'src/core/services/feed_cache_service.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/theme/theme_provider.dart';
import 'src/core/widgets/crashlytics_listener.dart';
import 'src/features/notifications/presentation/providers/push_notification_handler_provider.dart';
import 'src/features/screenshot_protection/presentation/widgets/screenshot_protected_content.dart';
import 'src/services/push_notifications_listener.dart';
import 'src/services/push_notifications_provider.dart';

const _firebaseOptionsHelpMessage = 'Firebase configuration is missing or still uses placeholder values. '
    'Update lib/firebase_options.dart with real credentials (see README.md and SECURITY_NOTICE.md).';

bool _firebaseOptionsContainPlaceholders(FirebaseOptions options) {
  return options.apiKey.startsWith('YOUR_') ||
      options.projectId == 'your-project-id';
}

/// Background message handler for Firebase Cloud Messaging
/// Must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final logger = Logger();
  final options = DefaultFirebaseOptions.currentPlatform;

  if (_firebaseOptionsContainPlaceholders(options)) {
    logger.w('Skipping Firebase background initialization: $_firebaseOptionsHelpMessage');
    return;
  }

  await Firebase.initializeApp(options: options);
  logger.i('Handling background message: ${message.messageId}');
  logger.d('Message data: ${message.data}');
  logger.d('Message notification: ${message.notification?.title}');
}

Future<void> main() async {
  final crashlyticsService = CrashlyticsService();

  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Hive.initFlutter();

    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      
      if (_firebaseOptionsContainPlaceholders(options)) {
        print('⚠️ WARNING: $_firebaseOptionsHelpMessage');
        if (!kIsWeb) {
          throw Exception(_firebaseOptionsHelpMessage);
        }
      }
      
      await Firebase.initializeApp(options: options);

      if (!kIsWeb) {
        FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
      }
    } catch (e) {
      print('Firebase init error: $e');
    }

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await crashlyticsService.initialize();

    final feedCacheService = await _initializeFeedCache();
    // Initialize SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exception}');
      debugPrintStack(stackTrace: details.stack);
      unawaited(crashlyticsService.recordFlutterError(details));
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Platform error: $error');
      debugPrintStack(stackTrace: stack);
      unawaited(crashlyticsService.recordError(error, stack, fatal: true));
      return true;
    };

    runApp(
      ProviderScope(
        overrides: [
          crashlyticsServiceProvider.overrideWithValue(crashlyticsService),
          if (feedCacheService != null)
            feedCacheServiceProvider.overrideWithValue(feedCacheService),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const TeenTalkApp(),
      ),
    );
  }, (error, stackTrace) {
    if (kIsWeb) return;
    unawaited(
      crashlyticsService.recordError(error, stackTrace, fatal: true),
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

class TeenTalkApp extends ConsumerStatefulWidget {
  const TeenTalkApp({super.key});

  @override
  ConsumerState<TeenTalkApp> createState() => _TeenTalkAppState();
}

class _TeenTalkAppState extends ConsumerState<TeenTalkApp> {
  @override
  void initState() {
    super.initState();
    _initializePushNotifications();
  }

  Future<void> _initializePushNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    final router = ref.read(routerProvider);
    final pushHandler = ref.read(pushNotificationHandlerProvider);
    
    pushHandler.initialize(router);
    
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      await pushHandler.handleInitialMessage(initialMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return CrashlyticsListener(
      child: PushNotificationsListener(
        child: ScreenshotProtectedContent(
          child: MaterialApp.router(
            title: 'TeenTalk',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: router,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('es', ''),
              Locale('it', ''),
            ],
          ),
        ),
      ),
    );
  }
}
