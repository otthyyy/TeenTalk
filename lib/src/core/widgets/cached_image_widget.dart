import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';

import '../services/image_cache_service.dart';

class CachedImageWidget extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final bool enableInstrumentation;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.enableInstrumentation = false,
  });

  @override
  State<CachedImageWidget> createState() => _CachedImageWidgetState();
}

class _CachedImageWidgetState extends State<CachedImageWidget> {
  final Logger _logger = Logger();
  Stopwatch? _stopwatch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = widget.borderRadius ?? BorderRadius.circular(12);

    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: CachedNetworkImage(
        imageUrl: widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheManager: ImageCacheService.customCacheManager,
        placeholder: (context, url) {
          _startInstrumentation();
          return _buildShimmerPlaceholder(
            theme,
            widget.width,
            widget.height,
          );
        },
        errorWidget: (context, url, error) {
          _completeInstrumentation();
          return widget.errorWidget ??
              _buildErrorWidget(
                theme,
                widget.width,
                widget.height,
              );
        },
        imageBuilder: (context, imageProvider) {
          final isFromCache = _stopwatch == null;
          _completeInstrumentation(isFromCache: isFromCache);

          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: widget.fit,
              ),
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  void _startInstrumentation() {
    if (!widget.enableInstrumentation) return;
    if (_stopwatch != null) return;

    _stopwatch = Stopwatch()..start();
    _logger.d('Start loading image: ${widget.imageUrl}');
  }

  void _completeInstrumentation({bool isFromCache = false}) {
    if (!widget.enableInstrumentation) return;

    if (_stopwatch != null && _stopwatch!.isRunning) {
      _stopwatch!..stop();
      _logger.i(
        'Loaded image: ${widget.imageUrl} in ${_stopwatch!.elapsedMilliseconds}ms',
      );
      _stopwatch = null;
    } else if (isFromCache) {
      _logger.i('Loaded image from cache: ${widget.imageUrl}');
    }
  }

  Widget _buildShimmerPlaceholder(
    ThemeData theme,
    double? width,
    double? height,
  ) {
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      highlightColor: theme.colorScheme.surfaceVariant.withOpacity(0.1),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(
    ThemeData theme,
    double? width,
    double? height,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: theme.colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 8),
            Text(
              'Image unavailable',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
