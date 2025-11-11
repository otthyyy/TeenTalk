import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/user_profile.dart';

void main() {
  group('UserProfile.buildSearchKeywords', () {
    test('generates keywords from nickname only', () {
      final keywords = UserProfile.buildSearchKeywords(
        'JohnDoe',
        null,
        null,
        [],
        [],
      );

      expect(keywords, contains('johndoe'));
      expect(keywords.length, 1);
    });

    test('generates keywords from all fields', () {
      final keywords = UserProfile.buildSearchKeywords(
        'AliceSmith',
        'Harvard',
        'Sophomore',
        ['coding', 'music'],
        ['chess', 'debate'],
      );

      expect(keywords, contains('alicesmith'));
      expect(keywords, contains('harvard'));
      expect(keywords, contains('sophomore'));
      expect(keywords, contains('coding'));
      expect(keywords, contains('music'));
      expect(keywords, contains('chess'));
      expect(keywords, contains('debate'));
      expect(keywords.length, 7);
    });

    test('converts all keywords to lowercase', () {
      final keywords = UserProfile.buildSearchKeywords(
        'MixedCase',
        'HARVARD',
        'Sophomore',
        ['CodinG'],
        ['ChEsS'],
      );

      for (final keyword in keywords) {
        expect(keyword, keyword.toLowerCase());
      }
    });

    test('handles empty nickname gracefully', () {
      final keywords = UserProfile.buildSearchKeywords(
        '',
        'MIT',
        null,
        [],
        [],
      );

      expect(keywords, contains('mit'));
      expect(keywords.length, 1);
    });

    test('handles null values gracefully', () {
      final keywords = UserProfile.buildSearchKeywords(
        'User',
        null,
        null,
        [],
        [],
      );

      expect(keywords, contains('user'));
      expect(keywords.length, 1);
    });

    test('deduplicates keywords (using Set)', () {
      final keywords = UserProfile.buildSearchKeywords(
        'Alice',
        'MIT',
        null,
        ['coding', 'coding', 'music'],
        ['chess'],
      );

      final codeCount = keywords.where((k) => k == 'coding').length;
      expect(codeCount, 1);
    });

    test('handles empty strings in lists', () {
      final keywords = UserProfile.buildSearchKeywords(
        'User',
        'School',
        '',
        ['valid', ''],
        ['', 'club'],
      );

      expect(keywords, contains('user'));
      expect(keywords, contains('school'));
      expect(keywords, contains('valid'));
      expect(keywords, contains('club'));
    });

    test('handles whitespace-only strings', () {
      final keywords = UserProfile.buildSearchKeywords(
        'User',
        '  ',
        null,
        ['  ', 'valid'],
        [],
      );

      expect(keywords, contains('user'));
      expect(keywords, contains('valid'));
    });

    test('handles accented characters with normalization', () {
      final keywords = UserProfile.buildSearchKeywords(
        'José',
        'München',
        null,
        ['café', 'naïve'],
        ['résumé'],
      );

      expect(keywords, contains('josé'));
      expect(keywords, contains('jose'));
      expect(keywords, contains('münchen'));
      expect(keywords, contains('munchen'));
      expect(keywords, contains('café'));
      expect(keywords, contains('cafe'));
      expect(keywords, contains('naïve'));
      expect(keywords, contains('naive'));
      expect(keywords, contains('résumé'));
      expect(keywords, contains('resume'));
    });

    test('normalizes ligatures and sharp s', () {
      final keywords = UserProfile.buildSearchKeywords(
        'Straße',
        'Ærøskøbing',
        null,
        ['œuvre'],
        [],
      );

      expect(keywords, contains('straße'));
      expect(keywords, contains('strasse'));
      expect(keywords, contains('ærøskøbing'));
      expect(keywords, contains('aerøskøbing'));
      expect(keywords, contains('oeuvre'));
    });

    test('handles special characters in names', () {
      final keywords = UserProfile.buildSearchKeywords(
        "O'Brien",
        'St. Mary',
        null,
        ['rock&roll'],
        [],
      );

      expect(keywords, contains("o'brien"));
      expect(keywords, contains('st. mary'));
      expect(keywords, contains('rock&roll'));
    });

    test('handles unicode characters', () {
      final keywords = UserProfile.buildSearchKeywords(
        '中文名',
        '日本語',
        null,
        ['한국어'],
        ['Русский'],
      );

      expect(keywords, contains('中文名'));
      expect(keywords, contains('日本語'));
      expect(keywords, contains('한국어'));
      expect(keywords, contains('русский'));
    });

    test('handles numbers in keywords', () {
      final keywords = UserProfile.buildSearchKeywords(
        'User123',
        'School2024',
        'Year2',
        ['AI101', 'CS50'],
        ['Club21'],
      );

      expect(keywords, contains('user123'));
      expect(keywords, contains('school2024'));
      expect(keywords, contains('year2'));
      expect(keywords, contains('ai101'));
      expect(keywords, contains('cs50'));
      expect(keywords, contains('club21'));
    });

    test('handles mixed case with accents', () {
      final keywords = UserProfile.buildSearchKeywords(
        'François',
        'São Paulo',
        null,
        ['Zürich', 'MÜNCHEN'],
        ['Łódź'],
      );

      expect(keywords, contains('françois'));
      expect(keywords, contains('francois'));
      expect(keywords, contains('são paulo'));
      expect(keywords, contains('sao paulo'));
      expect(keywords, contains('zürich'));
      expect(keywords, contains('zurich'));
      expect(keywords, contains('münchen'));
      expect(keywords, contains('munchen'));
      expect(keywords, contains('łódź'));
      expect(keywords, contains('lodz'));
    });

    test('handles very long keyword lists', () {
      final manyInterests = List.generate(50, (i) => 'interest$i');
      final manyClubs = List.generate(30, (i) => 'club$i');

      final keywords = UserProfile.buildSearchKeywords(
        'User',
        'School',
        'Year',
        manyInterests,
        manyClubs,
      );

      expect(keywords, contains('user'));
      expect(keywords, contains('school'));
      expect(keywords, contains('year'));
      expect(keywords, contains('interest0'));
      expect(keywords, contains('interest49'));
      expect(keywords, contains('club0'));
      expect(keywords, contains('club29'));
    });
  });

  group('UserProfile.generateSearchKeywords', () {
    test('generates keywords from profile instance', () {
      final profile = UserProfile(
        uid: 'user1',
        nickname: 'TestUser',
        nicknameVerified: true,
        school: 'Harvard',
        schoolYear: 'Junior',
        interests: ['coding', 'gaming'],
        clubs: ['chess'],
        createdAt: DateTime.now(),
        privacyConsentGiven: true,
        privacyConsentTimestamp: DateTime.now(),
      );

      final keywords = profile.generateSearchKeywords();

      expect(keywords, contains('testuser'));
      expect(keywords, contains('harvard'));
      expect(keywords, contains('junior'));
      expect(keywords, contains('coding'));
      expect(keywords, contains('gaming'));
      expect(keywords, contains('chess'));
    });

    test('handles profile with minimal data', () {
      final profile = UserProfile(
        uid: 'user1',
        nickname: 'MinimalUser',
        nicknameVerified: true,
        createdAt: DateTime.now(),
        privacyConsentGiven: true,
        privacyConsentTimestamp: DateTime.now(),
      );

      final keywords = profile.generateSearchKeywords();

      expect(keywords, contains('minimaluser'));
      expect(keywords.length, 1);
    });
  });

  group('Search keyword edge cases', () {
    test('handles emoji in keywords', () {
      final keywords = UserProfile.buildSearchKeywords(
        'User😊',
        'School🎓',
        null,
        ['coding💻'],
        [],
      );

      expect(keywords, contains('user😊'));
      expect(keywords, contains('school🎓'));
      expect(keywords, contains('coding💻'));
    });

    test('handles hyphenated names', () {
      final keywords = UserProfile.buildSearchKeywords(
        'Mary-Jane',
        'Saint-Petersburg',
        null,
        ['web-development'],
        ['ping-pong'],
      );

      expect(keywords, contains('mary-jane'));
      expect(keywords, contains('saint-petersburg'));
      expect(keywords, contains('web-development'));
      expect(keywords, contains('ping-pong'));
    });

    test('handles apostrophes and quotes', () {
      final keywords = UserProfile.buildSearchKeywords(
        "O'Malley",
        "St. John's",
        null,
        ["Rock'n'Roll"],
        [],
      );

      expect(keywords, contains("o'malley"));
      expect(keywords, contains("st. john's"));
      expect(keywords, contains("rock'n'roll"));
    });

    test('handles periods and abbreviations', () {
      final keywords = UserProfile.buildSearchKeywords(
        'J.K. Rowling',
        'U.S.A.',
        'Ph.D.',
        ['A.I.'],
        ['N.A.S.A.'],
      );

      expect(keywords, contains('j.k. rowling'));
      expect(keywords, contains('u.s.a.'));
      expect(keywords, contains('ph.d.'));
      expect(keywords, contains('a.i.'));
      expect(keywords, contains('n.a.s.a.'));
    });

    test('handles underscores and other symbols', () {
      final keywords = UserProfile.buildSearchKeywords(
        'user_name',
        'school@location',
        null,
        ['c++', 'c#'],
        ['team_alpha'],
      );

      expect(keywords, contains('user_name'));
      expect(keywords, contains('school@location'));
      expect(keywords, contains('c++'));
      expect(keywords, contains('c#'));
      expect(keywords, contains('team_alpha'));
    });
  });
}
