import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/map_listing.dart';
import '../data/pickup_point.dart';
import '../data/pickup_point_repository.dart';

/// Filter chip pilihan pada layar Peta Utama.
enum MapFilterType {
  semua,
  terdekat,
  segeraHabis,
  makananBerat,
  snack,
}

/// Controller & State Notifier untuk layar Peta Utama (Module C).
class MapNotifier extends ChangeNotifier {
  MapNotifier(this._pickupRepo) {
    _allListings = seedMapListings();
  }

  final PickupPointRepository _pickupRepo;
  late final List<MapListing> _allListings;

  final MapController mapController = MapController();
  final ScrollController sheetScrollController = ScrollController();

  MapFilterType _activeFilter = MapFilterType.semua;
  MapFilterType get activeFilter => _activeFilter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _selectedListingId;
  String? get selectedListingId => _selectedListingId;

  /// Daftar listing terfilter berdasarkan pencarian dan filter chip.
  List<MapListing> get filteredListings {
    List<MapListing> list = List.of(_allListings);

    // 1. Filter pencarian teks
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((item) {
        return item.name.toLowerCase().contains(q) ||
            item.pickupPointName.toLowerCase().contains(q);
      }).toList();
    }

    // 2. Filter chip
    switch (_activeFilter) {
      case MapFilterType.semua:
        break;
      case MapFilterType.terdekat:
        // Urutkan berdasarkan distanceMeters dummy
        list.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
        break;
      case MapFilterType.segeraHabis:
        list = list
            .where((item) => item.status == MapListingStatus.segeraHabis)
            .toList();
        break;
      case MapFilterType.makananBerat:
        list = list.where((item) => item.categoryKey == 'makanan_berat').toList();
        break;
      case MapFilterType.snack:
        list = list.where((item) => item.categoryKey == 'snack').toList();
        break;
    }

    return list;
  }

  /// Pickup point yang terkait dengan filtered listings.
  List<PickupPoint> get activePickupPoints {
    final activeListingPointIds =
        filteredListings.map((l) => l.pickupPointId).toSet();
    return _pickupRepo
        .getAll()
        .where((p) => activeListingPointIds.contains(p.id))
        .toList();
  }

  /// Status listing untuk sebuah pickup point (apakah segera habis atau tersedia biasa).
  MapListingStatus? statusForPickupPoint(String pickupPointId) {
    final listingsForPoint =
        filteredListings.where((l) => l.pickupPointId == pickupPointId).toList();
    if (listingsForPoint.isEmpty) return null;
    if (listingsForPoint.any((l) => l.status == MapListingStatus.segeraHabis)) {
      return MapListingStatus.segeraHabis;
    }
    return MapListingStatus.tersedia;
  }

  /// Jumlah porsi untuk pin badge pickup point.
  int portionCountForPickupPoint(String pickupPointId) {
    final point = _pickupRepo.getById(pickupPointId);
    if (point != null && point.activeListingCount > 0) {
      return point.activeListingCount;
    }
    final listings =
        _allListings.where((l) => l.pickupPointId == pickupPointId).toList();
    return listings.fold(0, (acc, item) => acc + item.portionCount);
  }

  void setFilter(MapFilterType filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectListing(String id) {
    _selectedListingId = id;
    notifyListeners();

    // Temukan listing dan arahkan peta
    final listing = _allListings.firstWhere((l) => l.id == id);
    final point = _pickupRepo.getById(listing.pickupPointId);
    if (point != null) {
      mapController.move(
        LatLng(point.latitude, point.longitude),
        mapController.camera.zoom,
      );
    }
  }

  void selectPickupPoint(String pointId) {
    final listing = filteredListings
        .where((l) => l.pickupPointId == pointId)
        .firstOrNull;
    if (listing != null) {
      _selectedListingId = listing.id;
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedListingId = null;
    notifyListeners();
  }

  void centerOnCampus() {
    mapController.move(kCampusCenter, 16.5);
  }
}
