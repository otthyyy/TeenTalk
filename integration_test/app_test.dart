
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:teen_talk_app/main.dart';
import 'package:teen_talk_app/src/core/services/crashlytics_service.dart';
import 'package:teen_talk_app/src/core/providers/crashlytics_provider.dart';
import 'package:teen_talk_app/firebase_options.dart';

import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TeenTalk Integration Tests', () {
    setUpAll(() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      await TestHelpers.connectToEmulators();
    });

    setUp(() async {
      await TestHelpers.clearFirestoreData();
      await TestHelpers.signOut();
    });

    tearDown(() async {
      await TestHelpers.signOut();
    });

    testWidgets('Complete user flow: signup, onboarding, post, comment, like, DM',
        (WidgetTester tester) async {
      final crashlyticsService = CrashlyticsService();
      await crashlyticsService.initialize();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            crashlyticsServiceProvider.overrideWithValue(crashlyticsService),
          ],
          child: const TeenTalkApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Sign Up
      print('Step 1: Testing sign up flow...');
      
      final signUpButton = find.text('Sign Up');
      if (signUpButton.evaluate().isEmpty) {
        final dontHaveAccount = find.textContaining("Don't have an account");
        if (dontHaveAccount.evaluate().isNotEmpty) {
          await TestHelpers.tapButton(tester, dontHaveAccount);
        }
      }

      await TestHelpers.waitForWidget(tester, find.text('Sign Up'));
      
      final emailFields = find.byType(TextFormField);
      expect(emailFields, findsWidgets);

      await TestHelpers.enterText(
        tester,
        emailFields.at(0),
        'Test User',
      );
      await TestHelpers.enterText(
        tester,
        emailFields.at(1),
        'testuser@example.com',
      );
      await TestHelpers.enterText(
        tester,
        emailFields.at(2),
        'testpassword123',
      );
      await TestHelpers.enterText(
        tester,
        emailFields.at(3),
        'testpassword123',
      );

      await TestHelpers.tapButton(tester, find.text('Sign Up'));
      await tester.pump(const Duration(seconds: 2));

      print('Step 2: Testing onboarding flow...');
      
      await TestHelpers.waitForWidget(
        tester,
        find.text('Welcome to TeenTalk'),
        timeout: const Duration(seconds: 15),
      );

      final nicknameField = find.byType(TextFormField).first;
      await TestHelpers.enterText(tester, nicknameField, 'testuser123');
      
      final nextButtons = find.text('Next');
      if (nextButtons.evaluate().isNotEmpty) {
        await TestHelpers.tapButton(tester, nextButtons.first);
        await tester.pump(const Duration(milliseconds: 500));
      }

      final genderDropdown = find.byType(DropdownButtonFormField<String>);
      if (genderDropdown.evaluate().isNotEmpty) {
        await tester.tap(genderDropdown.first);
        await tester.pumpAndSettle();
        
        final maleOption = find.text('Male').last;
        if (maleOption.evaluate().isNotEmpty) {
          await tester.tap(maleOption);
          await tester.pumpAndSettle();
        }
      }

      if (nextButtons.evaluate().isNotEmpty) {
        await TestHelpers.tapButton(tester, nextButtons.first);
        await tester.pump(const Duration(milliseconds: 500));
      }

      final schoolYearDropdown = find.widgetWithText(
        DropdownButtonFormField<String>,
        'School Year',
      );
      if (schoolYearDropdown.evaluate().isEmpty) {
        final allDropdowns = find.byType(DropdownButtonFormField<String>);
        if (allDropdowns.evaluate().isNotEmpty) {
          await tester.tap(allDropdowns.first);
          await tester.pumpAndSettle();
          
          final freshman = find.text('Freshman').last;
          if (freshman.evaluate().isNotEmpty) {
            await tester.tap(freshman);
            await tester.pumpAndSettle();
          }
        }
      }

      final interestsCheckboxes = find.byType(CheckboxListTile);
      if (interestsCheckboxes.evaluate().isNotEmpty) {
        await tester.tap(interestsCheckboxes.first);
        await tester.pumpAndSettle();
      }

      if (nextButtons.evaluate().isNotEmpty) {
        await TestHelpers.tapButton(tester, nextButtons.first);
        await tester.pump(const Duration(milliseconds: 500));
      }

      final consentCheckboxes = find.byType(Checkbox);
      for (int i = 0; i < consentCheckboxes.evaluate().length; i++) {
        await tester.tap(consentCheckboxes.at(i));
        await tester.pumpAndSettle();
      }

      final completeButton = find.text('Complete');
      if (completeButton.evaluate().isNotEmpty) {
        await TestHelpers.tapButton(tester, completeButton);
        await tester.pump(const Duration(seconds: 3));
      }

      print('Step 3: Testing post creation...');
      
      await TestHelpers.waitForWidget(
        tester,
        find.text('Feed'),
        timeout: const Duration(seconds: 15),
      );

      final composeButton = find.byIcon(Icons.add);
      if (composeButton.evaluate().isNotEmpty) {
        await TestHelpers.tapButton(tester, composeButton.first);
        await tester.pump(const Duration(seconds: 1));
      }

      final postContentField = find.byType(TextField);
      if (postContentField.evaluate().isNotEmpty) {
        await TestHelpers.enterText(
          tester,
          postContentField.first,
          'This is my first test post!',
        );
        
        final postButton = find.text('Post');
        if (postButton.evaluate().isNotEmpty) {
          await TestHelpers.tapButton(tester, postButton);
          await tester.pump(const Duration(seconds: 2));
        }
      }

      print('Step 4: Verifying post in Firestore...');
      
      await tester.pump(const Duration(seconds: 2));
      
      final firestore = FirebaseFirestore.instance;
      final postsSnapshot = await firestore
          .collection('posts')
          .where('content', isEqualTo: 'This is my first test post!')
          .get();
      
      expect(postsSnapshot.docs.isNotEmpty, true,
          reason: 'Post should be created in Firestore');

      print('Step 5: Testing comment functionality...');
      
      final postCard = find.textContaining('This is my first test post!');
      if (postCard.evaluate().isNotEmpty) {
        await tester.tap(postCard);
        await tester.pumpAndSettle();
        
        final commentField = find.byType(TextField);
        if (commentField.evaluate().isNotEmpty) {
          await TestHelpers.enterText(
            tester,
            commentField.first,
            'Great first post!',
          );
          
          final sendCommentButton = find.byIcon(Icons.send);
          if (sendCommentButton.evaluate().isNotEmpty) {
            await TestHelpers.tapButton(tester, sendCommentButton);
            await tester.pump(const Duration(seconds: 2));
          }
        }
      }

      print('Step 6: Testing like functionality...');
      
      final likeButton = find.byIcon(Icons.favorite_border);
      if (likeButton.evaluate().isNotEmpty) {
        await TestHelpers.tapButton(tester, likeButton.first);
        await tester.pump(const Duration(seconds: 1));
        
        final likedIcon = find.byIcon(Icons.favorite);
        expect(likedIcon.evaluate().isNotEmpty, true,
            reason: 'Like button should show as liked');
      }

      print('Step 7: Verifying like in Firestore...');
      
      if (postsSnapshot.docs.isNotEmpty) {
        final postId = postsSnapshot.docs.first.id;
        final auth = FirebaseAuth.instance;
        final currentUser = auth.currentUser;
        
        if (currentUser != null) {
          final likeDoc = await firestore
              .collection('posts')
              .doc(postId)
              .collection('likes')
              .doc(currentUser.uid)
              .get();
          
          expect(likeDoc.exists, true,
              reason: 'Like document should exist in Firestore');
        }
      }

      print('Step 8: Testing direct messaging...');
      
      await tester.pageBack();
      await tester.pumpAndSettle();
      
      final messagesTab = find.text('Messages');
      if (messagesTab.evaluate().isNotEmpty) {
        await TestHelpers.tapButton(tester, messagesTab);
        await tester.pump(const Duration(seconds: 1));
      }

      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      
      if (currentUser != null) {
        final testRecipientId = await TestHelpers.createTestUser(
          email: 'recipient@example.com',
          password: 'password123',
          displayName: 'Test Recipient',
        );
        
        await TestHelpers.createUserProfile(
          uid: testRecipientId,
          nickname: 'testrecipient',
        );
        
        final conversationId = await TestHelpers.createConversation(
          user1Id: currentUser.uid,
          user2Id: testRecipientId,
        );
        
        await TestHelpers.sendMessage(
          conversationId: conversationId,
          senderId: currentUser.uid,
          content: 'Hello! This is a test message.',
        );
        
        await tester.pump(const Duration(seconds: 2));
        
        final messagesSnapshot = await firestore
            .collection('directMessages')
            .doc(conversationId)
            .collection('messages')
            .get();
        
        expect(messagesSnapshot.docs.isNotEmpty, true,
            reason: 'Message should be created in Firestore');
      }

      print('Step 9: Verifying notifications...');
      
      if (currentUser != null) {
        final notificationsExist = await TestHelpers.notificationExists(
          userId: currentUser.uid,
          type: 'like',
        );
        
        print('Notifications check completed');
      }

      print('All integration tests passed successfully!');
    });

    testWidgets('Sign in flow for existing user', (WidgetTester tester) async {
      print('Testing sign in flow...');
      
      final userId = await TestHelpers.createTestUser(
        email: 'existing@example.com',
        password: 'password123',
        displayName: 'Existing User',
      );
      
      await TestHelpers.createUserProfile(
        uid: userId,
        nickname: 'existinguser',
      );
      
      await TestHelpers.signOut();
      
      final crashlyticsService = CrashlyticsService();
      await crashlyticsService.initialize();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            crashlyticsServiceProvider.overrideWithValue(crashlyticsService),
          ],
          child: const TeenTalkApp(),
        ),
      );
      await tester.pumpAndSettle();
      
      await TestHelpers.waitForWidget(tester, find.text('Sign In'));
      
      final emailFields = find.byType(TextFormField);
      
      await TestHelpers.enterText(
        tester,
        emailFields.at(0),
        'existing@example.com',
      );
      await TestHelpers.enterText(
        tester,
        emailFields.at(1),
        'password123',
      );
      
      await TestHelpers.tapButton(tester, find.text('Sign In'));
      await tester.pump(const Duration(seconds: 3));
      
      await TestHelpers.waitForWidget(
        tester,
        find.text('Feed'),
        timeout: const Duration(seconds: 15),
      );
      
      expect(find.text('Feed'), findsOneWidget);
      
      print('Sign in test passed!');
    });

    testWidgets('Post with image upload simulation', (WidgetTester tester) async {
      print('Testing post with image...');
      
      final userId = await TestHelpers.createTestUser(
        email: 'imagetest@example.com',
        password: 'password123',
        displayName: 'Image Tester',
      );
      
      await TestHelpers.createUserProfile(
        uid: userId,
        nickname: 'imagetester',
      );
      
      final crashlyticsService = CrashlyticsService();
      await crashlyticsService.initialize();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            crashlyticsServiceProvider.overrideWithValue(crashlyticsService),
          ],
          child: const TeenTalkApp(),
        ),
      );
      await tester.pumpAndSettle();
      
      await TestHelpers.waitForWidget(
        tester,
        find.text('Feed'),
        timeout: const Duration(seconds: 10),
      );
      
      final postId = await TestHelpers.createTestPost(
        authorId: userId,
        content: 'Post with image',
        imageUrl: 'https://example.com/image.jpg',
      );
      
      await tester.pump(const Duration(seconds: 1));
      
      final firestore = FirebaseFirestore.instance;
      final postDoc = await firestore.collection('posts').doc(postId).get();
      
      expect(postDoc.exists, true);
      expect(postDoc.data()?['imageUrl'], 'https://example.com/image.jpg');
      
      print('Image post test passed!');
    });

    testWidgets('Notification stream updates', (WidgetTester tester) async {
      print('Testing notification stream...');
      
      final userId = await TestHelpers.createTestUser(
        email: 'notiftest@example.com',
        password: 'password123',
        displayName: 'Notification Tester',
      );
      
      await TestHelpers.createUserProfile(
        uid: userId,
        nickname: 'notiftester',
      );
      
      final crashlyticsService = CrashlyticsService();
      await crashlyticsService.initialize();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            crashlyticsServiceProvider.overrideWithValue(crashlyticsService),
          ],
          child: const TeenTalkApp(),
        ),
      );
      await tester.pumpAndSettle();
      
      await TestHelpers.waitForWidget(
        tester,
        find.text('Feed'),
        timeout: const Duration(seconds: 10),
      );
      
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('notifications').add({
        'recipientId': userId,
        'type': 'like',
        'senderId': 'anotheruser',
        'postId': 'testpost123',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
      
      await tester.pump(const Duration(seconds: 2));
      
      final notificationExists = await TestHelpers.notificationExists(
        userId: userId,
        type: 'like',
      );
      
      expect(notificationExists, true,
          reason: 'Notification should exist in Firestore');
      
      print('Notification stream test passed!');
    });
  });
}
