class TTAssets {
  const TTAssets._();

  static const String _iconsBase = 'assets/icons';
  static const String iconsGoogle = '$_iconsBase/google.svg';
  static const String iconsIncognito = '$_iconsBase/incognito.svg';

  static const String _animationsBase = 'assets/animations';
  static const String riveBase = '$_animationsBase/rive';
  static const String lottieBase = '$_animationsBase/lottie';

  /// Returns the full path for an icon stored under [assets/icons].
  static String icon(String fileName) => '$_iconsBase/$fileName';

  /// Returns the full path for a Rive animation under [assets/animations/rive].
  static String rive(String fileName) => '$riveBase/$fileName';

  /// Returns the full path for a Lottie animation under [assets/animations/lottie].
  static String lottie(String fileName) => '$lottieBase/$fileName';
}
