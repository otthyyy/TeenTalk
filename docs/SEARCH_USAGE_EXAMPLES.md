# Search Usage Examples

## Basic Search Patterns

### 1. Searching Users by Keyword

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teen_talk_app/src/core/utils/search_keywords_generator.dart';

Future<void> searchUsers(String query) async {
  final firestore = FirebaseFirestore.instance;
  
  // Normalize the query (strip accents, lowercase)
  final normalizedQuery = SearchKeywordsGenerator.normalizeSearchQuery(query);
  
  // Build query tokens for better matching
  final tokens = SearchKeywordsGenerator.buildQueryTokens(query).take(10).toList();
  
  // Execute search
  final snapshot = await firestore
    .collection('users')
    .where('profileVisible', isEqualTo: true)
    .where('searchKeywords', arrayContainsAny: tokens)
    .orderBy('createdAt', descending: true)
    .limit(50)
    .get();
  
  final users = snapshot.docs.map((doc) => UserProfile.fromFirestore(doc)).toList();
  
  print('Found ${users.length} users matching "$query"');
  for (final user in users) {
    print('- ${user.nickname} (${user.school})');
  }
}
```

### 2. Searching Posts with Filters

```dart
Future<void> searchPosts({
  required String query,
  String? section,
  String? school,
}) async {
  final firestore = FirebaseFirestore.instance;
  
  // Build base query
  var postsQuery = firestore.collection('posts').where('isModerated', isEqualTo: false);
  
  // Add keyword search
  if (query.isNotEmpty) {
    final tokens = SearchKeywordsGenerator.buildQueryTokens(query).take(10).toList();
    postsQuery = postsQuery.where('searchKeywords', arrayContainsAny: tokens);
  }
  
  // Add filters
  if (section != null) {
    postsQuery = postsQuery.where('section', isEqualTo: section);
  }
  
  if (school != null) {
    postsQuery = postsQuery.where('school', isEqualTo: school);
  }
  
  // Order and limit
  postsQuery = postsQuery
    .orderBy('createdAt', descending: true)
    .limit(20);
  
  final snapshot = await postsQuery.get();
  final posts = snapshot.docs.map((doc) => Post.fromJson({
    ...doc.data() as Map<String, dynamic>,
    'id': doc.id,
  })).toList();
  
  print('Found ${posts.length} posts');
}
```

### 3. Autocomplete Search

```dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teen_talk_app/src/core/utils/search_keywords_generator.dart';

class UserSearchField extends StatefulWidget {
  @override
  State<UserSearchField> createState() => _UserSearchFieldState();
}

class _UserSearchFieldState extends State<UserSearchField> {
  final _controller = TextEditingController();
  List<UserProfile> _suggestions = [];
  
  Future<void> _onSearchChanged(String query) async {
    if (query.length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    
    final tokens = SearchKeywordsGenerator.buildQueryTokens(query);
    if (tokens.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
      .collection('users')
      .where('profileVisible', isEqualTo: true)
      .where('searchKeywords', arrayContainsAny: tokens.take(10).toList())
      .limit(10)
      .get();
    
    setState(() {
      _suggestions = snapshot.docs
        .map((doc) => UserProfile.fromFirestore(doc))
        .toList();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search users...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            final user = _suggestions[index];
            return ListTile(
              title: Text(user.nickname),
              subtitle: Text(user.school ?? ''),
              onTap: () {
                // Navigate to user profile
              },
            );
          },
        ),
      ],
    );
  }
}
```

### 4. Search with Italian Text

```dart
// These searches work with accent-insensitive matching:

// User types "caffe" → finds "Caffè", "caffe", "CAFFE"
await searchUsers('caffe');

// User types "perché" → finds "perche", "Perché", "PERCHE"
await searchUsers('perché');

// User types "università" → finds "universita", "Università", "UNIVERSITA"
await searchUsers('università');

// The system automatically normalizes:
// - "Caffè" → "caffe"
// - "perché" → "perche"
// - "università" → "universita"
```

### 5. Multi-word Search

```dart
Future<void> multiWordSearch(String query) async {
  // Example: "Mario Rossi liceo"
  
  final tokens = SearchKeywordsGenerator.buildQueryTokens(query);
  // Returns: ["mario", "rossi", "li", "lic", "lice", "liceo"]
  
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore
    .collection('users')
    .where('profileVisible', isEqualTo: true)
    .where('searchKeywords', arrayContainsAny: tokens.take(10).toList())
    .limit(50)
    .get();
  
  // Results will include users with any of these keywords
  final users = snapshot.docs.map((doc) => UserProfile.fromFirestore(doc)).toList();
  
  // Optional: Client-side filtering for better relevance
  users.sort((a, b) {
    final aScore = _calculateRelevance(a, tokens);
    final bScore = _calculateRelevance(b, tokens);
    return bScore.compareTo(aScore);
  });
}

int _calculateRelevance(UserProfile user, List<String> tokens) {
  var score = 0;
  for (final token in tokens) {
    if (user.searchKeywords.contains(token)) {
      score += 1;
    }
  }
  return score;
}
```

### 6. Search by School

```dart
Future<void> searchUsersBySchool(String query, String school) async {
  final tokens = SearchKeywordsGenerator.buildQueryTokens(query);
  
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore
    .collection('users')
    .where('profileVisible', isEqualTo: true)
    .where('searchKeywords', arrayContainsAny: tokens.take(10).toList())
    .where('school', isEqualTo: school)
    .orderBy('createdAt', descending: true)
    .limit(50)
    .get();
  
  final users = snapshot.docs.map((doc) => UserProfile.fromFirestore(doc)).toList();
  print('Found ${users.length} users at $school');
}
```

### 7. Search Posts by Content

```dart
Future<void> searchPostsByContent(String query, {String? school}) async {
  final tokens = SearchKeywordsGenerator.buildQueryTokens(query);
  
  var postsQuery = FirebaseFirestore.instance
    .collection('posts')
    .where('isModerated', isEqualTo: false)
    .where('searchKeywords', arrayContainsAny: tokens.take(10).toList());
  
  if (school != null) {
    postsQuery = postsQuery.where('school', isEqualTo: school);
  }
  
  final snapshot = await postsQuery
    .orderBy('createdAt', descending: true)
    .limit(20)
    .get();
  
  final posts = snapshot.docs.map((doc) => Post.fromJson({
    ...doc.data() as Map<String, dynamic>,
    'id': doc.id,
  })).toList();
  
  // Display results
  for (final post in posts) {
    print('Post by ${post.isAnonymous ? "Anonymous" : post.authorNickname}');
    print('Content: ${post.content.substring(0, 50)}...');
  }
}
```

### 8. Using SearchRepository

```dart
import 'package:teen_talk_app/src/features/search/data/repositories/search_repository.dart';
import 'package:teen_talk_app/src/features/search/data/models/search_filters.dart';

Future<void> searchWithFilters() async {
  final repository = SearchRepository();
  
  // Basic search
  final filters = SearchFilters(
    query: 'mario',
  );
  
  final results = await repository.searchProfiles(filters);
  print('Found ${results.length} profiles');
  
  // Advanced search with filters
  final advancedFilters = SearchFilters(
    query: 'calcio',  // Search for "soccer"
    school: 'Liceo Arnaldo',
    interests: ['Sports'],
    minSchoolYear: 10,
    maxSchoolYear: 13,
  );
  
  final advancedResults = await repository.searchProfiles(advancedFilters);
  print('Found ${advancedResults.length} matching profiles');
}
```

### 9. Real-time Search Stream

```dart
import 'package:teen_talk_app/src/features/search/data/repositories/search_repository.dart';
import 'package:teen_talk_app/src/features/search/data/models/search_filters.dart';

Widget buildSearchStream(String query) {
  final repository = SearchRepository();
  final filters = SearchFilters(query: query);
  
  return StreamBuilder<List<UserProfile>>(
    stream: repository.watchProfiles(filters),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return CircularProgressIndicator();
      }
      
      final profiles = snapshot.data!;
      return ListView.builder(
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          final profile = profiles[index];
          return ListTile(
            title: Text(profile.nickname),
            subtitle: Text(profile.school ?? ''),
          );
        },
      );
    },
  );
}
```

## Testing Search Queries

### Testing Accent Normalization

```dart
void testAccentSearch() {
  // These should all match the same results:
  final queries = [
    'caffè',
    'caffe',
    'Caffè',
    'CAFFE',
    'CaFfE',
  ];
  
  for (final query in queries) {
    final normalized = SearchKeywordsGenerator.normalizeSearchQuery(query);
    print('$query → $normalized');  // All output: "caffe"
  }
}
```

### Testing Prefix Generation

```dart
void testPrefixGeneration() {
  final keywords = SearchKeywordsGenerator.generateKeywords(
    ['Università'],
    includePrefixes: true,
    includeBigrams: false,
  );
  
  print('Keywords for "Università":');
  print(keywords);
  // Outputs: ["università", "universita", "un", "uni", "univ", "unive", "univer", ...]
}
```

## Performance Tips

1. **Limit Token Count**: Use `.take(10)` to limit arrayContainsAny to 10 items
2. **Add Pagination**: Use `.limit()` and `.startAfterDocument()`
3. **Filter Order**: Apply most selective filters first
4. **Client-side Filtering**: For complex logic not supported by Firestore
5. **Caching**: Cache frequent searches in local storage

## Common Patterns

### Empty Search (Browse Mode)

```dart
// When query is empty, show trending or recent
if (query.isEmpty) {
  return firestore
    .collection('posts')
    .where('isModerated', isEqualTo: false)
    .orderBy('engagementScore', descending: true)
    .limit(20)
    .get();
}
```

### No Results Fallback

```dart
final results = await searchUsers(query);

if (results.isEmpty) {
  // Suggest alternatives:
  // 1. Remove last word
  // 2. Try stripped version
  // 3. Show popular users instead
  
  final fallbackQuery = query.split(' ').first;
  final fallbackResults = await searchUsers(fallbackQuery);
  
  if (fallbackResults.isNotEmpty) {
    print('No results for "$query". Did you mean "$fallbackQuery"?');
    return fallbackResults;
  }
}
```
