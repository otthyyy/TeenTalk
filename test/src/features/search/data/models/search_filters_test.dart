import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/search/data/models/search_filters.dart';

void main() {
  group('SearchFilters', () {
    test('should create default empty filters', () {
      const filters = SearchFilters();

      expect(filters.query, '');
      expect(filters.interests, isEmpty);
      expect(filters.minSchoolYear, isNull);
      expect(filters.maxSchoolYear, isNull);
      expect(filters.minTrustLevel, isNull);
      expect(filters.school, isNull);
    });

    test('should copyWith properly', () {
      const initial = SearchFilters(
        query: 'test',
        interests: ['Sports'],
      );

      final updated = initial.copyWith(
        interests: ['Music', 'Art'],
        minSchoolYear: 9,
      );

      expect(updated.query, 'test');
      expect(updated.interests, ['Music', 'Art']);
      expect(updated.minSchoolYear, 9);
    });

    test('should detect active filters', () {
      const noFilters = SearchFilters();
      expect(noFilters.hasActiveFilters, isFalse);

      const withInterests = SearchFilters(interests: ['Sports']);
      expect(withInterests.hasActiveFilters, isTrue);

      const withSchoolYear = SearchFilters(minSchoolYear: 9);
      expect(withSchoolYear.hasActiveFilters, isTrue);

      const withTrustLevel = SearchFilters(minTrustLevel: 50);
      expect(withTrustLevel.hasActiveFilters, isTrue);

      const withSchool = SearchFilters(school: 'Test School');
      expect(withSchool.hasActiveFilters, isTrue);
    });

    test('should clearFilter correctly', () {
      const filters = SearchFilters(
        interests: ['Sports'],
        minSchoolYear: 9,
        maxSchoolYear: 12,
        minTrustLevel: 50,
        school: 'Test School',
      );

      final clearedInterests = filters.clearFilter('interests');
      expect(clearedInterests.interests, isEmpty);
      expect(clearedInterests.minSchoolYear, 9);

      final clearedSchoolYear = filters.clearFilter('schoolYear');
      expect(clearedSchoolYear.minSchoolYear, isNull);
      expect(clearedSchoolYear.maxSchoolYear, isNull);
      expect(clearedSchoolYear.interests, isNotEmpty);

      final clearedTrust = filters.clearFilter('trustLevel');
      expect(clearedTrust.minTrustLevel, isNull);
      expect(clearedTrust.interests, isNotEmpty);

      final clearedSchool = filters.clearFilter('school');
      expect(clearedSchool.school, isNull);
      expect(clearedSchool.interests, isNotEmpty);
    });

    test('should serialize to/from JSON', () {
      const filters = SearchFilters(
        query: 'test',
        interests: ['Sports', 'Music'],
        minSchoolYear: 9,
        maxSchoolYear: 12,
        minTrustLevel: 50.5,
        school: 'Test School',
      );

      final json = filters.toJson();
      final restored = SearchFilters.fromJson(json);

      expect(restored.query, filters.query);
      expect(restored.interests, filters.interests);
      expect(restored.minSchoolYear, filters.minSchoolYear);
      expect(restored.maxSchoolYear, filters.maxSchoolYear);
      expect(restored.minTrustLevel, filters.minTrustLevel);
      expect(restored.school, filters.school);
    });

    test('should handle equality correctly', () {
      const filters1 = SearchFilters(
        query: 'test',
        interests: ['Sports'],
      );

      const filters2 = SearchFilters(
        query: 'test',
        interests: ['Sports'],
      );

      const filters3 = SearchFilters(
        query: 'different',
        interests: ['Sports'],
      );

      expect(filters1, equals(filters2));
      expect(filters1, isNot(equals(filters3)));
      expect(filters1.hashCode, equals(filters2.hashCode));
    });
  });
}
