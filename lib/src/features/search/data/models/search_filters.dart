import 'package:flutter/foundation.dart';

class SearchFilters {

  const SearchFilters({
    this.query = '',
    this.interests = const [],
    this.minSchoolYear,
    this.maxSchoolYear,
    this.minTrustLevel,
    this.school,
  });

  factory SearchFilters.fromJson(Map<String, dynamic> json) {
    return SearchFilters(
      query: json['query'] as String? ?? '',
      interests: json['interests'] != null
          ? List<String>.from(json['interests'] as List)
          : [],
      minSchoolYear: json['minSchoolYear'] as int?,
      maxSchoolYear: json['maxSchoolYear'] as int?,
      minTrustLevel: (json['minTrustLevel'] as num?)?.toDouble(),
      school: json['school'] as String?,
    );
  }
  final String query;
  final List<String> interests;
  final int? minSchoolYear;
  final int? maxSchoolYear;
  final double? minTrustLevel;
  final String? school;

  SearchFilters copyWith({
    String? query,
    List<String>? interests,
    int? minSchoolYear,
    int? maxSchoolYear,
    double? minTrustLevel,
    String? school,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      interests: interests ?? this.interests,
      minSchoolYear: minSchoolYear ?? this.minSchoolYear,
      maxSchoolYear: maxSchoolYear ?? this.maxSchoolYear,
      minTrustLevel: minTrustLevel ?? this.minTrustLevel,
      school: school ?? this.school,
    );
  }

  SearchFilters clearFilter(String filterType) {
    switch (filterType) {
      case 'interests':
        return copyWith(interests: []);
      case 'schoolYear':
        return SearchFilters(
          query: query,
          interests: interests,
          minTrustLevel: minTrustLevel,
          school: school,
        );
      case 'trustLevel':
        return SearchFilters(
          query: query,
          interests: interests,
          minSchoolYear: minSchoolYear,
          maxSchoolYear: maxSchoolYear,
          school: school,
        );
      case 'school':
        return SearchFilters(
          query: query,
          interests: interests,
          minSchoolYear: minSchoolYear,
          maxSchoolYear: maxSchoolYear,
          minTrustLevel: minTrustLevel,
        );
      default:
        return this;
    }
  }

  bool get hasActiveFilters {
    return interests.isNotEmpty ||
        minSchoolYear != null ||
        maxSchoolYear != null ||
        minTrustLevel != null ||
        school != null;
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'interests': interests,
      'minSchoolYear': minSchoolYear,
      'maxSchoolYear': maxSchoolYear,
      'minTrustLevel': minTrustLevel,
      'school': school,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchFilters &&
        other.query == query &&
        listEquals(other.interests, interests) &&
        other.minSchoolYear == minSchoolYear &&
        other.maxSchoolYear == maxSchoolYear &&
        other.minTrustLevel == minTrustLevel &&
        other.school == school;
  }

  @override
  int get hashCode {
    return query.hashCode ^
        Object.hashAll(interests) ^
        minSchoolYear.hashCode ^
        maxSchoolYear.hashCode ^
        minTrustLevel.hashCode ^
        school.hashCode;
  }
}
