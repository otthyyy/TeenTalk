import 'dart:html' as html;
import 'analytics_export_delegate.dart';

class WebAnalyticsExportDelegate implements AnalyticsExportDelegate {
  @override
  Future<void> export(String filename, String csvContent) async {
    final bytes = csvContent.codeUnits;
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement()
      ..href = url
      ..style.display = 'none'
      ..download = filename;
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}

AnalyticsExportDelegate buildAnalyticsExportDelegate() => WebAnalyticsExportDelegate();
