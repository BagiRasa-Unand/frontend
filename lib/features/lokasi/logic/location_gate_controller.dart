import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
import '../data/location_service.dart';

/// Presentation gate states corresponding to device location status.
enum LocationGateState {
  permissionNeeded,
  permissionDeniedForever,
  gpsOff,
}

/// Pure function mapping [LocationStatus] to [LocationGateState].
LocationGateState gateStateFor(LocationStatus status) {
  switch (status) {
    case LocationStatus.serviceDisabled:
      return LocationGateState.gpsOff;
    case LocationStatus.deniedForever:
      return LocationGateState.permissionDeniedForever;
    case LocationStatus.denied:
    case LocationStatus.granted:
      return LocationGateState.permissionNeeded;
  }
}

/// Controller managing UI state and action handlers for the Location Gate screen.
///
/// Implements [WidgetsBindingObserver] to observe app lifecycle transitions and
/// automatically re-evaluates location/GPS readiness when returning from device settings.
class LocationGateController extends ChangeNotifier with WidgetsBindingObserver {
  LocationGateController({
    required this.service,
    this.onResolved,
    this.onShowHint,
  }) {
    _gateState = gateStateFor(service.status);
    _selectedSegment = _gateState == LocationGateState.gpsOff ? 1 : 0;
    WidgetsBinding.instance.addObserver(this);
  }

  final LocationService service;
  final void Function(LatLng position)? onResolved;
  final void Function(String message)? onShowHint;

  late LocationGateState _gateState;
  LocationGateState get gateState => _gateState;

  int _selectedSegment = 0;
  int get selectedSegment => _selectedSegment;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void selectSegment(int index) {
    _selectedSegment = index;
    if (index == 0) {
      if (service.status == LocationStatus.deniedForever) {
        _gateState = LocationGateState.permissionDeniedForever;
      } else {
        _gateState = LocationGateState.permissionNeeded;
      }
    } else {
      _gateState = LocationGateState.gpsOff;
    }
    notifyListeners();
  }

  /// Initial or manual evaluation of location status.
  Future<void> checkStatus() async {
    _isLoading = true;
    notifyListeners();

    final status = await service.checkStatus();
    _gateState = gateStateFor(status);
    _selectedSegment = _gateState == LocationGateState.gpsOff ? 1 : 0;

    if (status == LocationStatus.granted) {
      final pos = await service.getCurrentLatLng();
      if (pos != null) {
        onResolved?.call(pos);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Handles the primary action button tap according to current [gateState].
  Future<void> handlePrimaryAction() async {
    switch (_gateState) {
      case LocationGateState.permissionNeeded:
        _isLoading = true;
        notifyListeners();

        final status = await service.requestPermission();
        _gateState = gateStateFor(status);
        _selectedSegment = _gateState == LocationGateState.gpsOff ? 1 : 0;

        if (status == LocationStatus.granted) {
          final pos = await service.getCurrentLatLng();
          if (pos != null) {
            onResolved?.call(pos);
          } else {
            onShowHint?.call('Gagal membaca koordinat GPS, coba sesaat lagi.');
          }
        } else if (status == LocationStatus.denied) {
          onShowHint?.call('Izin lokasi diperlukan untuk melanjutkan.');
        }

        _isLoading = false;
        notifyListeners();
        break;

      case LocationGateState.permissionDeniedForever:
        await service.openAppSettings();
        break;

      case LocationGateState.gpsOff:
        await service.openLocationSettings();
        break;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
