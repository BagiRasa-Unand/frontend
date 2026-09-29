import '../models/item.dart';

/// Sumber data sementara (dummy) penyaluran makanan surplus BagiRasa.
class ItemRepository {
  static const List<Item> _items = [];

  /// Mengambil daftar item makanan.
  /// simulateError: true -> sengaja dibuat gagal untuk menguji error state.
  Future<List<Item>> fetchItems({bool simulateError = false}) async {
    await Future.delayed(
      const Duration(seconds: 2),
    ); // simulasi waktu tunggu server
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _items;
  }
}
