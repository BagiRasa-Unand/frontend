import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../lokasi/data/pickup_point_repository.dart';
import '../../lokasi/presentation/pickup_point_form_screen.dart';
import '../data/food_listing.dart';
import '../data/food_listing_repository.dart';
import '../logic/listing_form_controller.dart';
import 'widgets/photo_source_sheet.dart';

class ListingFormScreen extends StatelessWidget {
  const ListingFormScreen({super.key, this.listing});

  final FoodListing? listing;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ListingFormController(listing: listing),
      child: const _ListingFormBody(),
    );
  }
}

class _ListingFormBody extends StatefulWidget {
  const _ListingFormBody();

  @override
  State<_ListingFormBody> createState() => _ListingFormBodyState();
}

class _ListingFormBodyState extends State<_ListingFormBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final controller = context.read<ListingFormController>();
    _nameController = TextEditingController(text: controller.name)
      ..addListener(() => controller.setName(_nameController.text));
    _descriptionController = TextEditingController(text: controller.description)
      ..addListener(() => controller.setDescription(_descriptionController.text));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        context.read<ListingFormController>().setPhotoPath(picked.path);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa mengakses kamera')),
      );
    }
  }

  Future<void> _showPhotoSourceSheet() async {
    final source = await showPhotoSourceSheet(context);
    if (source != null && mounted) {
      await _pickPhoto(source);
    }
  }

  Future<void> _pickDeadline() async {
    final controller = context.read<ListingFormController>();
    final current = controller.expiresAt ?? DateTime.now().add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: current.isBefore(DateTime.now()) ? DateTime.now() : current,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => _pickerTheme(context, child),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      builder: (context, child) => _pickerTheme(context, child),
    );
    if (time == null || !mounted) return;

    controller.setExpiresAt(DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ));
  }

  Theme _pickerTheme(BuildContext context, Widget? child) {
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
  }

  void _save() {
    final controller = context.read<ListingFormController>();
    if (!controller.validate(DateTime.now())) return;

    final repository = context.read<FoodListingRepository>();
    final messenger = ScaffoldMessenger.of(context);
    controller.save(repository);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Listing disimpan')),
    );
  }

  Future<void> _openPickupPointForm() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PickupPointFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ListingFormController>();
    final pickupPoints = context.watch<PickupPointRepository>().getAll();
    final isEdit = controller.isEdit;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _FormHeader(
              title: isEdit ? 'Ubah Listing' : 'Buat Listing',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ModeSwitcher(),
                    const SizedBox(height: 8),
                    _FormMeta(isEdit: isEdit),
                    const SizedBox(height: 16),
                    _PhotoField(
                      photoPath: controller.photoPath,
                      onTap: _showPhotoSourceSheet,
                    ),
                    const SizedBox(height: 18),
                    _FieldLabel(label: 'Nama Makanan', required: true),
                    const SizedBox(height: 4),
                    _TextField(
                      controller: _nameController,
                      hintText: 'Contoh: Nasi Kotak Ayam Penyet',
                      errorText: controller.nameError,
                    ),
                    const SizedBox(height: 18),
                    _FieldLabel(label: 'Jenis Makanan', required: true,
                        trailing: 'Pilih satu kategori'),
                    const SizedBox(height: 8),
                    _FoodTypeGrid(controller: controller),
                    if (controller.foodTypeError != null)
                      _ErrorText(controller.foodTypeError!),
                    const SizedBox(height: 18),
                    _QuantityField(controller: controller),
                    const SizedBox(height: 18),
                    _FieldLabel(label: 'Batas Waktu Pengambilan', required: true),
                    const SizedBox(height: 4),
                    _DeadlineField(
                      value: controller.expiresAt,
                      errorText: controller.expiresAtError,
                      onTap: _pickDeadline,
                    ),
                    const SizedBox(height: 18),
                    _PickupPointField(
                      controller: controller,
                      pickupPoints: pickupPoints,
                      onAdd: _openPickupPointForm,
                    ),
                    const SizedBox(height: 18),
                    _FieldLabel(label: 'Catatan Tambahan', trailing: '(Opsional)'),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _descriptionController,
                      minLines: 3,
                      maxLines: 4,
                      style: AppTextStyles.body,
                      decoration: _inputDecoration(
                        hintText: 'Contoh: Harap bawa wadah/Tupperware sendiri.\nAmbil langsung di meja stan kasir.',
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _TipCard(),
                    const SizedBox(height: 18),
                    ChunkyButton(
                      label: isEdit ? 'SIMPAN PERUBAHAN' : 'SIMPAN & BAGIKAN DONASI',
                      onTap: _save,
                      icon: const Icon(Icons.volunteer_activism_outlined,
                          size: 18, color: AppColors.surface),
                      height: 56,
                      borderRadius: AppRadius.r16,
                    ),
                    const SizedBox(height: 10),
                    ChunkyButton(
                      label: 'BATALKAN',
                      onTap: () => Navigator.of(context).pop(),
                      variant: ChunkyButtonVariant.neutral,
                      shadowColor: AppColors.border,
                      textColor: AppColors.textPrimary,
                      icon: const Icon(Icons.close_rounded,
                          size: 15, color: AppColors.textSecondary),
                      height: 48,
                      borderRadius: AppRadius.r16,
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

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.96),
        boxShadow: const [
          BoxShadow(color: AppColors.border, blurRadius: 8, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded)),
          const SizedBox(width: 4),
          Expanded(child: Text(title, style: AppTextStyles.heading)),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryDeep,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline_rounded,
                size: 17, color: AppColors.surface),
          ),
        ],
      ),
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.pillNeutral,
        borderRadius: BorderRadius.circular(AppRadius.r9999),
      ),
      child: Row(
        children: [
          _ModePill(label: 'Buat Baru', icon: Icons.add_circle_outline,
              selected: true),
          _ModePill(label: 'Ubah Data', icon: Icons.edit_note_outlined),
          _ModePill(label: 'Error Mode', icon: Icons.error_outline_rounded),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({required this.label, required this.icon, this.selected = false});

  final String label;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 28,
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.r9999),
          boxShadow: selected
              ? const [BoxShadow(color: AppColors.border, blurRadius: 2)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14,
                color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 4),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis,
                style: AppTextStyles.badge.copyWith(
                    color: selected ? AppColors.textPrimary : AppColors.textSecondary))),
          ],
        ),
      ),
    );
  }
}

class _FormMeta extends StatelessWidget {
  const _FormMeta({required this.isEdit});

  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.tealDeep,
            borderRadius: BorderRadius.circular(AppRadius.r9999),
            boxShadow: const [
              BoxShadow(color: AppColors.tealDark, blurRadius: 0, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.volunteer_activism_outlined,
                  size: 14, color: AppColors.surface),
              const SizedBox(width: 4),
              Text('DONASI MAKANAN', style: AppTextStyles.badge.copyWith(
                  color: AppColors.surface, letterSpacing: 0.55)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.r9999),
          ),
          child: Text(isEdit ? 'Mode Edit' : 'Mode Baru',
              style: AppTextStyles.badge.copyWith(color: AppColors.primaryDark)),
        ),
        const Spacer(),
        const Icon(Icons.verified_outlined, size: 14, color: AppColors.tealDeep),
        const SizedBox(width: 3),
        Text('Akun Mitra\nTerverifikasi', style: AppTextStyles.badge.copyWith(
            color: AppColors.textSecondary)),
      ],
    );
  }
}

class _PhotoField extends StatelessWidget {
  const _PhotoField({required this.photoPath, required this.onTap});

  final String? photoPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _FieldLabel(label: 'Foto Makanan', required: true),
            Text('Foto riil & mengunggah selera', style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: CustomPaint(
            painter: _DashedBorderPainter(),
            child: Container(
              height: 176,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r16),
                boxShadow: const [
                  BoxShadow(color: AppColors.border, blurRadius: 0, offset: Offset(0, 3)),
                ],
              ),
              child: photoPath == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_outlined,
                              size: 24, color: AppColors.primary),
                        ),
                        const SizedBox(height: 8),
                        Text('Ambil foto makanan', style: AppTextStyles.heading),
                        const SizedBox(height: 2),
                        Text('Atau pilih dari galeri ponselmu (Maks. 5 MB)',
                            style: AppTextStyles.caption),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWarm,
                            borderRadius: BorderRadius.circular(AppRadius.r9999),
                          ),
                          child: Text('Membantu menarik minat penyelamat pangan',
                              style: AppTextStyles.badge.copyWith(color: AppColors.brownMid)),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.r12),
                      child: _photoPreview(photoPath!),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _photoPreview(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover, width: double.infinity,
          height: double.infinity);
    }
    return Image.file(File(path), fit: BoxFit.cover, width: double.infinity,
        height: double.infinity);
  }
}

class _FoodTypeGrid extends StatelessWidget {
  const _FoodTypeGrid({required this.controller});

  final ListingFormController controller;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 12,
      childAspectRatio: 167 / 60,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: FoodType.values.map((type) {
        final selected = controller.foodType == type;
        return GestureDetector(
          onTap: () => controller.setFoodType(type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.primarySoft : AppColors.surface,
              border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: 2),
              borderRadius: BorderRadius.circular(AppRadius.r16),
              boxShadow: [
                BoxShadow(
                  color: selected ? AppColors.primary : AppColors.border,
                  blurRadius: 0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(_foodTypeIcon(type), size: 18,
                    color: selected ? AppColors.primary : AppColors.tealDeep),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_foodTypeLabel(type), style: AppTextStyles.badge.copyWith(
                          color: selected ? AppColors.primaryDark : AppColors.textPrimary)),
                      Text(_foodTypeHint(type), maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _foodTypeIcon(FoodType type) => switch (type) {
        FoodType.makananBerat => Icons.lunch_dining_outlined,
        FoodType.camilan => Icons.bakery_dining_outlined,
        FoodType.minuman => Icons.local_cafe_outlined,
        FoodType.lainnya => Icons.category_outlined,
      };

  String _foodTypeLabel(FoodType type) => switch (type) {
        FoodType.makananBerat => 'Makanan Berat',
        FoodType.camilan => 'Camilan / Roti',
        FoodType.minuman => 'Minuman',
        FoodType.lainnya => 'Lainnya',
      };

  String _foodTypeHint(FoodType type) => switch (type) {
        FoodType.makananBerat => 'Nasi, lauk, mie',
        FoodType.camilan => 'Kue, gorengan',
        FoodType.minuman => 'Jus, teh, kopi',
        FoodType.lainnya => 'Bahan segar, buah',
      };
}

class _QuantityField extends StatelessWidget {
  const _QuantityField({required this.controller});

  final ListingFormController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: controller.quantityError == null
            ? AppColors.border : AppColors.error, width: 2),
        borderRadius: BorderRadius.circular(AppRadius.r16),
        boxShadow: const [
          BoxShadow(color: AppColors.border, blurRadius: 0, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(label: 'Jumlah Porsi', required: true),
                  Text('Tersedia untuk dibagikan', style: AppTextStyles.caption),
                ],
              ),
              Row(
                children: [
                  _StepperButton(icon: Icons.remove, onTap: controller.decreaseQuantity,
                      enabled: controller.quantityTotal > controller.minimumQuantity),
                  SizedBox(
                    width: 56,
                    child: Column(
                      children: [
                        Text('${controller.quantityTotal}', style: AppTextStyles.modalTitle.copyWith(
                            color: AppColors.primaryDark)),
                        Text('porsi', style: AppTextStyles.badge.copyWith(
                            color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  _StepperButton(icon: Icons.add, onTap: controller.increaseQuantity,
                      enabled: controller.quantityTotal < 999, primary: true),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.favorite_border_rounded,
                  size: 17, color: AppColors.tealDeep),
              const SizedBox(width: 6),
              Expanded(child: Text(
                controller.isEdit && controller.claimedQuantity > 0
                    ? '${controller.claimedQuantity} porsi sudah diklaim'
                    : 'Setiap porsi sangat berharga untuk teman kampusmu.',
                style: AppTextStyles.caption.copyWith(color: AppColors.tealDeep),
              )),
            ],
          ),
          if (controller.quantityError != null)
            _ErrorText(controller.quantityError!),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap,
      required this.enabled, this.primary = false});

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: primary ? AppColors.primary : AppColors.surfaceWarm,
          borderRadius: BorderRadius.circular(AppRadius.r12),
          boxShadow: [
            BoxShadow(
              color: primary ? AppColors.primaryDark : AppColors.border,
              blurRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: primary ? AppColors.surface : AppColors.textPrimary),
      ),
    );
  }
}

class _DeadlineField extends StatelessWidget {
  const _DeadlineField({required this.value, required this.errorText, required this.onTap});

  final DateTime? value;
  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: errorText == null ? AppColors.border : AppColors.error,
                  width: 2),
              borderRadius: BorderRadius.circular(AppRadius.r16),
              boxShadow: const [
                BoxShadow(color: AppColors.border, blurRadius: 0, offset: Offset(0, 3)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_outlined, color: AppColors.tealDeep),
                const SizedBox(width: 12),
                Expanded(child: Text(_format(value), style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700))),
                const Icon(Icons.calendar_month_outlined,
                    color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
        if (errorText != null) _ErrorText(errorText!),
      ],
    );
  }

  String _format(DateTime? value) {
    if (value == null) return 'Pilih batas waktu pengambilan';
    final date = '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
    final time = '${value.hour.toString().padLeft(2, '0')}.${value.minute.toString().padLeft(2, '0')} WIB';
    return '$date, $time';
  }
}

class _PickupPointField extends StatelessWidget {
  const _PickupPointField({required this.controller, required this.pickupPoints, required this.onAdd});

  final ListingFormController controller;
  final List<dynamic> pickupPoints;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _FieldLabel(label: 'Titik Pengambilan', required: true),
            GestureDetector(
              onTap: onAdd,
              child: Row(
                children: [
                  const Icon(Icons.add_location_alt_outlined,
                      size: 15, color: AppColors.tealDeep),
                  const SizedBox(width: 2),
                  Text('+ Tambah titik baru', style: AppTextStyles.badge.copyWith(
                      color: AppColors.tealDeep)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (pickupPoints.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius: BorderRadius.circular(AppRadius.r16),
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: Text('Belum ada titik pengambilan. Tambahkan titik baru.',
                style: AppTextStyles.caption),
          )
        else
          DropdownButtonFormField<String>(
            initialValue: controller.pickupPointId,
            isExpanded: true,
            decoration: _inputDecoration(
              prefixIcon: Icons.location_on_outlined,
              errorText: controller.pickupPointError,
            ),
            hint: Text('Pilih titik pengambilan', style: AppTextStyles.body),
            items: pickupPoints.map<DropdownMenuItem<String>>((point) {
              return DropdownMenuItem<String>(
                value: point.id as String,
                child: Text(point.name as String, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: controller.setPickupPoint,
          ),
        if (pickupPoints.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('Lokasi yang mudah diakses mahasiswa saat pergantian jam kuliah.',
                style: AppTextStyles.caption),
          ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(AppRadius.r16),
        boxShadow: const [
          BoxShadow(color: AppColors.border, blurRadius: 0, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.reward.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadius.r16),
            ),
            child: Image.asset('assets/images/rasi_worried.png'),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pesan Sahabat Rasi', style: AppTextStyles.body),
                Text('"Pastikan makanan masih higienis dan layak konsumsi ya! Kamu baru saja menyelamatkan bumi hari ini."',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.required = false, this.trailing});

  final String label;
  final bool required;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(TextSpan(
          text: label,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          children: required
              ? [const TextSpan(text: ' *', style: TextStyle(color: AppColors.error))]
              : null,
        )),
        if (trailing != null) Text(trailing!, style: AppTextStyles.caption),
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({required this.controller, required this.hintText, this.errorText});

  final TextEditingController controller;
  final String hintText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: AppTextStyles.body,
      decoration: _inputDecoration(hintText: hintText, errorText: errorText),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4),
      child: Text(message, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
    );
  }
}

InputDecoration _inputDecoration({
  String? hintText,
  String? errorText,
  IconData? prefixIcon,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.r16),
    borderSide: BorderSide(
      color: errorText == null ? AppColors.border : AppColors.error,
      width: 2,
    ),
  );
  return InputDecoration(
    hintText: hintText,
    hintStyle: AppTextStyles.body.copyWith(color: AppColors.slate),
    prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, color: AppColors.primary),
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    errorText: errorText,
    errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
  );
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path();
    const dash = 7.0;
    const gap = 5.0;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(AppRadius.r16),
    );
    final outline = Path()..addRRect(rect);
    final metrics = outline.computeMetrics();
    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        path.addPath(metric.extractPath(distance,
            (distance + dash).clamp(0, metric.length)), Offset.zero);
        distance += dash + gap;
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
