import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:teen_talk_app/src/features/messages/data/models/direct_message.dart';
import 'package:teen_talk_app/src/features/messages/presentation/widgets/message_bubble.dart';
import '../helpers/golden_test_helper.dart';

void main() {
  setUpAll(() async {
    await loadTestFonts();
  });

  group('MessageBubble widget golden tests', () {
    final now = DateTime(2024, 1, 15, 14, 30);

    final sentMessage = DirectMessage(
      id: 'msg-1',
      conversationId: 'conv-1',
      senderId: 'current-user',
      senderName: 'You',
      content: 'Hey! How are you doing?',
      createdAt: now,
      isRead: true,
    );

    final receivedMessage = DirectMessage(
      id: 'msg-2',
      conversationId: 'conv-1',
      senderId: 'other-user',
      senderName: 'John',
      content: 'I\'m doing great! Thanks for asking 😊',
      createdAt: now.add(const Duration(minutes: 1)),
      isRead: false,
    );

    final unreadMessage = DirectMessage(
      id: 'msg-3',
      conversationId: 'conv-1',
      senderId: 'current-user',
      senderName: 'You',
      content: 'That\'s awesome!',
      createdAt: now.add(const Duration(minutes: 2)),
      isRead: false,
    );

    final imageMessage = DirectMessage(
      id: 'msg-4',
      conversationId: 'conv-1',
      senderId: 'other-user',
      senderName: 'John',
      content: 'Check out this photo!',
      createdAt: now.add(const Duration(minutes: 3)),
      isRead: true,
      imageUrl: 'https://example.com/image.jpg',
    );

    final longMessage = DirectMessage(
      id: 'msg-5',
      conversationId: 'conv-1',
      senderId: 'current-user',
      senderName: 'You',
      content:
          'This is a really long message that should wrap to multiple lines. '
          'It contains a lot of text to test how the message bubble handles '
          'longer content and ensures that the layout remains clean and readable.',
      createdAt: now.add(const Duration(minutes: 4)),
      isRead: true,
    );

    Widget buildMessageBubble(
      DirectMessage message, {
      required bool isCurrentUser,
      required String senderName,
      ThemeMode theme = ThemeMode.light,
    }) {
      final lightTheme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
      );

      final darkTheme = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
      );

      return ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: theme,
          home: Scaffold(
            backgroundColor: theme == ThemeMode.dark
                ? darkTheme.colorScheme.surface
                : lightTheme.colorScheme.surface,
            body: Center(
              child: MessageBubble(
                message: message,
                isCurrentUser: isCurrentUser,
                senderName: senderName,
              ),
            ),
          ),
        ),
      );
    }

    testGoldens('message bubble variants - light theme', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'sent message read',
          buildMessageBubble(
            sentMessage,
            isCurrentUser: true,
            senderName: 'You',
          ),
        )
        ..addScenario(
          'received message',
          buildMessageBubble(
            receivedMessage,
            isCurrentUser: false,
            senderName: 'John',
          ),
        )
        ..addScenario(
          'sent message unread',
          buildMessageBubble(
            unreadMessage,
            isCurrentUser: true,
            senderName: 'You',
          ),
        )
        ..addScenario(
          'message with image',
          buildMessageBubble(
            imageMessage,
            isCurrentUser: false,
            senderName: 'John',
          ),
        )
        ..addScenario(
          'long message',
          buildMessageBubble(
            longMessage,
            isCurrentUser: true,
            senderName: 'You',
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(480, 1200),
      );

      await screenMatchesGolden(tester, 'message_bubble/message_variants_light');
    });

    testGoldens('message bubble variants - dark theme', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'sent message',
          buildMessageBubble(
            sentMessage,
            isCurrentUser: true,
            senderName: 'You',
            theme: ThemeMode.dark,
          ),
        )
        ..addScenario(
          'received message',
          buildMessageBubble(
            receivedMessage,
            isCurrentUser: false,
            senderName: 'John',
            theme: ThemeMode.dark,
          ),
        )
        ..addScenario(
          'long message',
          buildMessageBubble(
            longMessage,
            isCurrentUser: true,
            senderName: 'You',
            theme: ThemeMode.dark,
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(480, 700),
      );

      await screenMatchesGolden(tester, 'message_bubble/message_variants_dark');
    });

    testGoldens('message conversation', (tester) async {
      await tester.pumpWidgetBuilder(
        ProviderScope(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6366F1),
                brightness: Brightness.light,
              ),
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    MessageBubble(
                      message: sentMessage,
                      isCurrentUser: true,
                      senderName: 'You',
                    ),
                    MessageBubble(
                      message: receivedMessage,
                      isCurrentUser: false,
                      senderName: 'John',
                    ),
                    MessageBubble(
                      message: unreadMessage,
                      isCurrentUser: true,
                      senderName: 'You',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        surfaceSize: const Size(460, 500),
      );

      await screenMatchesGolden(tester, 'message_bubble/conversation_light');
    });

    testGoldens('message bubble tablet layout', (tester) async {
      await tester.pumpWidgetBuilder(
        buildMessageBubble(
          sentMessage,
          isCurrentUser: true,
          senderName: 'You',
        ),
        surfaceSize: const Size(840, 200),
      );

      await screenMatchesGolden(tester, 'message_bubble/message_tablet');
    });

    testWidgets('message bubble shows correct time', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MessageBubble(
                message: sentMessage,
                isCurrentUser: true,
                senderName: 'You',
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('14:30'), findsOneWidget);
    });

    testWidgets('sent message shows read icon', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MessageBubble(
                message: sentMessage,
                isCurrentUser: true,
                senderName: 'You',
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
    });

    testWidgets('unread message shows single check icon', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MessageBubble(
                message: unreadMessage,
                isCurrentUser: true,
                senderName: 'You',
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byIcon(Icons.done_rounded), findsOneWidget);
    });

    testWidgets('received message shows sender avatar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MessageBubble(
                message: receivedMessage,
                isCurrentUser: false,
                senderName: 'John',
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('J'), findsOneWidget);
    });
  });
}
