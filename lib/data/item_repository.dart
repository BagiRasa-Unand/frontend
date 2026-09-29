import '../models/item.dart';

/// Sumber data sementara (dummy). Nanti bisa diganti dengan API/database.
/// Data disesuaikan dengan konteks aplikasi BagiRasa (donasi makanan surplus kampus).
class ItemRepository {
  // Data dummy listing donasi makanan surplus
  static const List<Item> _items = [
    Item(
      id: '1',
      title: 'Nasi Kotak Sisa Rapat BEM',
      subtitle: 'Tersedia 20 porsi • Gedung Student Center Lt. 2',
      description:
          'Nasi kotak sisa rapat BEM Fakultas Teknik, masih dalam kondisi baik dan layak konsumsi. '
          'Tersedia 20 porsi berisi nasi, ayam goreng, tempe, dan sayur asem. '
          'Batas konsumsi aman: 3 jam dari sekarang. Hubungi panitia di lobi untuk pengambilan.',
    ),
    Item(
      id: '2',
      title: 'Surplus Makan Siang Kantin Pusat',
      subtitle: 'Tersedia 15 porsi • Kantin Pusat Unand',
      description:
          'Kantin Pusat Universitas Andalas menyisakan 15 porsi makan siang berupa nasi rendang dan '
          'gulai ayam. Semua makanan dimasak pagi ini dan masih segar. '
          'Pengambilan gratis, cukup tunjukkan akun BagiRasa kepada petugas kantin.',
    ),
    Item(
      id: '3',
      title: 'Kue & Snack Seminar Fakultas',
      subtitle: 'Tersedia 30 pcs • Aula Fakultas Ekonomi',
      description:
          'Sisa snack seminar nasional Fakultas Ekonomi: kue lapis, risol, dan onde-onde. '
          'Total sekitar 30 pieces, dikemas per 5 buah dalam kantong plastik. '
          'Dipersilakan diambil langsung di meja registrasi Aula FE sebelum pukul 17.00 WIB.',
    ),
  ];

  /// Mengambil daftar item.
  /// [simulateError]: jika true, sengaja melempar Exception untuk menguji error state.
  Future<List<Item>> fetchItems({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi waktu tunggu server
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _items;
  }
}
