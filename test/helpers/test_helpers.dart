import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget createTestApp(
  Widget child, {
  double textScaleFactor = 1.0,
  ThemeMode themeMode = ThemeMode.light,
  bool wrapInScaffold = true,
}) {
  return ProviderScope(
    child: MediaQuery(
      data: MediaQueryData(
        textScaleFactor: textScaleFactor,
        size: const Size(400, 800),
      ),
      child: MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: themeMode,
        home: wrapInScaffold
            ? Scaffold(
                body: SingleChildScrollView(
                  child: child,
                ),
              )
            : child,
      ),
    ),
  );
}
