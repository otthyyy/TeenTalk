abstract class AnalyticsExportDelegate {
  Future<void> export(String filename, String csvContent);
}

AnalyticsExportDelegate buildAnalyticsExportDelegate() {
  throw UnsupportedError('Cannot create export delegate on this platform.');
}
