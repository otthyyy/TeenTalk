import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestHelpers {
  static Future<void> connectToEmulators() async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;
    final functions = FirebaseFunctions.instance;

    auth.useAuthEmulator('localhost', 9099);
    firestore.useFirestoreEmulator('localhost', 8080);
    storage.useStorageEmulator('localhost', 9199);
    functions.useFunctionsEmulator('localhost', 5001);

    firestore.settings = const Settings(persistenceEnabled: false);
  }

  static Future<void> clearFirestoreData() async {
    final firestore = FirebaseFirestore.instance;
    
    final collections = ['users', 'posts', 'directMessages', 'notifications'];
    
    for (final collection in collections) {
      final snapshot = await firestore.collection(collection).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  static Future<void> signOut() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      await auth.signOut();
    }
  }

  static Future<String> createTestUser({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final auth = FirebaseAuth.instance;
    final userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (displayName != null && userCredential.user != null) {
      await userCredential.user!.updateDisplayName(displayName);
    }
    
    return userCredential.user!.uid;
  }

  static Future<void> createUserProfile({
    required String uid,
    required String nickname,
    String? bio,
    bool isAdmin = false,
  }) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(uid).set({
      'uid': uid,
      'nickname': nickname,
      'nicknameLowercase': nickname.toLowerCase(),
      'bio': bio ?? '',
      'profileVisible': true,
      'privacyConsentGiven': true,
      'privacyConsentTimestamp': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'anonymousPostsCount': 0,
      'isAdmin': isAdmin,
      'blockedUsers': [],
      'isSuspended': false,
      'crashReportingEnabled': true,
      'isProfileComplete': true,
    });
  }

  static Future<String> createTestPost({
    required String authorId,
    required String content,
    bool isAnonymous = false,
    String? imageUrl,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final postRef = await firestore.collection('posts').add({
      'authorId': authorId,
      'content': content,
      'contentLength': content.length,
      'createdAt': FieldValue.serverTimestamp(),
      'commentCount': 0,
      'likeCount': 0,
      'isAnonymous': isAnonymous,
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
    return postRef.id;
  }

  static Future<String> createTestComment({
    required String postId,
    required String authorId,
    required String content,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final commentRef = await firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      'authorId': authorId,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'likeCount': 0,
    });
    
    await firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(1),
    });
    
    return commentRef.id;
  }

  static Future<void> likePost({
    required String postId,
    required String userId,
  }) async {
    final firestore = FirebaseFirestore.instance;
    
    await firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .set({
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    await firestore.collection('posts').doc(postId).update({
      'likeCount': FieldValue.increment(1),
    });
  }

  static Future<String> createConversation({
    required String user1Id,
    required String user2Id,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final conversationRef = await firestore.collection('directMessages').add({
      'participantIds': [user1Id, user2Id],
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
    return conversationRef.id;
  }

  static Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) async {
    final firestore = FirebaseFirestore.instance;
    
    await firestore
        .collection('directMessages')
        .doc(conversationId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
    
    await firestore.collection('directMessages').doc(conversationId).update({
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessage': content,
    });
  }

  static Future<bool> notificationExists({
    required String userId,
    required String type,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .where('type', isEqualTo: type)
        .get();
    
    return snapshot.docs.isNotEmpty;
  }

  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final endTime = DateTime.now().add(timeout);
    
    while (DateTime.now().isBefore(endTime)) {
      await tester.pumpAndSettle();
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    throw Exception('Widget not found after timeout');
  }

  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  static Future<void> tapButton(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  static Finder findByKey(String key) {
    return find.byKey(Key(key));
  }

  static Finder findByText(String text) {
    return find.text(text);
  }

  static Finder findByType(Type type) {
    return find.byType(type);
  }
}
