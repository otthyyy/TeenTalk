import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:teen_talk_app/main.dart';

void main() {
  testWidgets('TeenTalk app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: TeenTalkApp(),
      ),
    );

    // Verify that the app loads with the feed page
    expect(find.text('Feed Page'), findsOneWidget);
    
    // Verify bottom navigation items are present
    expect(find.text('Feed'), findsNWidgets(2)); // Once in nav, once in page
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });
}
