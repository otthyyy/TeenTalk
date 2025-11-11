import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/screenshot_protection_providers.dart';
import 'screenshot_warning_dialog.dart';
import 'screenshot_blur_overlay.dart';

class ScreenshotProtectedContent extends ConsumerStatefulWidget {
  const ScreenshotProtectedContent({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<ScreenshotProtectedContent> createState() =>
      _ScreenshotProtectedContentState();
}

class _ScreenshotProtectedContentState
    extends ConsumerState<ScreenshotProtectedContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(screenshotProtectionStateProvider);
    });
  }

  bool _dialogShowing = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(screenshotProtectionStateProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (Platform.isIOS && state.showWarning && !_dialogShowing) {
        _dialogShowing = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const ScreenshotWarningDialog(),
        ).then((_) {
          if (mounted) {
            ref
                .read(screenshotProtectionStateProvider.notifier)
                .dismissWarning();
            _dialogShowing = false;
          }
        });
      }
    });

    return Stack(
      children: [
        widget.child,
        if (Platform.isIOS && state.isEnabled && state.isIosCaptureActive)
          const ScreenshotBlurOverlay(),
      ],
    );
  }
}
