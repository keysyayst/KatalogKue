import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class SearchHistoryHiveService {
  static const String _boxName = 'search_history';
  Box<String>? _box;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<void> addSearch(String query) async {
    if (_box == null) return;
    if (query.trim().isEmpty) return;

    final trimmedQuery = query.trim().toLowerCase();
    final existingIndex = _box!.values.toList().indexOf(trimmedQuery);

    if (existingIndex != -1) {
      await _box!.deleteAt(existingIndex);
    }

    await _box!.add(trimmedQuery);

    while (_box!.length > 20) {
      await _box!.deleteAt(0);
    }
  }

  List<String> getSearchHistory() {
    if (_box == null) return [];
    return _box!.values.toList().reversed.toList();
  }

  Future<void> removeSearch(String query) async {
    if (_box == null) return;
    final index = _box!.values.toList().indexOf(query.trim().toLowerCase());
    if (index != -1) {
      await _box!.deleteAt(index);
    }
  }

  Future<void> clearHistory() async {
    if (_box == null) return;
    await _box!.clear();
  }

  Future<void> close() async {
    await _box?.close();
  }
}
