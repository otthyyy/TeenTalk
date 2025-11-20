import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import '../constants/tt_assets.dart';

class FirstRunIntroOverlay extends StatefulWidget {
  const FirstRunIntroOverlay({
    super.key,
    required this.onContinue,
    required this.onSkip,
    this.shouldAnimate = true,
  });

  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final bool shouldAnimate;

  @override
  State<FirstRunIntroOverlay> createState() => _FirstRunIntroOverlayState();
}

class _FirstRunIntroOverlayState extends State<FirstRunIntroOverlay> {
  rive.Artboard? _artboard;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    if (widget.shouldAnimate) {
      _loadRiveBackground();
    }
  }

  Future<void> _loadRiveBackground() async {
    try {
      final file = await rive.RiveFile.asset(TTAssets.riveIntroBackground);
      if (!mounted) return;
      setState(() {
        _artboard = file.mainArtboard;
      });
    } catch (e) {
      debugPrint('Failed to load intro Rive background: $e');
      if (!mounted) return;
      setState(() {
        _loadFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: _buildBackground(theme),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome to TeenTalk',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your safe space to share, learn, and grow. '
                          "Let's take a quick tour together!",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Wrap(
                          alignment: WrapAlignment.center,
                          runSpacing: 12,
                          spacing: 12,
                          children: [
                            _introChip(
                              icon: Icons.message_rounded,
                              label: 'Chat with peers',
                            ),
                            _introChip(
                              icon: Icons.lightbulb_outline,
                              label: 'Discover insights',
                            ),
                            _introChip(
                              icon: Icons.shield_moon_outlined,
                              label: 'Stay anonymous',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: widget.onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Let\'s go'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: widget.onSkip,
                        child: const Text('Skip for now'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(ThemeData theme) {
    if (!widget.shouldAnimate || _loadFailed) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.6),
              theme.colorScheme.secondary.withOpacity(0.6),
            ],
          ),
        ),
      );
    }

    if (_artboard == null) {
      return Container(
        alignment: Alignment.center,
        color: theme.colorScheme.surface,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return rive.Rive(
      artboard: _artboard!,
      fit: BoxFit.cover,
    );
  }

  Widget _introChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
