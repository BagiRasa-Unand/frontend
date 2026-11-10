import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'location_platform.dart';

/// Status of location service and permissions on the device.
enum LocationStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

/// Central application service managing GPS service state, permissions,
/// and current coordinates.
///
/// Wraps a [LocationPlatform] adapter for testability and clean architecture.
class LocationService extends ChangeNotifier {
  LocationService([LocationPlatform? platform])
      : _platform = platform ?? const GeolocatorLocationPlatform();

  final LocationPlatform _platform;

  LocationStatus _status = LocationStatus.denied;
  LocationStatus get status => _status;

  LatLng? _lastKnown;
  LatLng? get lastKnown => _lastKnown;

  /// Checks the current location status.
  ///
  /// Service disabled on device wins over any permission status.
  /// If the service is enabled, maps the permission to [LocationStatus].
  Future<LocationStatus> checkStatus() async {
    try {
      final serviceEnabled = await _platform.isServiceEnabled();
      if (!serviceEnabled) {
        _status = LocationStatus.serviceDisabled;
        notifyListeners();
        return _status;
      }

      final permission = await _platform.checkPermission();
      _status = _mapPermission(permission);
      notifyListeners();
      return _status;
    } catch (_) {
      _status = LocationStatus.denied;
      notifyListeners();
      return _status;
    }
  }

  /// Prompts the user to grant location permissions.
  ///
  /// If the location service itself is disabled, immediately returns [LocationStatus.serviceDisabled].
  Future<LocationStatus> requestPermission() async {
    try {
      final serviceEnabled = await _platform.isServiceEnabled();
      if (!serviceEnabled) {
        _status = LocationStatus.serviceDisabled;
        notifyListeners();
        return _status;
      }

      final permission = await _platform.requestPermission();
      _status = _mapPermission(permission);
      notifyListeners();
      return _status;
    } catch (_) {
      _status = LocationStatus.denied;
      notifyListeners();
      return _status;
    }
  }

  /// Retrieves the current [LatLng] position.
  ///
  /// Returns null if status is not [LocationStatus.granted],
  /// or if a timeout (10 seconds) or platform exception occurs.
  /// Successfully fetched positions are cached in [lastKnown].
  Future<LatLng?> getCurrentLatLng() async {
    if (_status != LocationStatus.granted) {
      return null;
    }

    try {
      final position = await _platform
          .getCurrentLatLng()
          .timeout(const Duration(seconds: 10));

      if (position != null) {
        _lastKnown = position;
        notifyListeners();
      }
      return position;
    } catch (_) {
      return null;
    }
  }

  /// Opens the device's location settings page.
  Future<bool> openLocationSettings() async {
    return _platform.openLocationSettings();
  }

  /// Opens the application details settings page.
  Future<bool> openAppSettings() async {
    return _platform.openAppSettings();
  }

  /// Pure geodesic distance calculation in meters between two coordinates.
  ///
  /// Uses latlong2 Distance with zero platform or GPS dependency.
  static double distanceMeters(LatLng a, LatLng b) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, a, b);
  }

  LocationStatus _mapPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationStatus.granted;
      case LocationPermission.deniedForever:
        return LocationStatus.deniedForever;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationStatus.denied;
    }
  }
}

