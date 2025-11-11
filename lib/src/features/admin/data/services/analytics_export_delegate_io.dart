import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'analytics_export_delegate.dart';

class IoAnalyticsExportDelegate implements AnalyticsExportDelegate {
  @override
  Future<void> export(String filename, String csvContent) async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/$filename';
    final file = File(path);
    await file.writeAsString(csvContent);

    await Share.shareXFiles(
      [XFile(path)],
      text: 'Analytics Report',
      subject: 'Analytics Report - ${DateTime.now()}',
    );
  }
}

AnalyticsExportDelegate buildAnalyticsExportDelegate() => IoAnalyticsExportDelegate();
