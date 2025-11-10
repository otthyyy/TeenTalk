import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/core/widgets/cached_image_widget.dart';

void main() {
  group('CachedImageWidget', () {
    testWidgets('shows shimmer placeholder while loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedImageWidget(
              imageUrl: 'https://example.com/image.jpg',
              width: 200,
              height: 200,
            ),
          ),
        ),
      );

      // Pump a frame to allow widget to build placeholder state
      await tester.pump();

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('honors custom border radius', (tester) async {
      const customBorderRadius = BorderRadius.all(Radius.circular(24));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CachedImageWidget(
              imageUrl: 'https://example.com/image.jpg',
              width: 200,
              height: 200,
              borderRadius: customBorderRadius,
            ),
          ),
        ),
      );

      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, customBorderRadius);
    });
  });
}
