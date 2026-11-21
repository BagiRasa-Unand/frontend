import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/main_shell.dart';

/// Halaman Splash Screen BagiRasa
/// Desain minimalis & clean dengan latar putih polos, logo langsung (tanpa border),
/// dan efek transisi fade-in yang halus.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Animasi Smooth Fade-in
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _textFadeAnimation;
  late final Animation<double> _footerFadeAnimation;

  Timer? _navigationTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Fade-in halus untuk logo
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
      ),
    );

    // Fade-in halus untuk teks judul & tagline
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.85, curve: Curves.easeIn),
      ),
    );

    // Fade-in untuk elemen bawah
    _footerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // Jalankan animasi fade-in
    _controller.forward();

    // Berpindah otomatis ke beranda setelah 2.8 detik
    _navigationTimer = Timer(const Duration(milliseconds: 2800), _navigateToHome);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih bersih
      body: GestureDetector(
        onTap: _navigateToHome, // Tap layar di mana saja untuk lewati langsung
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                // ── Area Tengah (Logo Langsung + Judul + Tagline) ───────────
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Logo Langsung (Tanpa Border / Box, Fade-in Halus)
                          _buildAnimatedLogo(),

                          const SizedBox(height: 20),

                          // 2. Judul BagiRasa
                          _buildBrandTitle(),

                          const SizedBox(height: 10),

                          // 3. Tagline Bersih
                          _buildTagline(),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Area Bawah (Responsif & Anti-Overflow) ───────────────────
                _buildFooter(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Logo Project Langsung (Tanpa Kotak/Border, Fade-in) ─────────────────────
  Widget _buildAnimatedLogo() {
    return FadeTransition(
      opacity: _logoFadeAnimation,
      child: Image.asset(
        'assets/logo.png',
        width: 135,
        height: 135,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.volunteer_activism_rounded,
          size: 72,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // ── Judul Aplikasi: BagiRasa ────────────────────────────────────────────────
  Widget _buildBrandTitle() {
    return FadeTransition(
      opacity: _textFadeAnimation,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.nunitoSans(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
            color: AppColors.textPrimary,
          ),
          children: const [
            TextSpan(text: 'Bagi'),
            TextSpan(
              text: 'Rasa',
              style: TextStyle(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tagline Pendukung ────────────────────────────────────────────────────────
  Widget _buildTagline() {
    return FadeTransition(
      opacity: _textFadeAnimation,
      child: Text(
        'Selamatkan porsi berlebih, salurkan rasa penuh kebaikan di kampus.',
        textAlign: TextAlign.center,
        style: GoogleFonts.nunitoSans(
          fontSize: 14.5,
          height: 1.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // ── Footer Bawah Bersih ──────────────────────────────────────────────────────
  Widget _buildFooter() {
    return FadeTransition(
      opacity: _footerFadeAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 3 Titik Indikator Animasi Pulsa Halus
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final delay = index * 0.25;
                  final progress = (_controller.value + delay) % 1.0;
                  final opacity = 0.25 + (progress * 0.75);

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3.5),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: opacity),
                    ),
                  );
                },
              );
            }),
          ),

          const SizedBox(height: 14),

          // Teks Kredensial SDG (FittedBox agar bebas overflow di layar apa pun)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSdgItem('SDG 2', 'Tanpa Kelaparan'),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 3.5,
                  height: 3.5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.border,
                  ),
                ),
                _buildSdgItem('SDG 12', 'Konsumsi Bertanggung Jawab'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSdgItem(String code, String desc) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          code,
          style: GoogleFonts.nunitoSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.brownDeep,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '• $desc',
          style: GoogleFonts.nunitoSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
