import 'package:flutter/material.dart';
import '../models/listing.dart';

// VALIDATION: fungsi top-level agar bisa diuji isolasi tanpa widget.
// Mengembalikan null = boleh hapus, String = alasan penolakan.
String? validateHapus(Listing l) {
  if (l.punyaKlaimDisetujui) {
    return 'Listing tidak dapat dihapus karena masih ada klaim yang disetujui.';
  }
  return null;
}

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key, required this.listing});

  final Listing listing;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  // STATE
  bool _isDeleting = false;

  Future<void> _hapusListing() async {
    // VALIDATION
    final alasan = validateHapus(widget.listing);
    if (alasan != null) {
      // Validasi gagal: tampilkan alasan, jangan ubah data.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(alasan)),
      );
      return;
    }

    // FEEDBACK: dialog konfirmasi
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Listing?'),
        content: Text(
          'Listing "${widget.listing.namaMakanan}" akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    // null (back gesture) atau false = batal
    if (konfirmasi != true) return;
    if (!mounted) return;

    setState(() => _isDeleting = true);

    try {
      // Simulasi proses jaringan / operasi async.
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return; // cek setelah setiap await sebelum pakai context.

      // NAVIGATION: kirim id kembali ke daftar sebagai sinyal item telah dihapus.
      Navigator.pop(context, widget.listing.id);
    } finally {
      // Dimatikan di finally agar tidak stuck loading jika Future throw.
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = widget.listing;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.namaMakanan),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(label: 'Jenis', value: l.jenisMakanan),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Porsi Tersisa',
                      value: '${l.porsiTersisa} porsi',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Ada Klaim Disetujui',
                      value: l.punyaKlaimDisetujui ? 'Ya' : 'Tidak',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isDeleting ? null : _hapusListing,
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: _isDeleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Hapus Listing'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget kecil agar baris detail tidak duplikat kode.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 144,
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Expanded(
          child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          )),
        ),
      ],
    );
  }
}

