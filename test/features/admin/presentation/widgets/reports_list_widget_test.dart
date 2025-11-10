import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/admin/data/models/report.dart';
import 'package:teen_talk_app/src/features/admin/presentation/providers/admin_providers.dart';
import 'package:teen_talk_app/src/features/admin/presentation/widgets/reports_list_widget.dart';

class _FakeReport extends Report {
  const _FakeReport({
    required super.id,
    required super.itemId,
    required super.itemType,
    required super.authorId,
    required super.authorNickname,
    required super.content,
    required super.reason,
    required super.status,
    super.severity,
    required super.createdAt,
    required super.updatedAt,
  });
}

void main() {
  group('ReportsListWidget', () {
    final reports = [
      _FakeReport(
        id: '1',
        itemId: 'post-1',
        itemType: 'post',
        authorId: 'author-1',
        authorNickname: 'Author One',
        content: 'This is a fake post',
        reason: 'Spam',
        status: 'pending',
        severity: 'high',
        createdAt: DateTime(2024, 1, 1, 12, 0),
        updatedAt: DateTime(2024, 1, 1, 13, 0),
      ),
      _FakeReport(
        id: '2',
        itemId: 'comment-2',
        itemType: 'comment',
        authorId: 'author-2',
        authorNickname: 'Author Two',
        content: 'This is a fake comment',
        reason: 'Harassment',
        status: 'resolved',
        severity: 'medium',
        createdAt: DateTime(2024, 1, 2, 10, 0),
        updatedAt: DateTime(2024, 1, 2, 11, 0),
      ),
    ];

    testWidgets('renders reports list and filters', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminReportsProvider.overrideWith((ref, filter) => Future.value(reports)),
          ],
          child: const MaterialApp(
            home: Scaffold(body: ReportsListWidget()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Spam'), findsOneWidget);
      expect(find.text('Harassment'), findsOneWidget);
      expect(find.text('All Status'), findsOneWidget);
      expect(find.text('All Types'), findsOneWidget);
      expect(find.text('All Severity'), findsOneWidget);
    });

    testWidgets('shows quick actions for pending report', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminReportsProvider.overrideWith((ref, filter) => Future.value(reports)),
          ],
          child: const MaterialApp(
            home: Scaffold(body: ReportsListWidget()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Resolve'), findsWidgets);
      expect(find.text('Dismiss'), findsWidgets);
    });

    testWidgets('shows empty state when no reports', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminReportsProvider.overrideWith((ref, filter) => Future.value([])),
          ],
          child: const MaterialApp(
            home: Scaffold(body: ReportsListWidget()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No reports found'), findsOneWidget);
    });
  });
}
