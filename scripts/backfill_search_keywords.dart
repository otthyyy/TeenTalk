#!/usr/bin/env dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:teen_talk_app/firebase_options.dart';

void main(List<String> args) async {
  print('=== Search Keywords Backfill Script ===\n');
  
  if (args.isEmpty || !['dev', 'prod'].contains(args[0])) {
    print('Usage: dart run scripts/backfill_search_keywords.dart [dev|prod]');
    print('');
    print('Options:');
    print('  dev   - Run against Firebase emulator (localhost:8080)');
    print('  prod  - Run against production Firestore');
    print('');
    print('WARNING: Production backfills can incur costs and affect quotas.');
    exit(1);
  }

  final environment = args[0];
  final isDev = environment == 'dev';
  
  if (!isDev) {
    print('⚠️  WARNING: Running against PRODUCTION Firestore!');
    print('This will modify live data and incur write costs.');
    print('');
    stdout.write('Type "yes" to continue: ');
    final confirmation = stdin.readLineSync();
    if (confirmation?.toLowerCase() != 'yes') {
      print('Aborted.');
      exit(0);
    }
    print('');
  }

  try {
    // Initialize Firebase
    if (isDev) {
      print('🔧 Connecting to Firebase emulator...');
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'fake-api-key',
          appId: 'fake-app-id',
          messagingSenderId: 'fake-sender-id',
          projectId: 'demo-project',
        ),
      );
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    } else {
      print('🌐 Connecting to production Firestore...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final firestore = FirebaseFirestore.instance;
    
    print('✓ Connected to Firestore\n');

    // Backfill posts
    await backfillPosts(firestore);
    
    // Backfill users
    await backfillUsers(firestore);
    
    print('\n✅ Backfill complete!');
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print(stackTrace);
    exit(1);
  }
}

Future<void> backfillPosts(FirebaseFirestore firestore) async {
  print('📝 Backfilling posts...');
  
  final postsRef = firestore.collection('posts');
  var totalProcessed = 0;
  var totalUpdated = 0;
  var totalErrors = 0;
  
  try {
    // Query all posts without searchKeywords or with empty searchKeywords
    final snapshot = await postsRef.get();
    final posts = snapshot.docs;
    
    print('   Found ${posts.length} posts to process');
    
    if (posts.isEmpty) {
      print('   No posts to backfill\n');
      return;
    }
    
    // Process in batches of 500 (Firestore limit)
    final batchSize = 500;
    for (var i = 0; i < posts.length; i += batchSize) {
      final batch = firestore.batch();
      final end = (i + batchSize < posts.length) ? i + batchSize : posts.length;
      final batchDocs = posts.sublist(i, end);
      
      for (final doc in batchDocs) {
        try {
          final data = doc.data();
          final existingKeywords = data['searchKeywords'] as List?;
          
          // Skip if already has keywords
          if (existingKeywords != null && existingKeywords.isNotEmpty) {
            totalProcessed++;
            continue;
          }
          
          final content = data['content'] as String? ?? '';
          final authorNickname = data['authorNickname'] as String?;
          final isAnonymous = data['isAnonymous'] as bool? ?? false;
          final section = data['section'] as String?;
          final school = data['school'] as String?;
          
          // Generate keywords
          final keywords = generatePostKeywords(
            content: content,
            authorNickname: authorNickname,
            isAnonymous: isAnonymous,
            section: section,
            school: school,
          );
          
          // Update document
          batch.update(doc.reference, {
            'searchKeywords': keywords,
            'updatedAt': DateTime.now().toIso8601String(),
          });
          
          totalUpdated++;
        } catch (e) {
          print('   ⚠️  Error processing post ${doc.id}: $e');
          totalErrors++;
        }
        
        totalProcessed++;
      }
      
      // Commit batch
      if (totalUpdated > 0) {
        await batch.commit();
        print('   Processed ${totalProcessed}/${posts.length} posts (${totalUpdated} updated)');
      }
    }
    
    print('   ✓ Posts backfill complete: $totalUpdated updated, $totalErrors errors\n');
    
  } catch (e) {
    print('   ❌ Failed to backfill posts: $e\n');
    rethrow;
  }
}

Future<void> backfillUsers(FirebaseFirestore firestore) async {
  print('👥 Backfilling users...');
  
  final usersRef = firestore.collection('users');
  var totalProcessed = 0;
  var totalUpdated = 0;
  var totalErrors = 0;
  
  try {
    // Query all users
    final snapshot = await usersRef.get();
    final users = snapshot.docs;
    
    print('   Found ${users.length} users to process');
    
    if (users.isEmpty) {
      print('   No users to backfill\n');
      return;
    }
    
    // Process in batches of 500
    final batchSize = 500;
    for (var i = 0; i < users.length; i += batchSize) {
      final batch = firestore.batch();
      final end = (i + batchSize < users.length) ? i + batchSize : users.length;
      final batchDocs = users.sublist(i, end);
      
      for (final doc in batchDocs) {
        try {
          final data = doc.data();
          final existingKeywords = data['searchKeywords'] as List?;
          
          // Skip if already has keywords
          if (existingKeywords != null && existingKeywords.isNotEmpty) {
            totalProcessed++;
            continue;
          }
          
          final nickname = data['nickname'] as String? ?? '';
          final school = data['school'] as String?;
          final schoolYear = data['schoolYear'] as String?;
          final gender = data['gender'] as String?;
          final interests = (data['interests'] as List?)?.cast<String>() ?? [];
          final clubs = (data['clubs'] as List?)?.cast<String>() ?? [];
          
          // Generate keywords
          final keywords = generateUserKeywords(
            nickname: nickname,
            school: school,
            schoolYear: schoolYear,
            interests: interests,
            clubs: clubs,
            gender: gender,
          );
          
          // Update document
          batch.update(doc.reference, {
            'searchKeywords': keywords,
            'updatedAt': Timestamp.now(),
          });
          
          totalUpdated++;
        } catch (e) {
          print('   ⚠️  Error processing user ${doc.id}: $e');
          totalErrors++;
        }
        
        totalProcessed++;
      }
      
      // Commit batch
      if (totalUpdated > 0) {
        await batch.commit();
        print('   Processed ${totalProcessed}/${users.length} users (${totalUpdated} updated)');
      }
    }
    
    print('   ✓ Users backfill complete: $totalUpdated updated, $totalErrors errors\n');
    
  } catch (e) {
    print('   ❌ Failed to backfill users: $e\n');
    rethrow;
  }
}

// Simplified keyword generation (mirrors SearchKeywordsGenerator)
List<String> generatePostKeywords({
  required String content,
  String? authorNickname,
  required bool isAnonymous,
  String? section,
  String? school,
}) {
  final inputs = <String>[];
  
  // Add content words
  final contentWords = content
      .split(RegExp(r'\s+'))
      .where((word) => word.length >= 2)
      .toList();
  inputs.addAll(contentWords);
  
  // Add author nickname if not anonymous
  if (!isAnonymous && authorNickname != null && authorNickname.isNotEmpty) {
    inputs.add(authorNickname);
  }
  
  // Add section
  if (section != null && section.isNotEmpty) {
    inputs.add(section);
  }
  
  // Add school
  if (school != null && school.isNotEmpty) {
    inputs.add(school);
  }
  
  return generateKeywords(inputs, includeBigrams: true);
}

List<String> generateUserKeywords({
  required String nickname,
  String? school,
  String? schoolYear,
  List<String>? interests,
  List<String>? clubs,
  String? gender,
}) {
  final inputs = <String>[];
  
  if (nickname.isNotEmpty) {
    inputs.add(nickname);
  }
  
  if (school != null && school.isNotEmpty) {
    inputs.add(school);
  }
  
  if (schoolYear != null && schoolYear.isNotEmpty) {
    inputs.add(schoolYear);
  }
  
  if (gender != null && gender.isNotEmpty) {
    inputs.add(gender);
  }
  
  if (interests != null) {
    inputs.addAll(interests);
  }
  
  if (clubs != null) {
    inputs.addAll(clubs);
  }
  
  return generateKeywords(inputs, includeBigrams: false);
}

List<String> generateKeywords(List<String> inputs, {bool includeBigrams = false}) {
  final keywords = <String>{};
  const minTokenLength = 2;
  const maxKeywordsCount = 100;
  
  for (final input in inputs) {
    if (input.trim().isEmpty) continue;
    
    final normalized = input.trim();
    final tokens = normalized.split(RegExp(r'\s+'));
    
    for (final token in tokens) {
      if (token.isEmpty) continue;
      
      final lowercased = token.toLowerCase();
      if (lowercased.length >= minTokenLength) {
        keywords.add(lowercased);
        
        // Add stripped version
        final stripped = stripAccents(lowercased);
        if (stripped != lowercased) {
          keywords.add(stripped);
        }
        
        // Generate prefixes
        for (int i = minTokenLength; i <= stripped.length; i++) {
          keywords.add(stripped.substring(0, i));
        }
        if (stripped != lowercased) {
          for (int i = minTokenLength; i <= lowercased.length; i++) {
            keywords.add(lowercased.substring(0, i));
          }
        }
      }
    }
    
    // Generate bigrams
    if (includeBigrams && tokens.length > 1) {
      for (int i = 0; i < tokens.length - 1; i++) {
        final bigram = '${stripAccents(tokens[i].toLowerCase())}_${stripAccents(tokens[i + 1].toLowerCase())}';
        if (bigram.length >= minTokenLength * 2 + 1) {
          keywords.add(bigram);
        }
      }
    }
  }
  
  // Limit size
  final keywordsList = keywords.toList();
  if (keywordsList.length > maxKeywordsCount) {
    keywordsList.sort((a, b) => b.length.compareTo(a.length));
    return keywordsList.take(maxKeywordsCount).toList();
  }
  
  return keywordsList;
}

String stripAccents(String text) {
  const accentMap = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ý': 'y', 'ÿ': 'y',
    'ñ': 'n', 'ç': 'c',
  };
  
  final buffer = StringBuffer();
  for (final char in text.toLowerCase().split('')) {
    buffer.write(accentMap[char] ?? char);
  }
  return buffer.toString();
}
