import 'dart:io';
import 'package:flutter/foundation.dart';
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

  bool get _isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(screenshotProtectionStateProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_isIOS && state.showWarning && !_dialogShowing) {
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
      alignment: Alignment.topLeft,
      children: [
        widget.child,
        if (_isIOS && state.isEnabled && state.isIosCaptureActive)
          const ScreenshotBlurOverlay(),
      ],
    );
  }
}
