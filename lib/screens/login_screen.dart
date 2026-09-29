import 'package:flutter/material.dart';
import '../utils/validators.dart'; // (1) import validators
import '../routes/app_routes.dart'; // (1) import app_routes

/// Layar Login BagiRasa.
/// Diubah menjadi StatefulWidget untuk mendukung Form, controller, dan validasi.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // (1) key untuk Form dan controller untuk setiap field
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // (2) buang controller saat layar ditutup
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // (3) dijalankan saat tombol Masuk ditekan
  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return; // ada isian yang salah -> berhenti

    // Isian benar -> pindah ke Home, Login dibuang dari stack
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // warna dari Praktikum 1
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              // (4) bungkus field dengan Form
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),

                    // Logo & Branding (tampilan dari Praktikum 1, tidak diubah)
                    const Icon(
                      Icons.volunteer_activism_rounded,
                      size: 56,
                      color: Color(0xFF2D5A3D),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'BagiRasa',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E3230),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Masuk ke akun kampusmu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5A605B),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // (5) TextFormField Email dengan controller dan validator
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'contoh@student.unand.ac.id',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: Validators.email, // validasi dari validators.dart
                    ),
                    const SizedBox(height: 16),

                    // (5) TextFormField Password dengan controller dan validator
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: Validators.password, // validasi dari validators.dart
                    ),
                    const SizedBox(height: 28),

                    // (6) Tombol Masuk memanggil _submit
                    FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5A3D),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
