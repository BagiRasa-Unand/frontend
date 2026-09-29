import 'package:flutter/material.dart';
import '../utils/validators.dart'; // import validators untuk validasi catatan

/// Layar Form Catatan – pengguna mengetik catatan lalu menekan Simpan.
/// Hasil catatan dikembalikan ke layar Detail melalui Navigator.pop.
class CatatanFormScreen extends StatefulWidget {
  const CatatanFormScreen({super.key});

  @override
  State<CatatanFormScreen> createState() => _CatatanFormScreenState();
}

class _CatatanFormScreenState extends State<CatatanFormScreen> {
  // key untuk Form dan controller teks catatan
  final _formKey = GlobalKey<FormState>();
  final _catatanController = TextEditingController();

  // buang controller saat layar ditutup
  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  // dijalankan saat tombol Simpan ditekan
  void _simpan() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    // Tutup layar ini sambil MEMBAWA teks catatan ke layar sebelumnya
    Navigator.pop(context, _catatanController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6),
        title: const Text(
          'Tulis Catatan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E3230),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Field catatan – minimal 5 karakter (aturan dari validators.dart)
              TextFormField(
                controller: _catatanController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  hintText: 'Tulis catatanmu di sini...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    Validators.minLength(value, 5, fieldName: 'Catatan'),
              ),
              const SizedBox(height: 16),

              // Tombol Simpan – mengembalikan teks ke layar Detail
              FilledButton(
                onPressed: _simpan,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5A3D),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
