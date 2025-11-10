/// Utility for generating search keywords with support for:
/// - Case folding (lowercasing)
/// - Accent/diacritic stripping (important for Italian text)
/// - Prefix generation for autocomplete
/// - Bigram generation for better matching
/// - Size limiting to respect Firestore document size constraints
///
/// Italian Diacritics supported: à, è, é, ì, ò, ù
class SearchKeywordsGenerator {
  static const int maxKeywordsCount = 100;
  static const int minTokenLength = 2;
  
  /// Mapping of accented characters to their base forms
  static const Map<String, String> _accentMap = {
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'å': 'a',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ý': 'y',
    'ÿ': 'y',
    'ñ': 'n',
    'ç': 'c',
  };

  /// Strips accents/diacritics from a string
  static String stripAccents(String text) {
    final buffer = StringBuffer();
    for (final char in text.toLowerCase().split('')) {
      buffer.write(_accentMap[char] ?? char);
    }
    return buffer.toString();
  }

  /// Generates search keywords from a list of strings
  /// 
  /// Options:
  /// - [includePrefixes]: Generate prefixes for autocomplete (e.g., "hello" -> ["h", "he", "hel", "hell", "hello"])
  /// - [includeBigrams]: Generate bigrams for better phrase matching (e.g., "hello world" -> ["hello_world"])
  /// - [includeOriginal]: Include original tokens with accents preserved
  static List<String> generateKeywords(
    List<String> inputs, {
    bool includePrefixes = true,
    bool includeBigrams = false,
    bool includeOriginal = true,
  }) {
    final keywords = <String>{};

    for (final input in inputs) {
      if (input.trim().isEmpty) continue;

      final normalized = input.trim();
      final tokens = normalized.split(RegExp(r'\s+'));

      for (final token in tokens) {
        if (token.isEmpty) continue;

        final lowercased = token.toLowerCase();
        final stripped = stripAccents(lowercased);

        if (includeOriginal) {
          keywords.add(token);
        }

        // Always include lowercased and stripped variants
        keywords.add(lowercased);
        if (stripped != lowercased) {
          keywords.add(stripped);
        }

        if (lowercased.length < minTokenLength) {
          continue;
        }

        // Generate prefixes for autocomplete
        if (includePrefixes) {
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

    // Limit size to prevent exceeding Firestore document size limits
    final keywordsList = keywords.toList();
    if (keywordsList.length > maxKeywordsCount) {
      // Sort by length descending to prioritize longer (more specific) keywords
      keywordsList.sort((a, b) => b.length.compareTo(a.length));
      return keywordsList.take(maxKeywordsCount).toList();
    }

    return keywordsList;
  }

  /// Generates keywords specifically for post content
  /// Includes content tokens, author nickname (if not anonymous), section
  static List<String> generatePostKeywords({
    required String content,
    String? authorNickname,
    required bool isAnonymous,
    String? section,
    String? school,
  }) {
    final inputs = <String>[];

    // Add content words (filter out very common/short words)
    final contentWords = content
        .split(RegExp(r'\s+'))
        .where((word) => word.length >= minTokenLength)
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

    return generateKeywords(
      inputs,
      includePrefixes: true,
      includeBigrams: true,
      includeOriginal: true,
    );
  }

  /// Generates keywords for user profiles
  /// Includes nickname, school, school year, interests, clubs
  static List<String> generateUserKeywords({
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

    return generateKeywords(
      inputs,
      includePrefixes: true,
      includeBigrams: false, // Less useful for structured profile data
      includeOriginal: true,
    );
  }

  /// Builds query tokens for Firestore arrayContainsAny search
  static List<String> buildQueryTokens(String query) {
    final normalized = normalizeSearchQuery(query);
    if (normalized.isEmpty) {
      return const [];
    }

    final tokens = normalized
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();

    if (tokens.isEmpty) {
      return const [];
    }

    final keywordCandidates = <String>{};

    // Include complete tokens
    for (final token in tokens) {
      keywordCandidates.add(token);
    }

    final lastToken = tokens.last;
    if (lastToken.length >= minTokenLength) {
      for (int i = minTokenLength; i <= lastToken.length; i++) {
        keywordCandidates.add(lastToken.substring(0, i));
      }
    } else {
      keywordCandidates.add(lastToken);
    }

    return keywordCandidates.toList();
  }

  /// Normalizes a search query for matching against keywords
  static String normalizeSearchQuery(String query) {
    return stripAccents(query.trim().toLowerCase());
  }
}
