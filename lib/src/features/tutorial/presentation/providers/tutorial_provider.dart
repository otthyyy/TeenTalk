import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/tutorial_service.dart';

final tutorialServiceProvider = Provider<TutorialService>((ref) {
  return TutorialService();
});

class TutorialState {
  final bool hasCompleted;
  final bool hasSkipped;
  final bool isLoading;

  const TutorialState({
    required this.hasCompleted,
    required this.hasSkipped,
    required this.isLoading,
  });

  const TutorialState.loading()
      : hasCompleted = false,
        hasSkipped = false,
        isLoading = true;

  TutorialState copyWith({
    bool? hasCompleted,
    bool? hasSkipped,
    bool? isLoading,
  }) {
    return TutorialState(
      hasCompleted: hasCompleted ?? this.hasCompleted,
      hasSkipped: hasSkipped ?? this.hasSkipped,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get shouldShow => !isLoading && !hasCompleted && !hasSkipped;
}

class TutorialController extends StateNotifier<TutorialState> {
  TutorialController(this._tutorialService) : super(const TutorialState.loading()) {
    _loadStatus();
  }

  final TutorialService _tutorialService;

  Future<void> _loadStatus() async {
    final completed = await _tutorialService.isTutorialCompleted();
    final skipped = await _tutorialService.isTutorialSkipped();
    state = TutorialState(
      hasCompleted: completed,
      hasSkipped: skipped,
      isLoading: false,
    );
  }

  Future<void> markCompleted() async {
    await _tutorialService.markTutorialCompleted();
    state = state.copyWith(hasCompleted: true, hasSkipped: false);
  }

  Future<void> markSkipped() async {
    await _tutorialService.markTutorialSkipped();
    state = state.copyWith(hasSkipped: true);
  }

  Future<void> reset() async {
    await _tutorialService.resetTutorial();
    state = state.copyWith(
      hasCompleted: false,
      hasSkipped: false,
      isLoading: false,
    );
  }
}

final tutorialControllerProvider =
    StateNotifierProvider<TutorialController, TutorialState>((ref) {
  final service = ref.watch(tutorialServiceProvider);
  return TutorialController(service);
});

final shouldShowTutorialProvider = Provider<bool>((ref) {
  final state = ref.watch(tutorialControllerProvider);
  return state.shouldShow;
});

class TutorialAnchors {
  TutorialAnchors();

  final GlobalKey feedKey = GlobalKey(debugLabel: 'tutorialFeed');
  final GlobalKey createPostKey = GlobalKey(debugLabel: 'tutorialCreatePost');
  final GlobalKey searchKey = GlobalKey(debugLabel: 'tutorialSearch');
  final GlobalKey messagesNavKey = GlobalKey(debugLabel: 'tutorialMessages');
  final GlobalKey profileNavKey = GlobalKey(debugLabel: 'tutorialProfile');
  final GlobalKey safetyKey = GlobalKey(debugLabel: 'tutorialSafety');
}

final tutorialAnchorsProvider = Provider<TutorialAnchors>((ref) {
  return TutorialAnchors();
});
