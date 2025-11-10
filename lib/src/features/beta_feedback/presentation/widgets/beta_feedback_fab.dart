import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';

class BetaFeedbackFAB extends ConsumerWidget {
  const BetaFeedbackFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value;

    if (profile == null || !profile.isBetaTester) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: () {
        context.push('/beta-feedback');
      },
      tooltip: 'Beta Feedback',
      child: const Icon(Icons.feedback),
    );
  }
}
