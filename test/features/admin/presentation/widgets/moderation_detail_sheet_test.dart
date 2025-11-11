import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/admin/data/models/report.dart';
import 'package:teen_talk_app/src/features/admin/presentation/providers/admin_providers.dart';
import 'package:teen_talk_app/src/features/admin/presentation/widgets/moderation_detail_sheet.dart';

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
  group('ModerationDetailSheet', () {
    final report = _FakeReport(
      id: '1',
      itemId: 'post-1',
      itemType: 'post',
      authorId: 'author-1',
      authorNickname: 'Test User',
      content: 'This is a fake post',
      reason: 'Spam',
      status: 'pending',
      severity: 'high',
      createdAt: DateTime(2024, 1, 1, 12, 0),
      updatedAt: DateTime(2024, 1, 1, 13, 0),
    );

    final reportedContent = {
      'content': 'Suspicious post content',
      'authorNickname': 'Test User',
      'createdAt': '2024-01-01T12:00:00.000',
      'topicName': 'General',
      'commentCount': 5,
    };

    testWidgets('renders report details and tabs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reportedContentProvider.overrideWith(
              (ref, request) => Future.value(reportedContent),
            ),
            moderationDecisionsProvider.overrideWith(
              (ref, reportId) => Future.value([]),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ModerationDetailSheet(report: report),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Report Details'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('displays report information', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reportedContentProvider.overrideWith(
              (ref, request) => Future.value(reportedContent),
            ),
            moderationDecisionsProvider.overrideWith(
              (ref, reportId) => Future.value([]),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ModerationDetailSheet(report: report),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('POST • PENDING'), findsOneWidget);
      expect(find.text('Spam'), findsWidgets);
    });

    testWidgets('shows action bar for pending reports', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reportedContentProvider.overrideWith(
              (ref, request) => Future.value(reportedContent),
            ),
            moderationDecisionsProvider.overrideWith(
              (ref, reportId) => Future.value([]),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ModerationDetailSheet(report: report),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Apply Decision'), findsOneWidget);
    });

    testWidgets('hides action bar for resolved reports', (tester) async {
      final resolvedReport = report.copyWith(status: 'resolved');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reportedContentProvider.overrideWith(
              (ref, request) => Future.value(reportedContent),
            ),
            moderationDecisionsProvider.overrideWith(
              (ref, reportId) => Future.value([]),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ModerationDetailSheet(report: resolvedReport),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Apply Decision'), findsNothing);
    });

    testWidgets('shows content preview in content tab', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reportedContentProvider.overrideWith(
              (ref, request) => Future.value(reportedContent),
            ),
            moderationDecisionsProvider.overrideWith(
              (ref, reportId) => Future.value([]),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ModerationDetailSheet(report: report),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Content'));
      await tester.pumpAndSettle();

      expect(find.text('Suspicious post content'), findsOneWidget);
    });

    testWidgets('shows empty history message', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reportedContentProvider.overrideWith(
              (ref, request) => Future.value(reportedContent),
            ),
            moderationDecisionsProvider.overrideWith(
              (ref, reportId) => Future.value([]),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ModerationDetailSheet(report: report),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      expect(find.text('No moderation history yet'), findsOneWidget);
    });
  });
}
