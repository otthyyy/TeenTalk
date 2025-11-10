import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/search_filters.dart';

class SearchPreferencesRepository {
  SearchPreferencesRepository._(this._prefs);

  static const _recentFiltersKey = 'search_recent_filters';
  static const _defaultFiltersKey = 'search_default_filters';
  final SharedPreferences _prefs;

  static Future<SearchPreferencesRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SearchPreferencesRepository._(prefs);
  }

  List<SearchFilters> getRecentFilters() {
    final stored = _prefs.getStringList(_recentFiltersKey);
    if (stored == null) {
      return const [];
    }

    return stored.map((jsonString) {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      return SearchFilters.fromJson(decoded);
    }).toList(growable: false);
  }

  Future<void> saveRecentFilters(List<SearchFilters> filters) async {
    final encoded = filters
        .map((filter) => jsonEncode(filter.toJson()))
        .toList(growable: false);
    await _prefs.setStringList(_recentFiltersKey, encoded);
  }

  Future<void> addRecentFilter(SearchFilters filter) async {
    final recent = [...getRecentFilters()];

    recent.removeWhere((existing) => existing == filter);
    recent.insert(0, filter);

    if (recent.length > 5) {
      recent.removeRange(5, recent.length);
    }

    await saveRecentFilters(recent);
  }

  Future<void> removeRecentFilter(SearchFilters filter) async {
    final recent = [...getRecentFilters()];
    recent.removeWhere((existing) => existing == filter);
    await saveRecentFilters(recent);
  }

  Future<void> clearRecentFilters() async {
    await _prefs.remove(_recentFiltersKey);
  }

  SearchFilters? getDefaultFilters() {
    final jsonString = _prefs.getString(_defaultFiltersKey);
    if (jsonString == null) {
      return null;
    }

    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    return SearchFilters.fromJson(decoded);
  }

  Future<void> saveDefaultFilters(SearchFilters filter) async {
    await _prefs.setString(_defaultFiltersKey, jsonEncode(filter.toJson()));
  }

  Future<void> clearDefaultFilters() async {
    await _prefs.remove(_defaultFiltersKey);
  }
}
