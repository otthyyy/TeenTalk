import 'package:flutter/material.dart';

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const SkeletonPostCard();
      },
    );
  }
}

class SkeletonPostCard extends StatelessWidget {
  const SkeletonPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header skeleton
            Row(
              children: [
                _buildSkeletonAvatar(theme),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSkeletonLine(theme, width: 120, height: 16),
                      const SizedBox(height: 4),
                      _buildSkeletonLine(theme, width: 80, height: 12),
                    ],
                  ),
                ),
                _buildSkeletonIcon(theme),
              ],
            ),
            const SizedBox(height: 12),
            // Content skeleton
            _buildSkeletonLine(theme, width: double.infinity, height: 14),
            const SizedBox(height: 4),
            _buildSkeletonLine(theme, width: double.infinity, height: 14),
            const SizedBox(height: 4),
            _buildSkeletonLine(theme, width: 200, height: 14),
            const SizedBox(height: 12),
            // Footer skeleton
            Row(
              children: [
                _buildSkeletonButton(theme),
                const SizedBox(width: 16),
                _buildSkeletonButton(theme),
                const Spacer(),
                _buildSkeletonTag(theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonAvatar(ThemeData theme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSkeletonLine(ThemeData theme, {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildSkeletonIcon(ThemeData theme) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildSkeletonButton(ThemeData theme) {
    return Container(
      width: 60,
      height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildSkeletonTag(ThemeData theme) {
    return Container(
      width: 80,
      height: 24,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}