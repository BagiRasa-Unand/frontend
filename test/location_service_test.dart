import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:first_project/features/lokasi/data/location_platform.dart';
import 'package:first_project/features/lokasi/data/location_service.dart';

class FakeLocationPlatform implements LocationPlatform {
  bool serviceEnabled = true;
  LocationPermission permission = LocationPermission.denied;
  LatLng? currentPosition;
  bool shouldThrowOnGetPosition = false;
  Duration delayOnGetPosition = Duration.zero;
  bool openLocationSettingsCalled = false;
  bool openAppSettingsCalled = false;

  @override
  Future<bool> isServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async => permission;

  @override
  Future<LatLng?> getCurrentLatLng() async {
    if (shouldThrowOnGetPosition) {
      throw Exception('Platform error');
    }
    if (delayOnGetPosition > Duration.zero) {
      await Future.delayed(delayOnGetPosition);
    }
    return currentPosition;
  }

  @override
  Stream<LatLng> positionStream({int distanceFilterMeters = 10}) {
    return Stream.value(currentPosition ?? const LatLng(0, 0));
  }

  @override
  Future<bool> openLocationSettings() async {
    openLocationSettingsCalled = true;
    return true;
  }

  @override
  Future<bool> openAppSettings() async {
    openAppSettingsCalled = true;
    return true;
  }
}

void main() {
  group('LocationService tests', () {
    late FakeLocationPlatform fakePlatform;
    late LocationService service;

    setUp(() {
      fakePlatform = FakeLocationPlatform();
      service = LocationService(fakePlatform);
    });

    test('serviceDisabled beats any permission value (granted, denied, deniedForever)', () async {
      fakePlatform.serviceEnabled = false;

      fakePlatform.permission = LocationPermission.always;
      expect(await service.checkStatus(), LocationStatus.serviceDisabled);

      fakePlatform.permission = LocationPermission.whileInUse;
      expect(await service.checkStatus(), LocationStatus.serviceDisabled);

      fakePlatform.permission = LocationPermission.denied;
      expect(await service.checkStatus(), LocationStatus.serviceDisabled);

      fakePlatform.permission = LocationPermission.deniedForever;
      expect(await service.checkStatus(), LocationStatus.serviceDisabled);

      // requestPermission also returns serviceDisabled when service is off
      fakePlatform.permission = LocationPermission.always;
      expect(await service.requestPermission(), LocationStatus.serviceDisabled);
    });

    test('maps permissions correctly when service is enabled', () async {
      fakePlatform.serviceEnabled = true;

      fakePlatform.permission = LocationPermission.always;
      expect(await service.checkStatus(), LocationStatus.granted);

      fakePlatform.permission = LocationPermission.whileInUse;
      expect(await service.checkStatus(), LocationStatus.granted);

      fakePlatform.permission = LocationPermission.denied;
      expect(await service.checkStatus(), LocationStatus.denied);

      fakePlatform.permission = LocationPermission.deniedForever;
      expect(await service.checkStatus(), LocationStatus.deniedForever);

      fakePlatform.permission = LocationPermission.unableToDetermine;
      expect(await service.checkStatus(), LocationStatus.denied);
    });

    test('getCurrentLatLng returns null when not granted', () async {
      fakePlatform.serviceEnabled = true;
      fakePlatform.permission = LocationPermission.denied;
      fakePlatform.currentPosition = const LatLng(-0.9140, 100.4590);

      await service.checkStatus();
      expect(service.status, LocationStatus.denied);

      final pos = await service.getCurrentLatLng();
      expect(pos, isNull);
      expect(service.lastKnown, isNull);
    });

    test('getCurrentLatLng stores and returns position when granted', () async {
      fakePlatform.serviceEnabled = true;
      fakePlatform.permission = LocationPermission.whileInUse;
      const expectedPoint = LatLng(-0.9140, 100.4590);
      fakePlatform.currentPosition = expectedPoint;

      await service.checkStatus();
      expect(service.status, LocationStatus.granted);

      final pos = await service.getCurrentLatLng();
      expect(pos, equals(expectedPoint));
      expect(service.lastKnown, equals(expectedPoint));
    });

    test('getCurrentLatLng returns null on exception', () async {
      fakePlatform.serviceEnabled = true;
      fakePlatform.permission = LocationPermission.whileInUse;
      fakePlatform.shouldThrowOnGetPosition = true;

      await service.checkStatus();
      final pos = await service.getCurrentLatLng();
      expect(pos, isNull);
    });

    test('getCurrentLatLng returns null on timeout (>10s)', () async {
      fakePlatform.serviceEnabled = true;
      fakePlatform.permission = LocationPermission.whileInUse;
      fakePlatform.delayOnGetPosition = const Duration(seconds: 12);
      fakePlatform.currentPosition = const LatLng(-0.9140, 100.4590);

      await service.checkStatus();
      final pos = await service.getCurrentLatLng();
      expect(pos, isNull);
    });

    test('distanceMeters returns expected metric on a known pair', () {
      const p1 = LatLng(-0.9140, 100.4590);
      const p2 = LatLng(-0.9140, 100.4590);
      expect(LocationService.distanceMeters(p1, p2), closeTo(0.0, 0.01));

      // Two points separated by ~0.001 degree latitude (~111.3 meters)
      const p3 = LatLng(-0.9130, 100.4590);
      final dist = LocationService.distanceMeters(p1, p3);
      expect(dist, closeTo(111.3, 1.0));
    });
  });
}

