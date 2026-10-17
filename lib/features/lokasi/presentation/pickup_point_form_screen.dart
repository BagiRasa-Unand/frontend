import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../data/pickup_point.dart';
import '../data/pickup_point_repository.dart';
import '../logic/pickup_point_form_notifier.dart';

/// Screen for creating or updating a [PickupPoint] (Module C CREATE/UPDATE).
///
/// Matches the BagiRasa design spec with interactive FlutterMap,
/// dashed upload box with image_picker, chunky inputs, and validation.
class PickupPointFormScreen extends StatelessWidget {
  const PickupPointFormScreen({super.key, this.point});

  /// null = create mode, non-null = edit mode.
  final PickupPoint? point;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PickupPointFormNotifier(point: point),
      child: const _PickupPointFormContent(),
    );
  }
}

class _PickupPointFormContent extends StatefulWidget {
  const _PickupPointFormContent();

  @override
  State<_PickupPointFormContent> createState() =>
      _PickupPointFormContentState();
}

class _PickupPointFormContentState extends State<_PickupPointFormContent> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _noteController;
  late final MapController _mapController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final notifier = context.read<PickupPointFormNotifier>();
    _nameController = TextEditingController(text: notifier.name);
    _addressController = TextEditingController(text: notifier.address);
    _noteController = TextEditingController(text: notifier.note);
    _mapController = MapController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        context.read<PickupPointFormNotifier>().setPhotoPath(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  void _showImagePickerSheet() {
    final notifier = context.read<PickupPointFormNotifier>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih Sumber Foto',
                  style: AppTextStyles.heading,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.primary),
                  title: Text('Ambil dengan Kamera',
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded,
                      color: AppColors.tealDeep),
                  title: Text('Pilih dari Galeri Kampus',
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (notifier.photoPath != null) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.danger),
                    title: Text('Hapus Foto',
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(ctx);
                      notifier.setPhotoPath(null);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectTime({required bool isOpenTime}) async {
    final notifier = context.read<PickupPointFormNotifier>();
    final currentStr = isOpenTime ? notifier.openTime : notifier.closeTime;
    final parts = currentStr.replaceAll('WIB', '').trim().replaceAll('.', ':').split(':');
    final initialHour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 12 : 12;
    final initialMinute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.surface,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isOpenTime) {
        notifier.setOpenTime(picked);
      } else {
        notifier.setCloseTime(picked);
      }
    }
  }

  void _onSave() {
    final notifier = context.read<PickupPointFormNotifier>();
    if (notifier.validate()) {
      final repo = Provider.of<PickupPointRepository>(context, listen: false);
      notifier.save(repo);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Titik pengambilan disimpan'),
          backgroundColor: AppColors.tealDeep,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PickupPointFormNotifier>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Sticky Header / App Bar ─────────────────────────────────────
            _HeaderBar(onBack: () => Navigator.of(context).pop()),

            // ── Scrollable Form Body ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Context Title & Mitra Donatur Badge
                    _HeaderContext(isEdit: notifier.isEdit),
                    const SizedBox(height: 12),

                    // Map Section
                    _MapCard(
                      mapController: _mapController,
                      notifier: notifier,
                    ),
                    if (notifier.pinError != null) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          notifier.pinError!,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Main Chunky Form Container Card
                    _FormCard(
                      nameController: _nameController,
                      addressController: _addressController,
                      noteController: _noteController,
                      notifier: notifier,
                      onPickPhoto: _showImagePickerSheet,
                      onSelectTime: _selectTime,
                    ),
                    const SizedBox(height: 16),

                    // Mascot Rasi Micro-encouragement Box
                    const _MascotEncouragementBox(),
                    const SizedBox(height: 16),

                    // Action Buttons (SIMPAN & BATAL)
                    _ActionButtons(
                      onSave: _onSave,
                      onCancel: () => Navigator.of(context).pop(),
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

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Custom header matching Figma CSS: 64px tall, white back button, overline "BAGIRASA",
/// title "Form Titik Pengambilan", and circular avatar icon on the right.
class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // 44x44 Chunky Back Button
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.border,
                      blurRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                    onTap: onBack,
                    child: const Center(
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BAGIRASA',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 11,
                      height: 11 / 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.55,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Form Titik Pengambilan',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      height: 22 / 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Circular Avatar Button
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryDeep,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.brownDeep,
                  blurRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                color: AppColors.surface,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header title row + Mitra Donatur badge + descriptive subtitle.
class _HeaderContext extends StatelessWidget {
  const _HeaderContext({required this.isEdit});

  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // 10x10 Orange Dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isEdit ? 'Ubah Titik Pengambilan' : 'Tambah Titik Baru',
                  style: AppTextStyles.modalTitle,
                ),
              ],
            ),
            // Mitra Donatur Pill Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.primarySoftDeep,
                    blurRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    size: 13,
                    color: AppColors.primaryDeep,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'MITRA DONATUR',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 11,
                      height: 14 / 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.275,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Tentukan lokasi akurat agar mahasiswa mudah menemukan makananmu.',
          style: AppTextStyles.caption.copyWith(
            fontSize: 14,
            height: 20 / 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Interactive FlutterMap card (height 264px) with selectable pin,
/// "Gunakan lokasi saya" stub button, and coordinate accuracy bar.
class _MapCard extends StatelessWidget {
  const _MapCard({
    required this.mapController,
    required this.notifier,
  });

  final MapController mapController;
  final PickupPointFormNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final currentCenter = LatLng(
      notifier.latitude ?? kCampusCenterLat,
      notifier.longitude ?? kCampusCenterLng,
    );

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.border,
            blurRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 224px Map Container
          Container(
            height: 224,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: currentCenter,
                    initialZoom: 16.0,
                    onTap: (_, latlng) {
                      notifier.setPin(latlng.latitude, latlng.longitude);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.first_project',
                    ),
                    if (notifier.latitude != null &&
                        notifier.longitude != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              notifier.latitude!,
                              notifier.longitude!,
                            ),
                            width: 140,
                            height: 72,
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Floating Storefront Name Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColors.border,
                                        blurRadius: 0,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.storefront_rounded,
                                        size: 13,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 90),
                                        child: Text(
                                          notifier.name.trim().isNotEmpty
                                              ? notifier.name.trim()
                                              : 'Kantin Baru',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 12,
                                            height: 16 / 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Orange 36x36 Pin Marker with Shadow
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryDark,
                                        blurRadius: 0,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      color: AppColors.surface,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Top Map Overlay Bar: "Gunakan lokasi saya" + "Peta Kampus"
                Positioned(
                  left: 12,
                  right: 12,
                  top: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // STUB Button per ui_rules.md
                      GestureDetector(
                        onTap: () {
                          // TODO(stub): GPS current location retrieval
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur ini belum tersedia'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.indigoSoft,
                                blurRadius: 0,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.my_location_rounded,
                                size: 14,
                                color: AppColors.gpsIndigo,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Gunakan lokasi saya',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 11,
                                  height: 14 / 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.22,
                                  color: AppColors.gpsIndigo,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // "Peta Kampus" badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          'Peta Kampus',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 11,
                            height: 14 / 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.22,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Accuracy & Coordinate Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.my_location_rounded,
                      size: 14,
                      color: AppColors.tealDeep,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Akurasi GPS: ~5 meter (Gedung GKB Lt. 1)',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  'GESER PIN',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11,
                    height: 14 / 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.22,
                    color: AppColors.primaryDeep,
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

/// Main white card containing all form input fields.
class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.nameController,
    required this.addressController,
    required this.noteController,
    required this.notifier,
    required this.onPickPhoto,
    required this.onSelectTime,
  });

  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController noteController;
  final PickupPointFormNotifier notifier;
  final VoidCallback onPickPhoto;
  final Future<void> Function({required bool isOpenTime}) onSelectTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.border,
            blurRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Field 1: Nama Titik Pengambilan ────────────────────────────────
          const _FieldLabel(
            label: 'Nama Titik Pengambilan',
            isRequired: true,
          ),
          const SizedBox(height: 6),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r12),
              border: Border.all(
                color: notifier.nameError != null
                    ? AppColors.error
                    : AppColors.border,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: notifier.nameError != null
                      ? AppColors.error
                      : AppColors.border,
                  blurRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    onChanged: notifier.setName,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Kantin Teknik Sisfo (Stan Bu Haris)',
                      hintStyle: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Icon(
                    Icons.store_mall_directory_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (notifier.nameError != null) ...[
            const SizedBox(height: 4),
            Text(
              notifier.nameError!,
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
          const SizedBox(height: 12),

          // ── Field 2: Alamat Lengkap & Verified Badge ───────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _FieldLabel(
                label: 'Alamat Lengkap',
                isRequired: true,
              ),
              // "Terverifikasi Pin" Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.verifiedBadge,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 11,
                      color: AppColors.tealDeep,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Terverifikasi Pin',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11,
                        height: 14 / 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.22,
                        color: AppColors.tealDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r12),
              border: Border.all(
                color: notifier.addressError != null
                    ? AppColors.error
                    : AppColors.border,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: notifier.addressError != null
                      ? AppColors.error
                      : AppColors.border,
                  blurRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: addressController,
              onChanged: notifier.setAddress,
              maxLines: 2,
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText:
                    'Gedung Kuliah Bersama Lt. 1 Sayap Barat, Kampus Utama ITS, Sukolilo',
                hintStyle: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
                contentPadding: const EdgeInsets.all(14),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Otomatis diselaraskan dengan titik koordinat peta.',
            style: GoogleFonts.nunitoSans(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          if (notifier.addressError != null) ...[
            const SizedBox(height: 4),
            Text(
              notifier.addressError!,
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
          const SizedBox(height: 12),

          // ── Field 3: Row Jam Buka & Jam Tutup ──────────────────────────────
          Row(
            children: [
              // Jam Buka
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(label: 'Jam Buka', isRequired: true),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => onSelectTime(isOpenTime: true),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.r12),
                          border: Border.all(
                            color: notifier.timeError != null
                                ? AppColors.error
                                : AppColors.border,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: notifier.timeError != null
                                  ? AppColors.error
                                  : AppColors.border,
                              blurRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              notifier.formatTimeDisplay(notifier.openTime),
                              style: GoogleFonts.nunitoSans(
                                fontSize: 14,
                                height: 19 / 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Jam Tutup
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(label: 'Jam Tutup', isRequired: true),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => onSelectTime(isOpenTime: false),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.r12),
                          border: Border.all(
                            color: notifier.timeError != null
                                ? AppColors.error
                                : AppColors.border,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: notifier.timeError != null
                                  ? AppColors.error
                                  : AppColors.border,
                              blurRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_clock_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              notifier.formatTimeDisplay(notifier.closeTime),
                              style: GoogleFonts.nunitoSans(
                                fontSize: 14,
                                height: 19 / 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (notifier.timeError != null) ...[
            const SizedBox(height: 4),
            Text(
              notifier.timeError!,
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
          const SizedBox(height: 12),

          // ── Field 4: Catatan Pengambilan (Opsional) ────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Catatan Pengambilan',
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Opsional',
                style: GoogleFonts.nunitoSans(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r12),
              border: Border.all(color: AppColors.border, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.border,
                  blurRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: noteController,
              onChanged: notifier.setNote,
              maxLines: 3,
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText:
                    'Contoh: Masuk lewat pintu barat, stan no. 04 samping es teh. Harap bawa wadah makan sendiri.',
                hintStyle: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
                contentPadding: const EdgeInsets.all(14),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Field 5: Foto Lokasi Titik ────────────────────────────────────
          Text(
            'Foto Lokasi Titik',
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          _PhotoUploadZone(
            photoPath: notifier.photoPath,
            onTap: onPickPhoto,
          ),
          const SizedBox(height: 12),

          // ── Field 6: Chunky Switch: Langsung aktifkan titik ini ───────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Langsung aktifkan titik ini',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Dapat segera dipilih saat posting donasi',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Chunky Switch (56x32)
              GestureDetector(
                onTap: notifier.toggleAutoActivate,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 56,
                  height: 32,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: notifier.autoActivate
                        ? AppColors.tealDeep
                        : AppColors.toggleInactive,
                    borderRadius: BorderRadius.circular(9999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 180),
                    alignment: notifier.autoActivate
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.border,
                            blurRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: notifier.autoActivate
                          ? const Center(
                              child: Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: AppColors.tealDeep,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Helper for field labels with red asterisks.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.isRequired = false});

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text(
            '*',
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

/// 194px tall upload box matching Figma CSS (bg #FFF8F0, 56x56 orange camera circle,
/// informative text, and pill button). Shows preview when [photoPath] is non-null.
class _PhotoUploadZone extends StatelessWidget {
  const _PhotoUploadZone({
    required this.photoPath,
    required this.onTap,
  });

  final String? photoPath;
  final VoidCallback onTap;

  Widget _buildPreview(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    }
    if (kIsWeb) {
      return Image.network(path, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    }
    return Image.file(File(path), fit: BoxFit.cover, width: double.infinity, height: double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 194,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.r16),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.border,
              blurRadius: 0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: photoPath != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  _buildPreview(photoPath!),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.border,
                            blurRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_rounded,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Ubah Foto',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 56x56 Camera Circle Button with Shadow
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark,
                            blurRadius: 0,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.photo_camera_rounded,
                          color: AppColors.surface,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ketuk untuk unggah foto lokasi atau stan kantin',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Format JPG/PNG, maks 5 MB. Foto yang jelas mempermudah penyelamatan makanan!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // "Pilih dari Galeri Kampus" pill button
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.photo_library_outlined,
                            size: 13,
                            color: AppColors.tealDeep,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pilih dari Galeri Kampus',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 11,
                              height: 14 / 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.22,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Mascot Rasi Micro-encouragement Box (76px tall, 48x48 icon circle, speech text).
class _MascotEncouragementBox extends StatelessWidget {
  const _MascotEncouragementBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r16),
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
          // 48x48 Mascot Circle
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySoftDeep,
                  blurRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/images/rasi_empty.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.rice_bowl_rounded,
                  size: 24,
                  color: AppColors.primaryDeep,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Rasi bersiap membantu!',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '"Titik pengambilan yang jelas membantu porsi makanan terselamatkan lebih cepat tanpa salah...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
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

/// Action buttons: Primary SIMPAN (56px) and Secondary BATAL (48px).
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onSave,
    required this.onCancel,
  });

  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary Save Button (height 56, edge 4, radius r16)
        ChunkyButton(
          label: 'SIMPAN TITIK PENGAMBILAN',
          onTap: onSave,
          height: 56,
          borderRadius: AppRadius.r16,
          edge: 4,
          letterSpacing: 0.7,
          icon: const Icon(
            Icons.assignment_turned_in_rounded,
            size: 16,
            color: AppColors.surface,
          ),
        ),
        const SizedBox(height: 8),
        // Secondary Cancel Button (height 48, edge 3, radius r16, white fill)
        ChunkyButton(
          label: 'BATAL',
          onTap: onCancel,
          height: 48,
          borderRadius: AppRadius.r16,
          edge: 3,
          fillColor: AppColors.surface,
          shadowColor: AppColors.border,
          textColor: AppColors.textSecondary,
          letterSpacing: 0.7,
        ),
      ],
    );
  }
}
