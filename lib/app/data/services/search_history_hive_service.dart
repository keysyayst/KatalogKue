import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class SearchHistoryHiveService {
  static const String _boxName = 'search_history';
  Box<String>? _box;

  /// Inisialisasi Hive box
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    _box = await Hive.openBox<String>(_boxName);
  }

  /// Simpan query pencarian ke history
  /// Query akan ditambahkan ke awal list (paling baru)
  Future<void> addSearch(String query) async {
    if (_box == null) {
      throw Exception('SearchHistoryHiveService belum diinisialisasi');
    }

    // Abaikan query kosong atau hanya spasi
    if (query.trim().isEmpty) return;

    final trimmedQuery = query.trim().toLowerCase();

    // Hapus query yang sama jika sudah ada (untuk memindahkan ke paling atas)
    final existingIndex = _box!.values.toList().indexOf(trimmedQuery);
    if (existingIndex != -1) {
      await _box!.deleteAt(existingIndex);
    }

    // Tambahkan query baru di awal (index 0)
    await _box!.add(trimmedQuery);

    // Batasi history maksimal 20 item
    // Hapus item terlama jika melebihi batas
    while (_box!.length > 20) {
      await _box!.deleteAt(0);
    }
  }

  /// Ambil semua riwayat pencarian
  /// Diurutkan dari yang terbaru (terakhir ditambahkan)
  List<String> getSearchHistory() {
    if (_box == null) {
      throw Exception('SearchHistoryHiveService belum diinisialisasi');
    }

    // Balik urutan agar yang terbaru di awal
    return _box!.values.toList().reversed.toList();
  }

  /// Hapus satu item dari riwayat pencarian
  Future<void> removeSearch(String query) async {
    if (_box == null) {
      throw Exception('SearchHistoryHiveService belum diinisialisasi');
    }

    final index = _box!.values.toList().indexOf(query.trim().toLowerCase());
    if (index != -1) {
      await _box!.deleteAt(index);
    }
  }

  /// Hapus semua riwayat pencarian
  Future<void> clearHistory() async {
    if (_box == null) {
      throw Exception('SearchHistoryHiveService belum diinisialisasi');
    }

    await _box!.clear();
  }

  /// Tutup box (biasanya dipanggil saat aplikasi ditutup)
  Future<void> close() async {
    await _box?.close();
  }
}
