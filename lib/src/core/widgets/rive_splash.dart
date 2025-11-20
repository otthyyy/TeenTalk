import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../constants/tt_assets.dart';

class RiveSplash extends StatefulWidget {
  const RiveSplash({
    super.key,
    this.onAnimationComplete,
    this.shouldAnimate = true,
    this.maxDuration = const Duration(milliseconds: 1500),
    this.fallbackWidget,
  });

  final VoidCallback? onAnimationComplete;
  final bool shouldAnimate;
  final Duration maxDuration;
  final Widget? fallbackWidget;

  @override
  State<RiveSplash> createState() => _RiveSplashState();
}

class _RiveSplashState extends State<RiveSplash> {
  Artboard? _riveArtboard;
  StateMachineController? _controller;
  bool _loadFailed = false;
  Timer? _maxDurationTimer;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    if (widget.shouldAnimate && _canPlayAnimation()) {
      _loadRiveFile();
      _startMaxDurationTimer();
    } else {
      _completeImmediately();
    }
  }

  bool _canPlayAnimation() {
    if (kIsWeb) {
      return true;
    }
    
    if (Platform.isAndroid || Platform.isIOS) {
      return true;
    }
    
    return false;
  }

  void _startMaxDurationTimer() {
    _maxDurationTimer = Timer(widget.maxDuration, () {
      if (!_completed && mounted) {
        _complete();
      }
    });
  }

  void _completeImmediately() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_completed) {
        _complete();
      }
    });
  }

  void _complete() {
    if (_completed) return;
    setState(() {
      _completed = true;
    });
    widget.onAnimationComplete?.call();
  }

  Future<void> _loadRiveFile() async {
    try {
      final data = await RiveFile.asset(TTAssets.riveSplashLogo);
      final artboard = data.mainArtboard;
      
      final controller = StateMachineController.fromArtboard(
        artboard,
        'State Machine 1',
      );
      
      if (controller != null) {
        artboard.addController(controller);
        _controller = controller;
      }

      if (mounted) {
        setState(() {
          _riveArtboard = artboard;
        });
      }
    } catch (e) {
      debugPrint('Failed to load Rive animation: $e');
      if (mounted) {
        setState(() {
          _loadFailed = true;
        });
        _complete();
      }
    }
  }

  @override
  void dispose() {
    _maxDurationTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadFailed || !widget.shouldAnimate || !_canPlayAnimation()) {
      return widget.fallbackWidget ?? _buildFallback(context);
    }

    if (_riveArtboard == null) {
      return widget.fallbackWidget ?? _buildFallback(context);
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.08),
              Theme.of(context).colorScheme.secondary.withOpacity(0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SizedBox(
              width: 300,
              height: 300,
              child: Rive(
                artboard: _riveArtboard!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.08),
              theme.colorScheme.secondary.withOpacity(0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 90,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'TeenTalk',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
