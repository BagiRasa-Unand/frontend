import 'package:flutter/material.dart';
import '../data/pickup_point.dart';
import '../data/pickup_point_repository.dart';

/// Notifier that manages form state and validation for creating or editing
/// a [PickupPoint].
class PickupPointFormNotifier extends ChangeNotifier {
  PickupPointFormNotifier({
    this.point,
  }) {
    if (point != null) {
      _name = point!.name;
      _address = point!.address;
      _openTime = point!.openTime;
      _closeTime = point!.closeTime;
      _note = point!.note;
      _photoPath = point!.photoPath;
      _latitude = point!.latitude;
      _longitude = point!.longitude;
      _autoActivate = point!.status == PickupPointStatus.aktif;
    } else {
      _name = '';
      _address = '';
      _openTime = '13:00';
      _closeTime = '16:30';
      _note = '';
      _photoPath = null;
      _latitude = kCampusCenterLat;
      _longitude = kCampusCenterLng;
      _autoActivate = true;
    }
  }

  final PickupPoint? point;

  bool get isEdit => point != null;

  late String _name;
  late String _address;
  late String _openTime;
  late String _closeTime;
  late String _note;
  String? _photoPath;
  double? _latitude;
  double? _longitude;
  late bool _autoActivate;

  String? _nameError;
  String? _addressError;
  String? _pinError;
  String? _timeError;
  bool _hasAttemptedSubmit = false;

  // ── Getters ────────────────────────────────────────────────────────────────

  String get name => _name;
  String get address => _address;
  String get openTime => _openTime;
  String get closeTime => _closeTime;
  String get note => _note;
  String? get photoPath => _photoPath;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get autoActivate => _autoActivate;

  String? get nameError => _nameError;
  String? get addressError => _addressError;
  String? get pinError => _pinError;
  String? get timeError => _timeError;
  bool get hasAttemptedSubmit => _hasAttemptedSubmit;

  /// Formats "HH:mm" to display string "HH.mm WIB"
  String formatTimeDisplay(String time) {
    if (time.isEmpty) return '--.-- WIB';
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}.${parts[1].padLeft(2, '0')} WIB';
    }
    return '$time WIB';
  }

  // ── Setters & Mutations ───────────────────────────────────────────────────

  void setName(String val) {
    _name = val;
    if (_hasAttemptedSubmit) {
      _validateName();
    }
    notifyListeners();
  }

  void setAddress(String val) {
    _address = val;
    if (_hasAttemptedSubmit) {
      _validateAddress();
    }
    notifyListeners();
  }

  void setOpenTime(TimeOfDay time) {
    _openTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    if (_hasAttemptedSubmit) {
      _validateTime();
    }
    notifyListeners();
  }

  void setCloseTime(TimeOfDay time) {
    _closeTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    if (_hasAttemptedSubmit) {
      _validateTime();
    }
    notifyListeners();
  }

  void setNote(String val) {
    _note = val;
    notifyListeners();
  }

  void setPhotoPath(String? path) {
    _photoPath = path;
    notifyListeners();
  }

  void setPin(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
    _pinError = null;
    notifyListeners();
  }

  void toggleAutoActivate() {
    _autoActivate = !_autoActivate;
    notifyListeners();
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  bool _validateName() {
    if (_name.trim().isEmpty) {
      _nameError = 'Nama titik pengambilan wajib diisi';
      return false;
    }
    _nameError = null;
    return true;
  }

  bool _validateAddress() {
    if (_address.trim().isEmpty) {
      _addressError = 'Alamat lengkap wajib diisi';
      return false;
    }
    _addressError = null;
    return true;
  }

  bool _validatePin() {
    if (_latitude == null || _longitude == null) {
      _pinError = 'Silakan tentukan titik lokasi pada peta';
      return false;
    }
    _pinError = null;
    return true;
  }

  int _parseMinutes(String timeStr) {
    final clean = timeStr.replaceAll('WIB', '').trim().replaceAll('.', ':');
    final parts = clean.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      return h * 60 + m;
    }
    return 0;
  }

  bool _validateTime() {
    final openMinutes = _parseMinutes(_openTime);
    final closeMinutes = _parseMinutes(_closeTime);

    if (closeMinutes <= openMinutes) {
      _timeError = 'Jam tutup harus lebih lambat dari jam buka';
      return false;
    }
    _timeError = null;
    return true;
  }

  bool validate() {
    _hasAttemptedSubmit = true;
    final isNameValid = _validateName();
    final isAddressValid = _validateAddress();
    final isPinValid = _validatePin();
    final isTimeValid = _validateTime();

    notifyListeners();
    return isNameValid && isAddressValid && isPinValid && isTimeValid;
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  PickupPoint save(PickupPointRepository repo) {
    final status =
        _autoActivate ? PickupPointStatus.aktif : PickupPointStatus.nonAktif;

    if (isEdit) {
      final updated = point!.copyWith(
        name: _name.trim(),
        address: _address.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
        openTime: _openTime,
        closeTime: _closeTime,
        note: _note.trim(),
        photoPath: _photoPath,
        status: status,
      );
      repo.update(updated);
      return updated;
    } else {
      final newPoint = PickupPoint(
        id: 'pp-${DateTime.now().millisecondsSinceEpoch}',
        name: _name.trim(),
        address: _address.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
        openTime: _openTime,
        closeTime: _closeTime,
        note: _note.trim(),
        photoPath: _photoPath,
        activeListingCount: 0,
        status: status,
      );
      repo.add(newPoint);
      return newPoint;
    }
  }
}
