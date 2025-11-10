import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../profile/domain/models/user_profile.dart';
import '../models/search_filters.dart';

class SearchRepository {
  SearchRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<UserProfile>> searchProfiles(
    SearchFilters filters, {
    int limit = 50,
  }) async {
    final query = _buildQuery(filters).limit(limit);
    final snapshot = await query.get();

    return snapshot.docs.map(UserProfile.fromFirestore).toList();
  }

  Stream<List<UserProfile>> watchProfiles(
    SearchFilters filters, {
    int limit = 50,
  }) {
    final query = _buildQuery(filters).limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map(UserProfile.fromFirestore).toList();
    });
  }

  Query<Map<String, dynamic>> _buildQuery(SearchFilters filters) {
    Query<Map<String, dynamic>> query =
        _firestore.collection('users').where('profileVisible', isEqualTo: true);

    if (filters.query.isNotEmpty) {
      final normalizedQuery = filters.query.trim().toLowerCase();
      query = query.where('nicknameLowercase', isEqualTo: normalizedQuery);
    }

    if (filters.school != null && filters.school!.isNotEmpty) {
      query = query.where('school', isEqualTo: filters.school);
    }

    final hasSchoolYearRange =
        filters.minSchoolYear != null || filters.maxSchoolYear != null;
    if (filters.minSchoolYear != null) {
      query = query.where(
        'schoolYear',
        isGreaterThanOrEqualTo: filters.minSchoolYear,
      );
    }

    if (filters.maxSchoolYear != null) {
      query = query.where(
        'schoolYear',
        isLessThanOrEqualTo: filters.maxSchoolYear,
      );
    }

    if (filters.interests.isNotEmpty) {
      final interests = filters.interests.take(10).toList();
      query = query.where('interests', arrayContainsAny: interests);
    }

    if (filters.minTrustLevel != null) {
      query = query.where(
        'trustLevel',
        isGreaterThanOrEqualTo: filters.minTrustLevel,
      );
    }

    if (hasSchoolYearRange) {
      query = query.orderBy('schoolYear');
      query = query.orderBy('trustLevel', descending: true);
      query = query.orderBy('nicknameLowercase');
      return query;
    }

    if (filters.minTrustLevel != null) {
      query = query.orderBy('trustLevel', descending: true);
      query = query.orderBy('nicknameLowercase');
      return query;
    }

    query = query.orderBy('nicknameLowercase');
    return query;
  }
}
