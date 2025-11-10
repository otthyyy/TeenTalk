import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/feed_sort_option.dart';

class FilterPreferencesService {
  static const String _keyPrefix = 'feed_sort_order_';

  Future<void> saveSortOrder(String section, FeedSortOption sortOrder) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyPrefix$section', sortOrder.value);
  }

  Future<FeedSortOption> getSortOrder(String section) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('$_keyPrefix$section');
    if (value == null) {
      return FeedSortOption.newest;
    }
    return FeedSortOptionX.fromStorage(value);
  }

  Future<void> clearSortOrder(String section) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$section');
  }

  Future<void> clearAllSortOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
