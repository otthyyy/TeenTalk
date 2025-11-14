import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/search_filters.dart';
import '../providers/search_provider.dart';

class FilterDrawer extends ConsumerStatefulWidget {
  const FilterDrawer({super.key});

  @override
  ConsumerState<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends ConsumerState<FilterDrawer> {
  late SearchFilters _workingFilters;

  @override
  void initState() {
    super.initState();
    _workingFilters = ref.read(searchProvider).filters;
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final availableInterests = ref.watch(availableInterestsProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildInterestsSection(context, availableInterests),
                  const SizedBox(height: 24),
                  _buildSchoolYearSection(context),
                  const SizedBox(height: 24),
                  _buildTrustSection(context),
                  if (searchState.defaultFilters != null) ...[
                    const SizedBox(height: 24),
                    _buildDefaultSection(context, searchState),
                  ],
                  if (searchState.recentFilters.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildRecentSection(context, searchState),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            _buildFooter(context, searchState),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filters',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(
    BuildContext context,
    List<String> availableInterests,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interests',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableInterests.map((interest) {
            final isSelected = _workingFilters.interests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _workingFilters = _workingFilters.copyWith(
                      interests: {
                        ..._workingFilters.interests,
                        interest,
                      }.toList(),
                    );
                  } else {
                    _workingFilters = _workingFilters.copyWith(
                      interests: _workingFilters.interests
                          .where((value) => value != interest)
                          .toList(),
                    );
                  }
                });
              },
            );
          }).toList(),
        ),
        if (_workingFilters.interests.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _workingFilters = _workingFilters.copyWith(interests: []);
                });
              },
              child: const Text('Clear interests'),
            ),
          ),
      ],
    );
  }

  Widget _buildSchoolYearSection(BuildContext context) {
    final years = List<int>.generate(12, (index) => index + 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'School Year',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int?>(
                initialValue: _workingFilters.minSchoolYear,
                decoration: const InputDecoration(
                  labelText: 'From',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Any'),
                  ),
                  ...years.map(
                    (year) => DropdownMenuItem<int?>(
                      value: year,
                      child: Text('Year $year'),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    var maxYear = _workingFilters.maxSchoolYear;
                    if (value != null && maxYear != null && value > maxYear) {
                      maxYear = value;
                    }
                    _workingFilters = _workingFilters.copyWith(
                      minSchoolYear: value,
                      maxSchoolYear: maxYear,
                    );
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int?>(
                initialValue: _workingFilters.maxSchoolYear,
                decoration: const InputDecoration(
                  labelText: 'To',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Any'),
                  ),
                  ...years.map(
                    (year) => DropdownMenuItem<int?>(
                      value: year,
                      child: Text('Year $year'),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    var minYear = _workingFilters.minSchoolYear;
                    if (value != null && minYear != null && value < minYear) {
                      minYear = value;
                    }
                    _workingFilters = _workingFilters.copyWith(
                      maxSchoolYear: value,
                      minSchoolYear: minYear,
                    );
                  });
                },
              ),
            ),
          ],
        ),
        if (_workingFilters.minSchoolYear != null ||
            _workingFilters.maxSchoolYear != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _workingFilters = _workingFilters.copyWith(
                    minSchoolYear: null,
                    maxSchoolYear: null,
                  );
                });
              },
              child: const Text('Clear school year'),
            ),
          ),
      ],
    );
  }

  Widget _buildTrustSection(BuildContext context) {
    final minTrust = _workingFilters.minTrustLevel ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trust Level Threshold',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Slider(
          value: minTrust,
          min: 0,
          max: 100,
          divisions: 100,
          label: minTrust.toStringAsFixed(0),
          onChanged: (value) {
            setState(() {
              _workingFilters = _workingFilters.copyWith(
                minTrustLevel: value == 0 ? null : value,
              );
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Minimum: ${minTrust.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _workingFilters = _workingFilters.copyWith(minTrustLevel: null);
                });
              },
              child: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultSection(BuildContext context, SearchState state) {
    final defaultFilters = state.defaultFilters!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saved Default',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.star_rounded),
            title: Text(_filterSummary(defaultFilters)),
            subtitle: const Text('Tap to load default filters'),
            onTap: () {
              setState(() {
                _workingFilters = defaultFilters;
              });
            },
            trailing: IconButton(
              tooltip: 'Remove default filters',
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearDefaultFilters,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSection(BuildContext context, SearchState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Combinations',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...state.recentFilters.map((filter) {
          final summary = _filterSummary(filter);
          return Card(
            child: ListTile(
              dense: true,
              title: Text(summary),
              subtitle: filter == _workingFilters
                  ? const Text('Currently loaded')
                  : null,
              onTap: () {
                setState(() {
                  _workingFilters = filter;
                });
              },
              trailing: IconButton(
                tooltip: 'Remove from recents',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _removeRecentFilter(filter),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, SearchState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: _applyFilters,
            child: const Text('Apply Filters'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: state.isSavingDefault ? null : _saveAsDefault,
                  child: state.isSavingDefault
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save as Default'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    ref.read(searchProvider.notifier).search(
          filters: _workingFilters,
          useDebounce: false,
        );
    Navigator.of(context).maybePop();
  }

  void _resetFilters() {
    setState(() {
      _workingFilters = const SearchFilters();
    });
  }

  Future<void> _saveAsDefault() async {
    await ref.read(searchProvider.notifier).saveAsDefaultFilter();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Default filters saved')), 
    );
  }

  Future<void> _clearDefaultFilters() async {
    await ref.read(searchProvider.notifier).clearDefaultFilter();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Default filters cleared')), 
    );
  }

  Future<void> _removeRecentFilter(SearchFilters filters) async {
    await ref.read(searchProvider.notifier).removeRecentFilter(filters);
  }

  String _filterSummary(SearchFilters filters) {
    final parts = <String>[];
    if (filters.interests.isNotEmpty) {
      parts.add(filters.interests.join(', '));
    }
    if (filters.minSchoolYear != null || filters.maxSchoolYear != null) {
      parts.add(_schoolYearSummary(filters));
    }
    if (filters.minTrustLevel != null) {
      parts.add('Trust ≥${filters.minTrustLevel!.toStringAsFixed(0)}');
    }
    if (parts.isEmpty) {
      return 'No filters applied';
    }
    return parts.join(' · ');
  }

  String _schoolYearSummary(SearchFilters filters) {
    final min = filters.minSchoolYear;
    final max = filters.maxSchoolYear;

    if (min != null && max != null) {
      if (min == max) {
        return 'Year $min';
      }
      return 'Years $min–$max';
    } else if (min != null) {
      return 'Year ≥$min';
    } else if (max != null) {
      return 'Year ≤$max';
    }
    return 'School year';
  }
}
