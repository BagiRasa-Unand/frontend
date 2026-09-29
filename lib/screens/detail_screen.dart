import 'package:flutter/material.dart';
import '../models/item.dart';
import '../routes/app_routes.dart'; // import AppRoutes untuk navigasi ke CatatanForm

/// Layar Detail – menampilkan informasi lengkap satu item donasi.
/// Diubah menjadi StatefulWidget untuk menyimpan state catatan.
class DetailScreen extends StatefulWidget {
  // (1) data yang DITERIMA dari Home
  final Item item;

  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // (2) menyimpan catatan yang dikirim balik dari form
  String? _catatan;

  // (3) buka form, TUNGGU hasilnya, lalu tampilkan
  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );
    if (!mounted || hasil == null) return; // null = pengguna batal/back
    setState(() => _catatan = hasil);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Di dalam State, data widget dibaca dengan "widget.item"
    final item = widget.item;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E3230),
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Judul item
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E3230),
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle / keterangan singkat
          Text(
            item.subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5A605B),
            ),
          ),
          const SizedBox(height: 16),

          // Deskripsi lengkap
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: const Border.fromBorderSide(
                BorderSide(color: Color.fromRGBO(0, 0, 0, 0.06)),
              ),
            ),
            child: Text(
              item.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2E3230),
                height: 1.6,
              ),
            ),
          ),

          const Divider(height: 32),

          // Tampilkan catatan (atau placeholder jika belum ada)
          Text(
            _catatan == null ? 'Belum ada catatan.' : 'Catatan: $_catatan',
            style: TextStyle(
              fontSize: 14,
              color: _catatan == null
                  ? const Color(0xFF74796E)
                  : const Color(0xFF2E3230),
              fontStyle:
                  _catatan == null ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          const SizedBox(height: 16),

          // Tombol Tulis Catatan -> membuka CatatanFormScreen
          FilledButton.icon(
            onPressed: _bukaFormCatatan,
            icon: const Icon(Icons.edit_note),
            label: const Text('Tulis Catatan'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2D5A3D),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
