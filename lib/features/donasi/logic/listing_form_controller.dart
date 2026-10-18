import 'package:flutter/foundation.dart';

import '../../../core/app_session.dart';
import '../data/food_listing.dart';
import '../data/food_listing_repository.dart';

class ListingFormController extends ChangeNotifier {
  ListingFormController({this.listing}) {
    if (listing == null) return;
    _name = listing!.name;
    _foodType = listing!.foodType;
    _description = listing!.description;
    _quantityTotal = listing!.quantityTotal;
    _pickupPointId = listing!.pickupPointId;
    _expiresAt = listing!.expiresAt;
    _photoPath = listing!.photoPath;
  }

  final FoodListing? listing;

  String _name = '';
  FoodType? _foodType;
  String _description = '';
  int _quantityTotal = 1;
  String? _pickupPointId;
  DateTime? _expiresAt;
  String? _photoPath;
  bool _hasAttemptedSubmit = false;

  String? _nameError;
  String? _foodTypeError;
  String? _quantityError;
  String? _expiresAtError;
  String? _pickupPointError;

  bool get isEdit => listing != null;
  String get name => _name;
  FoodType? get foodType => _foodType;
  String get description => _description;
  int get quantityTotal => _quantityTotal;
  String? get pickupPointId => _pickupPointId;
  DateTime? get expiresAt => _expiresAt;
  String? get photoPath => _photoPath;
  int get claimedQuantity => listing?.claimedQuantity ?? 0;
  int get minimumQuantity => claimedQuantity > 0 ? claimedQuantity : 1;

  String? get nameError => _nameError;
  String? get foodTypeError => _foodTypeError;
  String? get quantityError => _quantityError;
  String? get expiresAtError => _expiresAtError;
  String? get pickupPointError => _pickupPointError;

  void setName(String value) {
    _name = value;
    if (_hasAttemptedSubmit) _validateName();
    notifyListeners();
  }

  void setFoodType(FoodType value) {
    _foodType = value;
    _foodTypeError = null;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setQuantity(int value) {
    _quantityTotal = value.clamp(minimumQuantity, 999).toInt();
    if (_hasAttemptedSubmit) _validateQuantity();
    notifyListeners();
  }

  void increaseQuantity() => setQuantity(_quantityTotal + 1);

  void decreaseQuantity() => setQuantity(_quantityTotal - 1);

  void setPickupPoint(String? id) {
    _pickupPointId = id;
    _pickupPointError = null;
    notifyListeners();
  }

  void setExpiresAt(DateTime value) {
    _expiresAt = value;
    _expiresAtError = null;
    notifyListeners();
  }

  void setPhotoPath(String? path) {
    _photoPath = path;
    notifyListeners();
  }

  bool validate(DateTime now) {
    _hasAttemptedSubmit = true;
    final nameValid = _validateName();
    final foodTypeValid = _validateFoodType();
    final quantityValid = _validateQuantity();
    final expiresAtValid = _validateExpiresAt(now);
    final pickupPointValid = _validatePickupPoint();
    final valid = nameValid &&
      foodTypeValid &&
      quantityValid &&
      expiresAtValid &&
      pickupPointValid;
    notifyListeners();
    return valid;
  }

  FoodListing save(FoodListingRepository repository) {
    final expiresAt = _expiresAt!;
    final quantityRemaining = _quantityTotal - claimedQuantity;
    final saved = isEdit
        ? listing!.copyWith(
            name: _name.trim(),
            foodType: _foodType!,
            description: _description.trim(),
            quantityTotal: _quantityTotal,
            quantityRemaining: quantityRemaining,
            photoPath: _photoPath,
            pickupPointId: _pickupPointId!,
            expiresAt: expiresAt,
          )
        : FoodListing(
            id: 'food-${DateTime.now().microsecondsSinceEpoch}',
            donorId: kCurrentUserId,
            donorName: 'Budi Santoso',
            name: _name.trim(),
            foodType: _foodType!,
            description: _description.trim(),
            quantityTotal: _quantityTotal,
            quantityRemaining: quantityRemaining,
            photoPath: _photoPath,
            pickupPointId: _pickupPointId!,
            createdAt: DateTime.now(),
            expiresAt: expiresAt,
          );

    if (isEdit) {
      repository.update(saved);
    } else {
      repository.add(saved);
    }
    return saved;
  }

  bool _validateName() {
    _nameError = _name.trim().isEmpty ? 'Nama makanan wajib diisi' : null;
    return _nameError == null;
  }

  bool _validateFoodType() {
    _foodTypeError = _foodType == null ? 'Pilih jenis makanan' : null;
    return _foodTypeError == null;
  }

  bool _validateQuantity() {
    _quantityError = _quantityTotal < minimumQuantity || _quantityTotal > 999
        ? 'Jumlah harus antara $minimumQuantity dan 999'
        : null;
    return _quantityError == null;
  }

  bool _validateExpiresAt(DateTime now) {
    _expiresAtError = _expiresAt == null || !_expiresAt!.isAfter(now)
        ? 'Batas waktu harus setelah sekarang'
        : null;
    return _expiresAtError == null;
  }

  bool _validatePickupPoint() {
    _pickupPointError = _pickupPointId == null
        ? 'Pilih titik pengambilan'
        : null;
    return _pickupPointError == null;
  }
}