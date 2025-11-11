import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/core/utils/search_keywords_generator.dart';

void main() {
  group('SearchKeywordsGenerator', () {
    test('strips Italian diacritics correctly', () {
      const input = 'àèéìòùñç';
      final result = SearchKeywordsGenerator.stripAccents(input);
      expect(result, equals('aeeiounc'));
    });

    test('generateKeywords produces prefixes and normalized tokens', () {
      final keywords = SearchKeywordsGenerator.generateKeywords(['Caffè']);

      expect(keywords, contains('ca'));
      expect(keywords, contains('caf'));
      expect(keywords, contains('caff'));
      expect(keywords, contains('caffe'));
      expect(keywords, contains('caffè'.toLowerCase()));
      expect(keywords, contains('cafe'));
    });

    test('generatePostKeywords includes content, author, section, and school', () {
      final keywords = SearchKeywordsGenerator.generatePostKeywords(
        content: 'Ciao Ragazzi! Evento al caffè domani',
        authorNickname: 'Mario',
        isAnonymous: false,
        section: 'eventi',
        school: 'Liceo Arnaldo',
      );

      expect(keywords, contains('ciao'));
      expect(keywords, contains('ra'));
      expect(keywords, contains('ragazzi'));
      expect(keywords, contains('evento'));
      expect(keywords, contains('caffe'));
      expect(keywords, contains('mario'));
      expect(keywords, contains('ev'));
      expect(keywords, contains('eventi'));
      expect(keywords, contains('li'));
      expect(keywords, contains('liceo'));
    });

    test('generateUserKeywords includes profile metadata and gender', () {
      final keywords = SearchKeywordsGenerator.generateUserKeywords(
        nickname: 'Giulia',
        school: 'Liceo Classico',
        schoolYear: '4',
        interests: const ['Musica', 'Fotografia'],
        clubs: const ['Teatro'],
        gender: 'F',
      );

      expect(keywords, contains('gi'));
      expect(keywords, contains('giulia'));
      expect(keywords, contains('lic'));
      expect(keywords, contains('liceo'));
      expect(keywords, contains('cl'));
      expect(keywords, contains('classico'));
      expect(keywords, contains('4'));
      expect(keywords, contains('mu'));
      expect(keywords, contains('musica'));
      expect(keywords, contains('fo'));
      expect(keywords, contains('fotografia'));
      expect(keywords, contains('te'));
      expect(keywords, contains('teatro'));
      expect(keywords, contains('f'));
    });

    test('limits number of keywords to configured maximum', () {
      final longText = List.generate(200, (index) => 'keyword$index').join(' ');
      final keywords = SearchKeywordsGenerator.generatePostKeywords(
        content: longText,
        authorNickname: 'Author',
        isAnonymous: false,
        section: 'section',
        school: 'school',
      );

      expect(keywords.length, lessThanOrEqualTo(SearchKeywordsGenerator.maxKeywordsCount));
    });
  });
}
