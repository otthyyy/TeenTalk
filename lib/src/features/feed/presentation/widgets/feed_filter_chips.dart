import 'package:flutter/material.dart';
import '../../domain/models/feed_sort_option.dart';

class FeedFilterChips extends StatelessWidget {

  const FeedFilterChips({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
  });
  final FeedSortOption selectedOption;
  final ValueChanged<FeedSortOption> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: FeedSortOption.values.map((option) {
        final isSelected = option == selectedOption;
        return FilterChip(
          label: Text(option.label),
          selected: isSelected,
          onSelected: (_) => onOptionSelected(option),
          selectedColor: theme.colorScheme.primaryContainer,
          checkmarkColor: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surface,
          labelStyle: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
        );
      }).toList(),
    );
  }
}
