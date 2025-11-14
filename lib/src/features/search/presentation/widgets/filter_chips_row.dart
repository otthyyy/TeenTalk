import 'package:flutter/material.dart';

import '../../data/models/search_filters.dart';

class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({
    super.key,
    required this.filters,
    required this.onClearFilter,
    required this.onClearAll,
    required this.onRemoveInterest,
  });

  final SearchFilters filters;
  final void Function(String filterType) onClearFilter;
  final VoidCallback onClearAll;
  final void Function(String interest) onRemoveInterest;

  @override
  Widget build(BuildContext context) {
    final chips = _buildChips(context);

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.35),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...chips,
          if (chips.length > 1)
            ActionChip(
              label: const Text('Clear all'),
              onPressed: onClearAll,
              avatar: const Icon(Icons.clear_all, size: 18),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildChips(BuildContext context) {
    final chips = <Widget>[];

    for (final interest in filters.interests) {
      chips.add(
        InputChip(
          label: Text(interest),
          onDeleted: () => onRemoveInterest(interest),
          deleteIcon: const Icon(Icons.close, size: 16),
        ),
      );
    }

    if (filters.interests.isNotEmpty) {
      chips.add(
        ActionChip(
          label: const Text('Clear interests'),
          onPressed: () => onClearFilter('interests'),
          avatar: const Icon(Icons.cancel_outlined, size: 18),
        ),
      );
    }

    if (filters.minSchoolYear != null || filters.maxSchoolYear != null) {
      chips.add(
        InputChip(
          label: Text(_schoolYearLabel()),
          onDeleted: () => onClearFilter('schoolYear'),
          deleteIcon: const Icon(Icons.close, size: 16),
        ),
      );
    }

    if (filters.minTrustLevel != null) {
      chips.add(
        InputChip(
          label: Text('Trust ≥${filters.minTrustLevel!.toStringAsFixed(0)}'),
          onDeleted: () => onClearFilter('trustLevel'),
          deleteIcon: const Icon(Icons.close, size: 16),
        ),
      );
    }

    if (filters.school != null && filters.school!.isNotEmpty) {
      chips.add(
        InputChip(
          label: Text('School: ${filters.school}'),
          onDeleted: () => onClearFilter('school'),
          deleteIcon: const Icon(Icons.close, size: 16),
        ),
      );
    }

    return chips;
  }

  String _schoolYearLabel() {
    final min = filters.minSchoolYear;
    final max = filters.maxSchoolYear;

    if (min != null && max != null) {
      if (min == max) {
        return 'Year $min';
      }
      return 'Years $min–$max';
    }

    if (min != null) {
      return 'Year ≥$min';
    }

    if (max != null) {
      return 'Year ≤$max';
    }

    return 'School year';
  }
}
