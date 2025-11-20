import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_provider.dart';

class LazyLottie extends ConsumerStatefulWidget {
  const LazyLottie({
    super.key,
    required this.assetPath,
    this.shouldAnimate = true,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.fallbackIcon,
    this.fallbackMessage,
    this.repeat = true,
  });

  final String assetPath;
  final bool shouldAnimate;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData? fallbackIcon;
  final String? fallbackMessage;
  final bool repeat;

  @override
  ConsumerState<LazyLottie> createState() => _LazyLottieState();
}

class _LazyLottieState extends ConsumerState<LazyLottie> {
  bool _loadFailed = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  void _checkConnection() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final connectivityState = ref.watch(connectivityStatusProvider);

    final isOffline = connectivityState.when(
      data: (connected) => !connected,
      loading: () => false,
      error: (_, __) => true,
    );

    if (isOffline || _loadFailed || !widget.shouldAnimate || !_canPlayAnimation()) {
      return _buildFallback(theme);
    }

    if (_isLoading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Lottie.asset(
        widget.assetPath,
        fit: widget.fit,
        repeat: widget.repeat,
        errorBuilder: (context, error, stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_loadFailed) {
              setState(() {
                _loadFailed = true;
              });
            }
          });
          return _buildFallback(theme);
        },
      ),
    );
  }

  bool _canPlayAnimation() {
    if (kIsWeb) {
      return true;
    }
    
    if (Platform.isAndroid || Platform.isIOS) {
      return true;
    }
    
    return true;
  }

  Widget _buildFallback(ThemeData theme) {
    final icon = widget.fallbackIcon ?? Icons.animation;
    final message = widget.fallbackMessage;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: (widget.height ?? 100) * 0.4,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
