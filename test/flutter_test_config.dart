import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> main(FutureOr<void> Function() testMain) async {
  final goldenDirectory = Directory('test/goldens');
  if (!goldenDirectory.existsSync()) {
    goldenDirectory.createSync(recursive: true);
  }

  final baseUri = Uri.parse('file://${Directory.current.path}/test/goldens/');

  await GoldenToolkit.runWithConfiguration(
    () async {
      await loadAppFonts();
      await testMain();
    },
    config: GoldenToolkitConfiguration(
      fileComparator: LocalFileComparator(baseUri),
      enableRealShadows: true,
    ),
  );
}
