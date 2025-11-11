import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:teen_talk_app/src/features/tutorial/presentation/providers/tutorial_provider.dart';

Future<void> pumpTutorialController() async {
  await Future<void>.delayed(const Duration(milliseconds: 10));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('tutorial is shown by default when not completed or skipped', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await pumpTutorialController();

    final state = container.read(tutorialControllerProvider);
    expect(state.shouldShow, isTrue);
    expect(state.hasCompleted, isFalse);
    expect(state.hasSkipped, isFalse);
  });

  test('marking tutorial completed updates state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await pumpTutorialController();
    await container.read(tutorialControllerProvider.notifier).markCompleted();
    await pumpTutorialController();

    final state = container.read(tutorialControllerProvider);
    expect(state.hasCompleted, isTrue);
    expect(state.shouldShow, isFalse);
  });

  test('skipping tutorial prevents it from showing again', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await pumpTutorialController();
    await container.read(tutorialControllerProvider.notifier).markSkipped();
    await pumpTutorialController();

    final state = container.read(tutorialControllerProvider);
    expect(state.hasSkipped, isTrue);
    expect(state.shouldShow, isFalse);
  });

  test('resetting tutorial clears completion and skip flags', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await pumpTutorialController();
    final notifier = container.read(tutorialControllerProvider.notifier);
    await notifier.markCompleted();
    await pumpTutorialController();

    await notifier.reset();
    await pumpTutorialController();

    final state = container.read(tutorialControllerProvider);
    expect(state.hasCompleted, isFalse);
    expect(state.hasSkipped, isFalse);
    expect(state.shouldShow, isTrue);
  });
}
