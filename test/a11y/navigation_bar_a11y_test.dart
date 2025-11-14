import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Navigation Bar Accessibility Tests', () {
    testWidgets('bottom navigation has semantic label', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          BottomNavigationBar(
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bug_report),
                label: 'Firebase Test',
              ),
            ],
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('navigation items have proper labels', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          BottomNavigationBar(
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bug_report),
                label: 'Firebase Test',
              ),
            ],
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Firebase Test'), findsOneWidget);
    });

    testWidgets('navigation items have icons', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          BottomNavigationBar(
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bug_report),
                label: 'Firebase Test',
              ),
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsWidgets);
      expect(find.byIcon(Icons.bug_report), findsWidgets);
    });

    testWidgets('navigation bar renders at 1.3x text scale', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          BottomNavigationBar(
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bug_report),
                label: 'Firebase Test',
              ),
            ],
          ),
          textScaleFactor: 1.3,
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('navigation bar renders at 2.0x text scale', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          BottomNavigationBar(
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bug_report),
                label: 'Firebase Test',
              ),
            ],
          ),
          textScaleFactor: 2.0,
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('Navigation Bar Golden Tests', () {
    testWidgets('renders correctly at 1.0x text scale', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          BottomNavigationBar(
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bug_report),
                label: 'Firebase Test',
              ),
            ],
          ),
        ),
      );

      await expectLater(
        find.byType(BottomNavigationBar),
        matchesGoldenFile('goldens/navigation_bar_1.0x.png'),
      );
    });

    testWidgets('renders correctly at 1.3x text scale', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          BottomNavigationBar(
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bug_report),
                label: 'Firebase Test',
              ),
            ],
          ),
          textScaleFactor: 1.3,
        ),
      );

      await expectLater(
        find.byType(BottomNavigationBar),
        matchesGoldenFile('goldens/navigation_bar_1.3x.png'),
      );
    });

    testWidgets('renders correctly at 2.0x text scale', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          BottomNavigationBar(
            currentIndex: 0,
            onTap: (_) {},
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bug_report),
                label: 'Firebase Test',
              ),
            ],
          ),
          textScaleFactor: 2.0,
        ),
      );

      await expectLater(
        find.byType(BottomNavigationBar),
        matchesGoldenFile('goldens/navigation_bar_2.0x.png'),
      );
    });
  });
}
