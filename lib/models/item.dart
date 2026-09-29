/// Model data utama aplikasi BagiRasa.
/// Menyimpan informasi surplus makanan kampus.
class Item {
  final String id;
  final String title;
  final String subtitle;
  final String description;

  const Item({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
