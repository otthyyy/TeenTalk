import 'analytics_export_delegate.dart';

class StubAnalyticsExportDelegate implements AnalyticsExportDelegate {
  @override
  Future<void> export(String filename, String csvContent) async {
    throw UnsupportedError('Cannot export on this platform.');
  }
}

AnalyticsExportDelegate buildAnalyticsExportDelegate() {
  return StubAnalyticsExportDelegate();
}
