import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/feature_card.dart';
import '../widgets/glass_pill.dart';
import '../widgets/metric_card.dart';

/// Halaman Splash & Onboarding Aplikasi BagiRasa
/// Didesain presisi berdasarkan spesifikasi Figma & PRD Kampus BagiRasa.
class SplashOnboardingScreen extends StatelessWidget {
  const SplashOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.paddingScreenHorizontal,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header Branding
                  _buildHeaderBranding(),
                  const SizedBox(height: 24),

                  // 2. Modern Organic Hero Card
                  _buildHeroCard(),
                  const SizedBox(height: 24),

                  // 3. Narrative Headline Section
                  _buildNarrativeHeader(),
                  const SizedBox(height: 24),

                  // 4. Metrics Strip
                  _buildMetricsStrip(),
                  const SizedBox(height: 24),

                  // 5. Feature Highlights
                  _buildFeatureHighlights(),
                  const SizedBox(height: 28),

                  // 6. Action CTAs
                  _buildActionButtons(context),
                  const SizedBox(height: 24),

                  // 7. Campus Credential Footer
                  _buildFooter(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Header Branding dengan Identity Capsule & Subtitle
  Widget _buildHeaderBranding() {
    return Column(
      children: [
        GlassPill(
          backgroundColor: Colors.white.withValues(alpha: 0.8),
          borderColor: const Color.fromRGBO(0, 0, 0, 0.04),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Logo
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.volunteer_activism,
                    size: 14,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.gapSm),
              
              // App Name
              Text('BagiRasa', style: AppTextStyles.brandTitle),
              const SizedBox(width: AppSpacing.gapSm),
              
              // Dot Separator
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFFC4C8BC),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.gapSm),
              
              // Badge KAMPUS
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.badgeGreenBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: Text('KAMPUS', style: AppTextStyles.badgeGreen),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Platform Berbagi Makanan Surplus Kampus',
          style: AppTextStyles.brandSubtitle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Organic Hero Card dengan Live Status & SDG Glass Pill
  Widget _buildHeroCard() {
    return Container(
      height: 224,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 20,
            offset: Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
        child: Stack(
          children: [
            // Background Image (dengan Fallback Gradient)
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=800',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2D5A3D), Color(0xFF1E3F2A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        size: 64,
                        color: Colors.white24,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(0, 0, 0, 0.5),
                      Colors.transparent,
                      Color.fromRGBO(0, 0, 0, 0.3),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),

            // Top Live Status Capsule
            Positioned(
              top: 14,
              left: 14,
              child: GlassPill(
                backgroundColor: const Color.fromRGBO(0, 0, 0, 0.4),
                borderColor: const Color.fromRGBO(255, 255, 255, 0.15),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.statusLiveGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Live Donasi Aktif', style: AppTextStyles.liveStatusPill),
                  ],
                ),
              ),
            ),

            // Bottom SDG Glass Pill
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: GlassPill(
                backgroundColor: const Color.fromRGBO(255, 255, 255, 0.85),
                borderColor: const Color.fromRGBO(255, 255, 255, 0.6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                borderRadius: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.eco_rounded,
                      size: 14,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'SDG 2 & 12 • Kampus Bebas Kelaparan',
                        style: AppTextStyles.sdgPill,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  /// Narrative Header Section
  Widget _buildNarrativeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamatkan Makanan Berlebih, Bantu Sesama di Kampus',
          style: AppTextStyles.heroHeading,
        ),
        const SizedBox(height: 8.75),
        Text(
          'Hubungkan warung, kantin, dan mahasiswa untuk mengurangi food waste demi kampus bebas kelaparan (SDG 2 & 12).',
          style: AppTextStyles.heroSubheading,
        ),
      ],
    );
  }

  /// Metrics Strip (500+ Porsi Terselamatkan, 12+ Kantin Mitra Kampus)
  Widget _buildMetricsStrip() {
    return Row(
      children: [
        MetricCard(
          icon: Icons.soup_kitchen_rounded,
          iconColor: AppColors.primaryGreen,
          iconBgColor: const Color.fromRGBO(45, 90, 61, 0.1),
          valueText: '500+ Porsi',
          labelText: 'Terselamatkan',
        ),
        const SizedBox(width: AppSpacing.gapMd),
        MetricCard(
          icon: Icons.storefront_rounded,
          iconColor: AppColors.accentGold,
          iconBgColor: AppColors.accentGoldBg,
          valueText: '12+ Kantin',
          labelText: 'Mitra Kampus',
        ),
      ],
    );
  }

  /// Feature Highlights List
  Widget _buildFeatureHighlights() {
    return Column(
      children: [
        FeatureCard(
          icon: Icons.near_me_rounded,
          iconColor: AppColors.primaryGreen,
          iconBgColor: const Color.fromRGBO(45, 90, 61, 0.1),
          title: 'Listing Berbasis Lokasi',
          tagText: 'TERDEKAT',
          tagBgColor: const Color.fromRGBO(200, 232, 208, 0.4),
          tagTextStyle: AppTextStyles.featureTagGreen,
          description:
              'Pantau donasi makanan terdekat dari kantin & fakultas dengan navigasi radius akurat.',
        ),
        const SizedBox(height: 10),
        FeatureCard(
          icon: Icons.volunteer_activism_rounded,
          iconColor: AppColors.accentGold,
          iconBgColor: const Color.fromRGBO(112, 92, 48, 0.1),
          title: 'Mudah & Bermartabat',
          tagText: 'DONASI & KLAIM',
          tagBgColor: const Color.fromRGBO(240, 232, 219, 0.6),
          tagTextStyle: AppTextStyles.featureTagGold,
          description:
              'Donasikan surplus makanan dari acara BEM atau ajukan klaim porsi secara mudah dan bermartabat.',
        ),
        const SizedBox(height: 10),
        FeatureCard(
          icon: Icons.timer_rounded,
          iconColor: AppColors.textSecondary,
          iconBgColor: const Color(0xFFE4E0D8),
          title: 'Pengingat & Higienitas',
          tagText: 'REAL-TIME',
          tagBgColor: const Color(0xFFEAE6DE),
          tagTextStyle: AppTextStyles.featureTagMuted,
          description:
              'Pengingat otomatis dan hitung mundur higienitas sebelum porsi makanan melewati masa konsumsi aman.',
        ),
      ],
    );
  }

  /// Action CTAs (Mulai Sekarang & Masuk Ke Akun)
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          label: 'Mulai Sekarang',
          isPrimary: true,
          icon: Icons.arrow_forward_rounded,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Selamat datang di BagiRasa! (Alur Donasi/Klaim)'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        CustomButton(
          label: 'Masuk Ke Akun',
          isPrimary: false,
          icon: Icons.login_rounded,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Halaman Masuk/Login'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Campus Credential Footer
  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school_rounded,
              size: 14,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(width: 6),
            Text(
              'Universitas Andalas • Padang',
              style: AppTextStyles.footerText,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'INISIATIF MAHASISWA PROGRAMMING MOBILE 2026',
          style: AppTextStyles.footerSubtext,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
