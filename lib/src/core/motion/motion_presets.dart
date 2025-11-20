import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Central motion system that wraps flutter_animate with preset durations, curves,
/// and stagger helpers. All animations use durations <300 ms for snappy, polished feel.
class MotionPresets {
  MotionPresets._();

  // Motion toggle - will be hooked up to motion preferences in Task 5
  static bool _motionEnabled = true;

  /// Check if animations should run. Can be disabled for reduced motion preference.
  static bool shouldAnimate() => _motionEnabled;

  /// Toggle motion on/off globally (for accessibility/motion preference)
  static void setMotionEnabled(bool enabled) {
    _motionEnabled = enabled;
  }

  // Duration presets (all <300 ms)
  static const Duration durationQuick = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSubtle = Duration(milliseconds: 200);

  // Curve presets for natural motion
  static const Curve curveSmooth = Curves.easeInOutCubic;
  static const Curve curveBounce = Curves.easeOutBack;
  static const Curve curveSnappy = Curves.easeOutExpo;
  static const Curve curveDecelerate = Curves.easeOutCubic;

  // Stagger delays for list reveals
  static const Duration staggerShort = Duration(milliseconds: 30);
  static const Duration staggerMedium = Duration(milliseconds: 50);

  // Page transition presets
  static Duration get pageTransitionDuration =>
      shouldAnimate() ? durationNormal : Duration.zero;

  static Curve get pageTransitionCurve => curveSmooth;

  // List item reveal presets
  static Duration listItemDelay(int index) {
    if (!shouldAnimate()) return Duration.zero;
    return staggerShort * index;
  }

  static Duration get listItemDuration =>
      shouldAnimate() ? durationSubtle : Duration.zero;

  // Micro-interaction presets (like button bounce)
  static Duration get microDuration =>
      shouldAnimate() ? durationQuick : Duration.zero;

  static Curve get microCurve => curveBounce;

  // Fade presets
  static Duration get fadeDuration =>
      shouldAnimate() ? durationNormal : Duration.zero;

  // Scale presets
  static Duration get scaleDuration =>
      shouldAnimate() ? durationQuick : Duration.zero;

  static Curve get scaleCurve => curveBounce;
}

/// Extension on Widget to apply common motion presets using flutter_animate
extension MotionExtensions on Widget {
  /// Fade in with optional delay
  Widget fadeInMotion({Duration delay = Duration.zero}) {
    if (!MotionPresets.shouldAnimate()) return this;
    return animate(delay: delay)
        .fadeIn(
          duration: MotionPresets.fadeDuration,
          curve: MotionPresets.curveSmooth,
        );
  }

  /// Slide and fade in from bottom (list reveal)
  Widget slideInMotion({int index = 0}) {
    if (!MotionPresets.shouldAnimate()) return this;
    return animate(delay: MotionPresets.listItemDelay(index))
        .fadeIn(
          duration: MotionPresets.listItemDuration,
          curve: MotionPresets.curveDecelerate,
        )
        .slideY(
          begin: 0.1,
          end: 0,
          duration: MotionPresets.listItemDuration,
          curve: MotionPresets.curveDecelerate,
        );
  }

  /// Scale bounce (micro-interaction)
  Widget scaleBounceTap() {
    if (!MotionPresets.shouldAnimate()) return this;
    return animate()
        .scale(
          duration: MotionPresets.scaleDuration,
          curve: MotionPresets.scaleCurve,
        );
  }

  /// Page entrance animation
  Widget pageEntrance() {
    if (!MotionPresets.shouldAnimate()) return this;
    return animate()
        .fadeIn(
          duration: MotionPresets.pageTransitionDuration,
          curve: MotionPresets.pageTransitionCurve,
        )
        .slideY(
          begin: 0.05,
          end: 0,
          duration: MotionPresets.pageTransitionDuration,
          curve: MotionPresets.pageTransitionCurve,
        );
  }

  /// Shimmer effect (for new items)
  Widget shimmerMotion() {
    if (!MotionPresets.shouldAnimate()) return this;
    return animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          color: Colors.white.withOpacity(0.3),
        );
  }

  /// Staggered list item animation
  Widget staggeredListItem(int index) {
    if (!MotionPresets.shouldAnimate()) return this;
    return animate(delay: MotionPresets.listItemDelay(index))
        .fadeIn(
          duration: MotionPresets.listItemDuration,
          curve: MotionPresets.curveDecelerate,
        )
        .slideY(
          begin: 0.08,
          end: 0,
          duration: MotionPresets.listItemDuration,
          curve: MotionPresets.curveDecelerate,
        );
  }

  /// Composer/modal entrance from bottom
  Widget composerEntrance() {
    if (!MotionPresets.shouldAnimate()) return this;
    return animate()
        .fadeIn(
          duration: MotionPresets.durationNormal,
          curve: MotionPresets.curveSmooth,
        )
        .slideY(
          begin: 0.2,
          end: 0,
          duration: MotionPresets.durationNormal,
          curve: MotionPresets.curveSnappy,
        );
  }
}
