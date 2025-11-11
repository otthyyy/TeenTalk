import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> loadTestFonts() async {
  await loadAppFonts();
}

Widget wrapWithMaterialApp(
  Widget child, {
  ThemeMode themeMode = ThemeMode.light,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
      ),
      home: child,
    ),
  );
}

Widget wrapWithScaffold(Widget child) {
  return Scaffold(
    body: child,
  );
}

Future<void> testGolden(
  WidgetTester tester,
  Widget widget, {
  required String description,
  List<Device> devices = const [Device.phone, Device.tabletLandscape],
  ThemeMode themeMode = ThemeMode.light,
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidgetBuilder(
    wrapWithMaterialApp(widget, themeMode: themeMode, overrides: overrides),
    wrapper: materialAppWrapper(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: themeMode == ThemeMode.light 
              ? Brightness.light 
              : Brightness.dark,
        ),
      ),
    ),
    surfaceSize: devices.first.size,
  );

  await multiScreenGolden(
    tester,
    description,
    devices: devices,
  );
}
