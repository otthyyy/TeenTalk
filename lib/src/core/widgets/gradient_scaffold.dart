import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: Colors.transparent, // Important for gradient visibility
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF0F0F1E), // Deep dark blue/purple
                          const Color(0xFF1A1A2E),
                          const Color(0xFF16213E),
                        ]
                      : [
                          const Color(0xFFFDFBF7), // Warm off-white
                          const Color(0xFFF4F1EA),
                          const Color(0xFFE8E8E8),
                        ],
                ),
              ),
            ),
          ),
          // Subtle Orbs/Glows (Static for now, could be animated)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.05),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary
                        .withOpacity(isDark ? 0.2 : 0.1),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary
                    .withOpacity(isDark ? 0.15 : 0.05),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.secondary
                        .withOpacity(isDark ? 0.2 : 0.1),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          // Main Body
          body,
        ],
      ),
    );
  }
}
