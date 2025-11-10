import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/domain/models/user_profile.dart';
import '../providers/search_provider.dart';
import '../widgets/filter_drawer.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/user_search_result_card.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final notifier = ref.read(searchProvider.notifier);
    final currentFilters = ref.read(searchProvider).filters;

    notifier.search(
      filters: currentFilters.copyWith(query: _searchController.text),
    );
  }

  void _openFilterDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _onProfileTap(UserProfile profile) {
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final hasActiveFilters = searchState.filters.hasActiveFilters;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Search Users'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: hasActiveFilters,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _openFilterDrawer,
          ),
        ],
      ),
      endDrawer: const FilterDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarWidget(
              controller: _searchController,
              onClear: () {
                _searchController.clear();
                ref.read(searchProvider.notifier).clearAllFilters();
              },
            ),
          ),
          if (hasActiveFilters)
            FilterChipsRow(
              filters: searchState.filters,
              onClearFilter: (filterType) {
                ref.read(searchProvider.notifier).clearFilter(filterType);
              },
              onClearAll: () {
                _searchController.clear();
                ref.read(searchProvider.notifier).clearAllFilters();
              },
              onRemoveInterest: (interest) {
                ref.read(searchProvider.notifier).removeInterest(interest);
              },
            ),
          Expanded(
            child: _buildBody(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SearchState state) {
    if (state.isLoading && state.results.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(searchProvider.notifier).search();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(searchProvider.notifier).search(useDebounce: false);
      },
      child: ListView.builder(
        itemCount: state.results.length + (state.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.results.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final profile = state.results[index];
          return UserSearchResultCard(
            profile: profile,
            onTap: () => _onProfileTap(profile),
          );
        },
      ),
    );
  }
}
