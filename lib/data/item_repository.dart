import '../models/item.dart';

class ItemRepository {
  static const List<Item> _items = [
    Item(
      id: '1',
      title: 'Nasi Ayam Geprek & Sayur',
      subtitle: 'Warung Mbak Sri (Kantin Utama)',
      description: 'Nasi ayam geprek porsi lengkap dengan sayur asam. Sisa 8 porsi.',
    ),
    Item(
      id: '2',
      title: 'Aneka Roti Manis & Donat',
      subtitle: 'Bakery Koperasi Mahasiswa',
      description: 'Sisa produksi hari ini, masih sangat layak konsumsi. Sisa 5 porsi.',
    ),
    Item(
      id: '3',
      title: 'Nasi Kotak Seminar Workshop',
      subtitle: 'Panitia Kuliah Tamu Al Fasilkom',
      description: 'Nasi kotak lengkap ayam bakar, sambal, dan sayur. Sisa 12 porsi.',
    ),
  ];

  Future<List<Item>> fetchItems({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2));
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _items;
  }
}
