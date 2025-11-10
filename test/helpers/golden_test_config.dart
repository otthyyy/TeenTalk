import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> loadGoldenTestFonts() async {
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    final ahem = File('fonts/Ahem.ttf');
    final fontLoader = FontLoader('Ahem');
    if (await ahem.exists()) {
      fontLoader.addFont(Future.value(ByteData.view(await ahem.readAsBytes())));
      await fontLoader.load();
    }
  }
}
