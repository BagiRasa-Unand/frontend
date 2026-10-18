import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../routes/app_routes.dart';

// STATE: data listing disimpan di sini, bukan di luar widget tree.
class ListingListScreen extends StatefulWidget {
  const ListingListScreen({super.key});

  @override
  State<ListingListScreen> createState() => _ListingListScreenState();
}

class _ListingListScreenState extends State<ListingListScreen> {
  // STATE
  final List<Listing> _listings = [
    const Listing(
      id: 'L001',
      namaMakanan: 'Nasi Padang Sisa Rapat BEM',
      jenisMakanan: 'Nasi & Lauk',
      porsiTersisa: 8,
      punyaKlaimDisetujui: true, 
    ),
    const Listing(
      id: 'L002',
      namaMakanan: 'Roti Canai Kantin Pusat',
      jenisMakanan: 'Roti & Kue',
      porsiTersisa: 12,
      punyaKlaimDisetujui: false,
    ),
    const Listing(
      id: 'L003',
      namaMakanan: 'Soto Ayam Kantin Teknik',
      jenisMakanan: 'Sup & Berkuah',
      porsiTersisa: 5,
      punyaKlaimDisetujui: false,
    ),
    const Listing(
      id: 'L004',
      namaMakanan: 'Martabak Telur Acara HIMATIF',
      jenisMakanan: 'Gorengan',
      porsiTersisa: 20,
      punyaKlaimDisetujui: false,
    ),
  ];

  // NAVIGATION: push ke detail dan tangani id yang dikembalikan.
  Future<void> _bukaDetail(Listing listing) async {
    final idDihapus = await Navigator.pushNamed<String>(
      context,
      AppRoutes.listingDetail,
      arguments: listing,
    );

    // Cek mounted karena pushNamed adalah await — widget bisa sudah unmount.
    if (!mounted) return;

    // FEEDBACK + STATE: hapus item dari list dan beri tahu user.
    if (idDihapus != null) {
      setState(() => _listings.removeWhere((l) => l.id == idDihapus));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing berhasil dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Saya'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _listings.length,
        itemBuilder: (context, index) {
          final listing = _listings[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                listing.namaMakanan,
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                '${listing.jenisMakanan} • ${listing.porsiTersisa} porsi',
                style: theme.textTheme.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _bukaDetail(listing),
            ),
          );
        },
      ),
    );
  }
}
