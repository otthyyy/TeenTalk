import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:teen_talk_app/src/common/widgets/trust_badge.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/trust_level.dart';
import 'package:teen_talk_app/src/core/localization/app_localizations.dart';

void main() {
  Widget wrapWithMaterialApp(Widget child) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('it'),
      ],
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('displays newcomer trust badge label', (tester) async {
    await tester.pumpWidget(
      wrapWithMaterialApp(
        const TrustBadge(trustLevel: TrustLevel.newcomer),
      ),
    );

    expect(find.text('Newcomer'), findsOneWidget);
  });

  testWidgets('displays member trust badge label', (tester) async {
    await tester.pumpWidget(
      wrapWithMaterialApp(
        const TrustBadge(trustLevel: TrustLevel.member),
      ),
    );

    expect(find.text('Member'), findsOneWidget);
  });

  testWidgets('displays trusted trust badge label', (tester) async {
    await tester.pumpWidget(
      wrapWithMaterialApp(
        const TrustBadge(trustLevel: TrustLevel.trusted),
      ),
    );

    expect(find.text('Trusted'), findsOneWidget);
  });

  testWidgets('displays veteran trust badge label', (tester) async {
    await tester.pumpWidget(
      wrapWithMaterialApp(
        const TrustBadge(trustLevel: TrustLevel.veteran),
      ),
    );

    expect(find.text('Veteran'), findsOneWidget);
  });

  testWidgets('hides label when showLabel is false', (tester) async {
    await tester.pumpWidget(
      wrapWithMaterialApp(
        const TrustBadge(
          trustLevel: TrustLevel.member,
          showLabel: false,
        ),
      ),
    );

    expect(find.text('Member'), findsNothing);
  });
}
