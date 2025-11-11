import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/legal/presentation/pages/legal_document_page.dart';

void main() {
  group('LegalDocumentPage', () {
    testWidgets('displays privacy policy page', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LegalDocumentPage(
            documentType: LegalDocumentType.privacyPolicy,
          ),
        ),
      );

      await tester.pump();
      
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays terms of service page', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LegalDocumentPage(
            documentType: LegalDocumentType.termsOfService,
          ),
        ),
      );

      await tester.pump();
      
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('has reload button in app bar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LegalDocumentPage(
            documentType: LegalDocumentType.privacyPolicy,
          ),
        ),
      );

      await tester.pump();
      
      final reloadButton = find.byIcon(Icons.refresh);
      expect(reloadButton, findsOneWidget);
    });

    test('legalDocumentTypeFromRouteSegment returns correct types', () {
      expect(
        legalDocumentTypeFromRouteSegment('privacy'),
        LegalDocumentType.privacyPolicy,
      );
      expect(
        legalDocumentTypeFromRouteSegment('privacy-policy'),
        LegalDocumentType.privacyPolicy,
      );
      expect(
        legalDocumentTypeFromRouteSegment('terms'),
        LegalDocumentType.termsOfService,
      );
      expect(
        legalDocumentTypeFromRouteSegment('terms-of-service'),
        LegalDocumentType.termsOfService,
      );
      expect(
        legalDocumentTypeFromRouteSegment('invalid'),
        isNull,
      );
    });

    test('LegalDocumentType extension provides correct route segments', () {
      expect(
        LegalDocumentType.privacyPolicy.routeSegment,
        'privacy-policy',
      );
      expect(
        LegalDocumentType.termsOfService.routeSegment,
        'terms-of-service',
      );
    });

    test('LegalDocumentType extension provides correct asset base names', () {
      expect(
        LegalDocumentType.privacyPolicy.assetBaseName,
        'privacy_policy',
      );
      expect(
        LegalDocumentType.termsOfService.assetBaseName,
        'terms_of_service',
      );
    });
  });

  group('LegalDocumentUnavailablePage', () {
    testWidgets('displays appropriate error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LegalDocumentUnavailablePage(),
        ),
      );

      expect(find.text('Document not found'), findsOneWidget);
      expect(
        find.text('The requested legal document could not be found.'),
        findsOneWidget,
      );
    });
  });
}
