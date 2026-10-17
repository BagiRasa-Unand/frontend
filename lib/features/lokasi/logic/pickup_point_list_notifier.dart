import 'package:flutter/foundation.dart';
import '../data/pickup_point.dart';
import '../data/pickup_point_repository.dart';

/// ChangeNotifier that the UI listens to for the pickup-point list.
///
/// Delegates all persistence to [PickupPointRepository] and re-exposes
/// computed properties (totals) so widgets don't do business logic.
class PickupPointListNotifier extends ChangeNotifier {
  PickupPointListNotifier(this._repo) {
    _repo.addListener(_onRepoChanged);
  }

  final PickupPointRepository _repo;

  void _onRepoChanged() => notifyListeners();

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }

  // ── Derived state ───────────────────────────────────────────────────────────

  List<PickupPoint> get points => _repo.getAll();

  int get totalPoints => points.length;

  int get totalActiveListings =>
      points.fold(0, (sum, p) => sum + p.activeListingCount);

  // ── Mutations ───────────────────────────────────────────────────────────────

  void delete(String id) => _repo.delete(id);

  void toggleStatus(String id) {
    final point = _repo.getById(id);
    if (point == null) return;
    final next = point.status == PickupPointStatus.aktif
        ? PickupPointStatus.tutup
        : PickupPointStatus.aktif;
    _repo.update(point.copyWith(status: next));
  }
}
