import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../profile/domain/models/user_profile.dart';
import '../../data/models/search_filters.dart';
import '../../data/repositories/search_preferences_repository.dart';
import '../../data/repositories/search_repository.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository();
});

final searchPreferencesRepositoryProvider =
    FutureProvider<SearchPreferencesRepository>((ref) async {
  return await SearchPreferencesRepository.create();
});

class SearchState {

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.isSavingDefault = false,
    this.error,
    this.filters = const SearchFilters(),
    this.recentFilters = const [],
    this.defaultFilters,
  });
  static const _sentinel = Object();

  final List<UserProfile> results;
  final bool isLoading;
  final bool isSavingDefault;
  final String? error;
  final SearchFilters filters;
  final List<SearchFilters> recentFilters;
  final SearchFilters? defaultFilters;

  SearchState copyWith({
    List<UserProfile>? results,
    bool? isLoading,
    bool? isSavingDefault,
    Object? error = _sentinel,
    SearchFilters? filters,
    List<SearchFilters>? recentFilters,
    Object? defaultFilters = _sentinel,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      isSavingDefault: isSavingDefault ?? this.isSavingDefault,
      error: error == _sentinel ? this.error : error as String?,
      filters: filters ?? this.filters,
      recentFilters: recentFilters ?? this.recentFilters,
      defaultFilters: defaultFilters == _sentinel
          ? this.defaultFilters
          : defaultFilters as SearchFilters?,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(
    this._repository,
    this._preferencesRepository,
  ) : super(const SearchState()) {
    _initialize();
  }

  final SearchRepository _repository;
  final SearchPreferencesRepository? _preferencesRepository;
  final Logger _logger = Logger();
  StreamSubscription? _resultsSubscription;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _resultsSubscription?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> search({
    SearchFilters? filters,
    bool saveToRecent = true,
    bool useDebounce = true,
  }) async {
    final searchFilters = filters ?? state.filters;

    _debounceTimer?.cancel();

    if (useDebounce) {
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        unawaited(_performSearch(
          searchFilters,
          saveToRecent: saveToRecent,
        ));
      });
      return;
    }

    await _performSearch(
      searchFilters,
      saveToRecent: saveToRecent,
    );
  }

  void updateFilters(SearchFilters filters) {
    state = state.copyWith(filters: filters);
  }

  void clearFilter(String filterType) {
    final newFilters = state.filters.clearFilter(filterType);
    search(
      filters: newFilters,
      saveToRecent: newFilters.hasActiveFilters,
      useDebounce: false,
    );
  }

  void removeInterest(String interest) {
    final updatedInterests =
        state.filters.interests.where((i) => i != interest).toList();
    final newFilters = state.filters.copyWith(interests: updatedInterests);
    search(
      filters: newFilters,
      saveToRecent: newFilters.hasActiveFilters,
      useDebounce: false,
    );
  }

  void clearAllFilters() {
    search(
      filters: const SearchFilters(),
      saveToRecent: false,
      useDebounce: false,
    );
  }

  void applyRecentFilter(SearchFilters filters) {
    search(filters: filters, useDebounce: false);
  }

  Future<void> removeRecentFilter(SearchFilters filters) async {
    if (_preferencesRepository == null) return;

    try {
      final updated = [...state.recentFilters];
      updated.removeWhere((f) => f == filters);
      state = state.copyWith(recentFilters: updated);
      await _preferencesRepository.removeRecentFilter(filters);
    } catch (e) {
      _logger.e('Failed to remove recent filter', error: e);
    }
  }

  Future<void> saveAsDefaultFilter() async {
    if (_preferencesRepository == null) return;

    try {
      state = state.copyWith(isSavingDefault: true);
      await _preferencesRepository.saveDefaultFilters(state.filters);
      state = state.copyWith(
        isSavingDefault: false,
        defaultFilters: state.filters,
      );
    } catch (e) {
      _logger.e('Failed to save default filters', error: e);
      state = state.copyWith(
        isSavingDefault: false,
        error: 'Failed to save default filters',
      );
    }
  }

  Future<void> applyDefaultFilter() async {
    final defaultFilters =
        state.defaultFilters ?? _preferencesRepository?.getDefaultFilters();
    if (defaultFilters == null) return;

    state = state.copyWith(defaultFilters: defaultFilters);

    await search(
      filters: defaultFilters,
      saveToRecent: false,
      useDebounce: false,
    );
  }

  Future<void> clearDefaultFilter() async {
    if (_preferencesRepository == null) return;

    try {
      await _preferencesRepository.clearDefaultFilters();
      state = state.copyWith(defaultFilters: null);
    } catch (e) {
      _logger.e('Failed to clear default filters', error: e);
      state = state.copyWith(error: 'Failed to clear default filters');
    }
  }

  Future<void> _initialize() async {
    await _loadRecentFilters();
    await _loadDefaultFilters();

    final initialFilters = state.defaultFilters ?? state.filters;
    await search(
      filters: initialFilters,
      saveToRecent: false,
      useDebounce: false,
    );
  }

  Future<void> _loadRecentFilters() async {
    if (_preferencesRepository == null) return;

    try {
      final filters = _preferencesRepository.getRecentFilters();
      state = state.copyWith(recentFilters: filters);
    } catch (e) {
      _logger.e('Failed to load recent filters', error: e);
    }
  }

  Future<void> _loadDefaultFilters() async {
    if (_preferencesRepository == null) return;

    try {
      final defaultFilters = _preferencesRepository.getDefaultFilters();
      state = state.copyWith(defaultFilters: defaultFilters);
    } catch (e) {
      _logger.e('Failed to load default filters', error: e);
    }
  }

  Future<void> _saveToRecentFilters(SearchFilters filters) async {
    if (_preferencesRepository == null) return;

    final recent = [...state.recentFilters];

    recent.removeWhere((f) => f == filters);

    recent.insert(0, filters);

    if (recent.length > 5) {
      recent.removeRange(5, recent.length);
    }

    state = state.copyWith(recentFilters: recent);

    try {
      await _preferencesRepository.addRecentFilter(filters);
    } catch (e) {
      _logger.e('Failed to persist recent filters', error: e);
    }
  }

  void _setupRealtimeUpdates(SearchFilters filters) {
    _resultsSubscription?.cancel();

    _resultsSubscription = _repository
        .watchProfiles(filters, limit: 50)
        .listen((results) {
      state = state.copyWith(results: results);
    }, onError: (error) {
      _logger.e('Real-time updates error', error: error);
    });
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> _performSearch(
    SearchFilters searchFilters, {
    required bool saveToRecent,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        filters: searchFilters,
      );

      final results = await _repository.searchProfiles(searchFilters);

      if (saveToRecent && searchFilters.hasActiveFilters) {
        await _saveToRecentFilters(searchFilters);
      }

      state = state.copyWith(
        results: results,
        isLoading: false,
      );

      _setupRealtimeUpdates(searchFilters);
    } catch (e, stackTrace) {
      _logger.e('Search failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed. Please try again.',
      );
    }
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  final prefsAsync = ref.watch(searchPreferencesRepositoryProvider);
  final prefs = prefsAsync.maybeWhen(
    data: (repo) => repo,
    orElse: () => null,
  );
  return SearchNotifier(repository, prefs);
});

final availableInterestsProvider = Provider<List<String>>((ref) {
  return [
    'Sports',
    'Music',
    'Art',
    'Gaming',
    'Reading',
    'Movies',
    'Technology',
    'Science',
    'Fashion',
    'Travel',
    'Photography',
    'Cooking',
    'Fitness',
    'Dance',
    'Theater',
    'Animals',
    'Environment',
    'Volunteering',
  ];
});
