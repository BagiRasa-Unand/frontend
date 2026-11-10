import 'package:geolocator/geolocator.dart' as geo;
import 'package:latlong2/latlong.dart';

export 'package:geolocator/geolocator.dart' show LocationPermission;

/// Abstraction layer for location platform operations.
///
/// Wraps native location APIs so that tests can easily inject fakes,
/// and no other file outside this adapter imports the `geolocator` package directly.
abstract class LocationPlatform {
  Future<bool> isServiceEnabled();
  Future<geo.LocationPermission> checkPermission();
  Future<geo.LocationPermission> requestPermission();
  Future<LatLng?> getCurrentLatLng();
  Stream<LatLng> positionStream({int distanceFilterMeters = 10});
  Future<bool> openLocationSettings();
  Future<bool> openAppSettings();
}

/// Default implementation of [LocationPlatform] wrapping [geo.Geolocator].
class GeolocatorLocationPlatform implements LocationPlatform {
  const GeolocatorLocationPlatform();

  @override
  Future<bool> isServiceEnabled() async {
    return geo.Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<geo.LocationPermission> checkPermission() async {
    return geo.Geolocator.checkPermission();
  }

  @override
  Future<geo.LocationPermission> requestPermission() async {
    return geo.Geolocator.requestPermission();
  }

  @override
  Future<LatLng?> getCurrentLatLng() async {
    try {
      final pos = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          timeLimit: Duration(seconds: 10),
        ),
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<LatLng> positionStream({int distanceFilterMeters = 10}) {
    final settings = geo.LocationSettings(
      accuracy: geo.LocationAccuracy.high,
      distanceFilter: distanceFilterMeters,
    );
    return geo.Geolocator.getPositionStream(locationSettings: settings)
        .map((pos) => LatLng(pos.latitude, pos.longitude));
  }

  @override
  Future<bool> openLocationSettings() async {
    return geo.Geolocator.openLocationSettings();
  }

  @override
  Future<bool> openAppSettings() async {
    return geo.Geolocator.openAppSettings();
  }
}
