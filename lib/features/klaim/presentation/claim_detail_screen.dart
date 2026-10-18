import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../donasi/data/food_listing.dart';
import '../../donasi/data/food_listing_repository.dart';
import '../../lokasi/data/pickup_point.dart';
import '../../lokasi/data/pickup_point_repository.dart';
import '../../lokasi/presentation/countdown_screen.dart';
import '../data/claim.dart';
import '../data/claim_repository.dart';
import '../logic/claim_detail_controller.dart';
import 'widgets/claim_decision_sheet.dart';

/// Screen "Detail Klaim" (Module B).
/// Menampilkan informasi lengkap klaim, status dinamis, hero maskot,
/// detail listing, titik temu pengambilan dengan peta, serta aksi kontekstual.
class ClaimDetailScreen extends StatelessWidget {
  const ClaimDetailScreen({super.key, required this.claimId});

  final String claimId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ClaimDetailController(
        claimId: claimId,
        claimRepository: ctx.read<ClaimRepository>(),
        foodRepository: ctx.read<FoodListingRepository>(),
        pickupPointRepository: ctx.read<PickupPointRepository>(),
      ),
      child: const _ClaimDetailBody(),
    );
  }
}

class _ClaimDetailBody extends StatelessWidget {
  const _ClaimDetailBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClaimDetailController>();
    final claim = controller.claim;
    final listing = controller.listing;
    final pickupPoint = controller.pickupPoint;

    // Jika klaim atau listing sudah tidak ada, tampilkan pesan ramah dan tombol kembali
    if (claim == null || listing == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Detail Klaim', style: AppTextStyles.heading),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/rasi_empty.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  'Klaim Tidak Ditemukan',
                  style: AppTextStyles.heading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Data klaim atau makanan donasi ini sudah tidak tersedia atau telah dihapus.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ChunkyButton(
                  label: 'KEMBALI',
                  height: 48,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final effectiveStatus = controller.effectiveStatus;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _DetailHeader(onBack: () => Navigator.of(context).pop()),
            if (kShowDemoControls)
              _SimulatorStatusBar(controller: controller),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StatusHeroCard(
                      status: effectiveStatus,
                      claim: claim,
                      listing: listing,
                      queuePosition: controller.queuePosition,
                    ),
                    const SizedBox(height: 16),
                    _ListingItemCard(
                      claim: claim,
                      listing: listing,
                      pickupPoint: pickupPoint,
                    ),
                    const SizedBox(height: 16),
                    _PickupPointCard(
                      pickupPoint: pickupPoint,
                    ),
                    const SizedBox(height: 16),
                    _TimeAndCodeCard(
                      claim: claim,
                      listing: listing,
                      now: controller.now,
                    ),
                  ],
                ),
              ),
            ),
            _BottomActionArea(
              status: effectiveStatus,
              claim: claim,
              listing: listing,
              pickupPoint: pickupPoint,
            ),
          ],
        ),
      ),
    );
  }
}

/// Header bar dengan tombol kembali, judul dengan overline, dan avatar profil.
class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xD9FFF8F5),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 4),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KLAIM',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.primaryDeep,
                      letterSpacing: 0.55,
                    ),
                  ),
                  Text(
                    'Detail Klaim',
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 18,
                      letterSpacing: -0.45,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryDeep,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.surface,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bar simulator demo untuk mengganti status klaim secara langsung.
class _SimulatorStatusBar extends StatelessWidget {
  const _SimulatorStatusBar({required this.controller});

  final ClaimDetailController controller;

  @override
  Widget build(BuildContext context) {
    final effective = controller.effectiveStatus;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDeep,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'PREVIEW STATUS KLAIM',
                    style: AppTextStyles.overline.copyWith(
                      letterSpacing: 0.55,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                '5 Kondisi',
                style: AppTextStyles.badge.copyWith(
                  fontSize: 11,
                  color: AppColors.primaryDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTab(
                  label: 'Menunggu',
                  status: ClaimStatus.menunggu,
                  isSelected: effective == ClaimStatus.menunggu,
                ),
                const SizedBox(width: 6),
                _buildTab(
                  label: 'Antre',
                  status: ClaimStatus.antre,
                  isSelected: effective == ClaimStatus.antre,
                ),
                const SizedBox(width: 6),
                _buildTab(
                  label: 'Diterima',
                  status: ClaimStatus.diterima,
                  isSelected: effective == ClaimStatus.diterima,
                ),
                const SizedBox(width: 6),
                _buildTab(
                  label: 'Ditolak',
                  status: ClaimStatus.ditolak,
                  isSelected: effective == ClaimStatus.ditolak,
                ),
                const SizedBox(width: 6),
                _buildTab(
                  label: 'Dibatalkan',
                  status: ClaimStatus.dibatalkan,
                  isSelected: effective == ClaimStatus.dibatalkan,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required ClaimStatus status,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.setSimulatedStatus(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.amber : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r9999),
          border: isSelected ? null : Border.all(color: AppColors.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppColors.amberDarkShadow : AppColors.border,
              blurRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTextStyles.badge.copyWith(
            fontSize: 12,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// 1. Status Hero Card dengan maskot Rasi, badge status, judul, dan catatan dinamis.
class _StatusHeroCard extends StatelessWidget {
  const _StatusHeroCard({
    required this.status,
    required this.claim,
    required this.listing,
    this.queuePosition,
  });

  final ClaimStatus status;
  final Claim claim;
  final FoodListing listing;
  final int? queuePosition;

  @override
  Widget build(BuildContext context) {
    final heroConfig = _getHeroConfig();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.r20),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.border,
            blurRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kontainer visual Maskot Rasi
              Container(
                width: 96,
                height: 96,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.r16),
                  border: Border.all(color: AppColors.border, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.border,
                      blurRadius: 0,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(child: _buildMascot(status)),
              ),
              const SizedBox(width: 14),
              // Teks status & microcopy
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: heroConfig.badgeBg,
                        borderRadius: BorderRadius.circular(AppRadius.r9999),
                        boxShadow: [
                          BoxShadow(
                            color: heroConfig.badgeShadow,
                            blurRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            heroConfig.badgeIcon,
                            size: 12,
                            color: heroConfig.badgeTextColor,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              heroConfig.badgeLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.badge.copyWith(
                                fontSize: 11,
                                color: heroConfig.badgeTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      heroConfig.heading,
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 18,
                        height: 1.25,
                        letterSpacing: -0.45,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      heroConfig.subtitle,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Info bar notifikasi di bagian bawah hero
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border, width: 2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  heroConfig.infoIcon,
                  size: 16,
                  color: heroConfig.infoColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    heroConfig.infoText,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMascot(ClaimStatus status) {
    final String assetPath;
    switch (status) {
      case ClaimStatus.diterima:
        assetPath = 'assets/images/rasi_happy.png';
        break;
      case ClaimStatus.menunggu:
      case ClaimStatus.antre:
        assetPath = 'assets/images/rasi_waiting.png';
        break;
      case ClaimStatus.ditolak:
      case ClaimStatus.dibatalkan:
        assetPath = 'assets/images/rasi_worried.png';
        break;
    }

    return Image.asset(
      assetPath,
      width: 76,
      height: 76,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // TODO: assets/images/rasi_happy.png atau rasi_waiting.png belum tersedia di direktori assets, menggunakan rasi_empty.png sebagai fallback per Rule 6
        return Image.asset(
          'assets/images/rasi_empty.png',
          width: 76,
          height: 76,
          fit: BoxFit.contain,
        );
      },
    );
  }

  _HeroConfig _getHeroConfig() {
    switch (status) {
      case ClaimStatus.menunggu:
        return const _HeroConfig(
          badgeLabel: 'Menunggu Persetujuan',
          badgeBg: AppColors.amber,
          badgeShadow: AppColors.amberDarkShadow,
          badgeTextColor: AppColors.textPrimary,
          badgeIcon: Icons.hourglass_bottom_rounded,
          heading: 'Menunggu persetujuan pendonor',
          subtitle: 'Pendonor sedang mengecek ketersediaan porsi makananmu di stan.',
          infoIcon: Icons.info_outline_rounded,
          infoColor: AppColors.amber,
          infoText: 'Klaim otomatis batal jika belum disetujui dalam 15 menit.',
        );

      case ClaimStatus.antre:
        final pos = queuePosition ?? 1;
        return _HeroConfig(
          badgeLabel: 'Antrean ke-$pos',
          badgeBg: AppColors.amber,
          badgeShadow: AppColors.amberDarkShadow,
          badgeTextColor: AppColors.textPrimary,
          badgeIcon: Icons.people_outline_rounded,
          heading: 'Kamu dalam antrean makanan',
          subtitle: 'Klaimmu akan otomatis diajukan jika porsi tersedia sebelum waktu habis.',
          infoIcon: Icons.schedule_rounded,
          infoColor: AppColors.amber,
          infoText: 'Antrean ke-$pos. Kamu otomatis dipromosikan jika pemohon sebelumnya batal.',
        );

      case ClaimStatus.diterima:
        return const _HeroConfig(
          badgeLabel: 'Klaim Disetujui (Siap Diambil)',
          badgeBg: AppColors.teal,
          badgeShadow: AppColors.tealDark,
          badgeTextColor: AppColors.surface,
          badgeIcon: Icons.check_circle_outline_rounded,
          heading: 'Klaim diterima! Siap diambil',
          subtitle: 'Tunjukkan kode klaim ke pemilik stan saat pengambilan makanan.',
          infoIcon: Icons.check_circle_rounded,
          infoColor: AppColors.teal,
          infoText: 'Segera ambil makanan di stan sebelum batas waktu berakhir.',
        );

      case ClaimStatus.ditolak:
        final reason = claim.rejectReason != null
            ? 'Alasan: ${claim.rejectReason}'
            : 'Pemilik stan tidak dapat memenuhi klaim ini saat ini.';
        return _HeroConfig(
          badgeLabel: 'Klaim Ditolak',
          badgeBg: AppColors.danger,
          badgeShadow: AppColors.dangerDark,
          badgeTextColor: AppColors.surface,
          badgeIcon: Icons.cancel_outlined,
          heading: 'Klaim belum disetujui',
          subtitle: reason,
          infoIcon: Icons.info_outline_rounded,
          infoColor: AppColors.danger,
          infoText: 'Jangan berkecil hati, kamu masih bisa mencari makanan surplus lainnya!',
        );

      case ClaimStatus.dibatalkan:
        final reason = claim.cancelReason != null
            ? 'Alasan: ${claim.cancelReason}'
            : 'Klaim dibatalkan oleh kamu sendiri.';
        return _HeroConfig(
          badgeLabel: 'Klaim Dibatalkan',
          badgeBg: AppColors.textSecondary,
          badgeShadow: AppColors.textPrimary,
          badgeTextColor: AppColors.surface,
          badgeIcon: Icons.do_not_disturb_alt_rounded,
          heading: 'Klaim telah dibatalkan',
          subtitle: reason,
          infoIcon: Icons.info_outline_rounded,
          infoColor: AppColors.textSecondary,
          infoText: 'Klaim ini sudah tidak aktif dan porsi telah dikembalikan ke stan.',
        );
    }
  }
}

class _HeroConfig {
  const _HeroConfig({
    required this.badgeLabel,
    required this.badgeBg,
    required this.badgeShadow,
    required this.badgeTextColor,
    required this.badgeIcon,
    required this.heading,
    required this.subtitle,
    required this.infoIcon,
    required this.infoColor,
    required this.infoText,
  });

  final String badgeLabel;
  final Color badgeBg;
  final Color badgeShadow;
  final Color badgeTextColor;
  final IconData badgeIcon;
  final String heading;
  final String subtitle;
  final IconData infoIcon;
  final Color infoColor;
  final String infoText;
}

/// Card 1: Listing Item Card
class _ListingItemCard extends StatelessWidget {
  const _ListingItemCard({
    required this.claim,
    required this.listing,
    required this.pickupPoint,
  });

  final Claim claim;
  final FoodListing listing;
  final PickupPoint? pickupPoint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r20),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.border,
            blurRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Foto dengan badge Halal
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border, width: 2),
              borderRadius: BorderRadius.circular(AppRadius.r16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildPhoto(listing.photoPath),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDeep,
                        borderRadius: BorderRadius.circular(AppRadius.r9999),
                      ),
                      child: Text(
                        'Halal',
                        style: AppTextStyles.badge.copyWith(
                          fontSize: 10,
                          color: AppColors.surface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info porsi, nama makanan, dan nama stan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.r9999),
                  ),
                  child: Text(
                    '${claim.quantity} Porsi Diklaim',
                    style: AppTextStyles.badge.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  listing.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      size: 14,
                      color: AppColors.primaryDeep,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pickupPoint?.name ?? 'Kantin Kampus',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto(String? path) {
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return Container(
      color: AppColors.surfaceWarm,
      child: const Center(
        child: Icon(Icons.restaurant_rounded, size: 32, color: AppColors.slate),
      ),
    );
  }
}

/// Card 2: Titik Pengambilan (Pickup Point) dengan preview peta FlutterMap.
class _PickupPointCard extends StatelessWidget {
  const _PickupPointCard({required this.pickupPoint});

  final PickupPoint? pickupPoint;

  @override
  Widget build(BuildContext context) {
    final lat = pickupPoint?.latitude ?? -0.9140;
    final lng = pickupPoint?.longitude ?? 100.4590;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r20),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.border,
            blurRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0x1A006A65),
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 16,
                  color: AppColors.tealDeep,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Titik Pengambilan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.28,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.rescueBadgeBg,
                  borderRadius: BorderRadius.circular(AppRadius.r9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_walk_rounded,
                      size: 13,
                      color: AppColors.tealDarkText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '250m dari lokasimu',
                      style: AppTextStyles.badge.copyWith(
                        fontSize: 11,
                        color: AppColors.tealDarkText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            pickupPoint?.name ?? 'Kantin Teknik Sisfo (Stan 04 - Bu Joko)',
            style: AppTextStyles.heading.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            pickupPoint?.address ??
                'Gedung GKB Lt. 1 Sayap Barat, Kampus Sukolilo (dekat tangga utama)',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          // Preview Peta Static Interaktif dengan FlutterMap
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.r12),
            child: Container(
              height: 96,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(AppRadius.r12),
              ),
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(lat, lng),
                      initialZoom: 15.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.bagirasa',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(lat, lng),
                            width: 32,
                            height: 32,
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: GestureDetector(
                      onTap: () {
                        // TODO(stub): Integrasi navigasi eksternal Google Maps
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur ini belum tersedia')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(AppRadius.r8),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D000000),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Buka di Google Maps',
                              style: AppTextStyles.badge.copyWith(
                                fontSize: 11,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Icon(
                              Icons.near_me_outlined,
                              size: 14,
                              color: AppColors.primaryDeep,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card 3: Waktu, Tanggal & Kode Referensi Transaksi
class _TimeAndCodeCard extends StatelessWidget {
  const _TimeAndCodeCard({
    required this.claim,
    required this.listing,
    required this.now,
  });

  final Claim claim;
  final FoodListing listing;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final codeDigits = claim.id.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0');
    final code = '#BGR-${codeDigits.length > 4 ? codeDigits.substring(0, 4) : codeDigits}';

    final createdHour = claim.createdAt.hour.toString().padLeft(2, '0');
    final createdMin = claim.createdAt.minute.toString().padLeft(2, '0');
    final waktuDiajukan = 'Hari ini, $createdHour.$createdMin WIB';

    final expiresHour = listing.expiresAt.hour.toString().padLeft(2, '0');
    final expiresMin = listing.expiresAt.minute.toString().padLeft(2, '0');
    final batasAmbil = '$expiresHour.$expiresMin WIB';

    final remaining = listing.timeLeftAt(now);
    final remainingText = '(${remaining.inMinutes} mnt)';

    final carbonKg = (claim.quantity * 1.4).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r20),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.border,
            blurRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Baris ID Transaksi Klaim
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'ID Transaksi Klaim',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kode transaksi klaim disalin')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.r8),
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          code,
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDeep,
                            letterSpacing: 0.35,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.copy_rounded,
                          size: 13,
                          color: AppColors.primaryDeep,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Baris Waktu Diajukan dan Batas Ambil
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waktu Diajukan',
                      style: AppTextStyles.overline.copyWith(
                        letterSpacing: 0.22,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      waktuDiajukan,
                      style: AppTextStyles.heading.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Batas Ambil',
                      style: AppTextStyles.overline.copyWith(
                        letterSpacing: 0.22,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        Text(
                          batasAmbil,
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDeep,
                          ),
                        ),
                        Text(
                          remainingText,
                          style: AppTextStyles.badge.copyWith(
                            fontSize: 11,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Micro-card Jejak Karbon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.volunteer_activism_rounded,
                  size: 18,
                  color: AppColors.tealDeep,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.brownMid,
                        height: 1.35,
                      ),
                      children: [
                        const TextSpan(text: 'Kamu menyelamatkan sekitar '),
                        TextSpan(
                          text: '$carbonKg kg jejak karbon',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.tealDeep,
                          ),
                        ),
                        const TextSpan(text: ' makanan berlebih hari ini!'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Area tombol aksi lengket di bagian bawah layar.
class _BottomActionArea extends StatelessWidget {
  const _BottomActionArea({
    required this.status,
    required this.claim,
    required this.listing,
    required this.pickupPoint,
  });

  final ClaimStatus status;
  final Claim claim;
  final FoodListing listing;
  final PickupPoint? pickupPoint;

  @override
  Widget build(BuildContext context) {
    if (status == ClaimStatus.ditolak || status == ClaimStatus.dibatalkan) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xF2FFFFFF),
        border: Border(
          top: BorderSide(color: AppColors.border, width: 2),
        ),
      ),
      child: status == ClaimStatus.diterima
          ? ChunkyButton(
              label: 'LIHAT WAKTU PENGAMBILAN',
              height: 48,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CountdownScreen(
                      pickupDeadline: listing.expiresAt,
                      listingName: listing.name,
                      pickupPointName: pickupPoint?.name ?? '',
                      orderCode: '#BGR-${claim.id.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0')}',
                    ),
                  ),
                );
              },
            )
          : GestureDetector(
              onTap: () => showClaimDecisionSheet(
                context,
                claim,
                ClaimDecision.cancel,
              ),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.r16),
                  border: Border.all(color: AppColors.border, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.border,
                      blurRadius: 0,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cancel_outlined,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'BATALKAN KLAIM',
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.28,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
