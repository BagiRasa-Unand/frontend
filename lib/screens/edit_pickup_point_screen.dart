import 'package:flutter/material.dart';
import '../models/pickup_point.dart';

// Validator top-level — tidak perlu akses state, mudah diuji terpisah
String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) return 'Nama tidak boleh kosong';
  return null;
}

String? validateAddress(String? value) {
  if (value == null || value.trim().isEmpty) return 'Alamat tidak boleh kosong';
  return null;
}

class EditPickupPointScreen extends StatefulWidget {
  final PickupPoint point;
  const EditPickupPointScreen({super.key, required this.point});

  @override
  State<EditPickupPointScreen> createState() => _EditPickupPointScreenState();
}

class _EditPickupPointScreenState extends State<EditPickupPointScreen> {
  final _formKey = GlobalKey<FormState>();

  // STATE
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Isi controller dari data lama saat layar pertama dibuka
    _nameCtrl = TextEditingController(text: widget.point.name);
    _addressCtrl = TextEditingController(text: widget.point.address);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // VALIDATION + FEEDBACK + NAVIGATION
  Future<void> _simpan() async {
    // VALIDATION — hentikan jika form tidak valid
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // FEEDBACK — nonaktifkan tombol, tampilkan loading
    setState(() => _loading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      // NAVIGATION — kembalikan objek baru; id, lat, lon dibawa apa adanya
      final hasil = widget.point.copyWith(
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      );
      Navigator.pop(context, hasil);
    } finally {
      // Loading selalu dimatikan, termasuk jika terjadi error
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Titik Pengambilan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Lokasi',
                border: OutlineInputBorder(),
              ),
              validator: validateName,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Alamat',
                border: OutlineInputBorder(),
              ),
              validator: validateAddress,
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 8),
            // Koordinat read-only — hanya untuk informasi, tidak dapat diubah
            Text(
              'Koordinat: ${widget.point.latitude.toStringAsFixed(4)}, '
              '${widget.point.longitude.toStringAsFixed(4)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              // Tombol nonaktif saat loading
              onPressed: _loading ? null : _simpan,
              child: _loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
