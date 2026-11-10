import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:first_project/features/lokasi/data/location_platform.dart';
import 'package:first_project/features/lokasi/data/route_service.dart';
import 'package:first_project/features/lokasi/logic/route_controller.dart';

class FakeRouteService extends RouteService {
  int fetchCount = 0;
  TravelMode? lastMode;
  RouteResult? nextResult;

  @override
  Future<RouteResult> getRoute(
    LatLng origin,
    LatLng destination,
    TravelMode mode,
  ) async {
    fetchCount++;
    lastMode = mode;
    return nextResult ??
        RouteResult(
          points: [origin, destination],
          distanceMeters: 500.0,
          duration: const Duration(minutes: 6),
          isEstimate: false,
        );
  }
}

class FakeLocationPlatform implements LocationPlatform {
  final StreamController<LatLng> _streamController =
      StreamController<LatLng>.broadcast();

  void emitPosition(LatLng pos) => _streamController.add(pos);

  @override
  Stream<LatLng> positionStream({int distanceFilterMeters = 10}) =>
      _streamController.stream;

  @override
  Future<bool> isServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.always;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.always;

  @override
  Future<LatLng?> getCurrentLatLng() async => null;

  @override
  Future<bool> openLocationSettings() async => true;

  @override
  Future<bool> openAppSettings() async => true;

  void dispose() {
    _streamController.close();
  }
}

void main() {
  group('RouteController tests', () {
    const destination = LatLng(-0.914000, 100.459000);
    const startPos = LatLng(-0.920000, 100.459000);

    late FakeRouteService fakeRouteService;
    late FakeLocationPlatform fakeLocationPlatform;

    setUp(() {
      fakeRouteService = FakeRouteService();
      fakeLocationPlatform = FakeLocationPlatform();
    });

    tearDown(() {
      fakeLocationPlatform.dispose();
    });

    test('initial state and needsLocation state when null location passed', () {
      final controller = RouteController(
        routeService: fakeRouteService,
        locationPlatform: fakeLocationPlatform,
        destination: destination,
        pickupPointName: 'Stan Teknik',
      );

      expect(controller.state, RouteViewState.loading);
      controller.setInitialLocation(null);
      expect(controller.state, RouteViewState.needsLocation);
      expect(controller.currentPosition, isNull);
      expect(fakeRouteService.fetchCount, 0);

      controller.dispose();
    });

    test('mode toggle triggers a fetch with the new travel mode', () async {
      final controller = RouteController(
        routeService: fakeRouteService,
        locationPlatform: fakeLocationPlatform,
        destination: destination,
        pickupPointName: 'Stan Teknik',
      );

      controller.setInitialLocation(startPos);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state, RouteViewState.ready);
      expect(fakeRouteService.fetchCount, 1);
      expect(controller.mode, TravelMode.walking);
      expect(fakeRouteService.lastMode, TravelMode.walking);

      // Toggle to motor
      controller.toggleMode(TravelMode.motor);
      await Future<void>.delayed(Duration.zero);

      expect(controller.mode, TravelMode.motor);
      expect(fakeRouteService.fetchCount, 2);
      expect(fakeRouteService.lastMode, TravelMode.motor);

      // Toggling to same mode does not re-fetch
      controller.toggleMode(TravelMode.motor);
      expect(fakeRouteService.fetchCount, 2);

      controller.dispose();
    });

    test('start and stop following manages subscription and updates coordinates', () async {
      final controller = RouteController(
        routeService: fakeRouteService,
        locationPlatform: fakeLocationPlatform,
        destination: destination,
        pickupPointName: 'Stan Teknik',
      );

      controller.setInitialLocation(startPos);
      await Future<void>.delayed(Duration.zero);

      expect(controller.isFollowing, isFalse);
      controller.startFollowing();
      expect(controller.isFollowing, isTrue);

      // Emit new coordinate along route
      const midPoint = LatLng(-0.916000, 100.459000);
      fakeLocationPlatform.emitPosition(midPoint);
      await Future<void>.delayed(Duration.zero);

      expect(controller.currentPosition, equals(midPoint));
      expect(controller.remainingDistanceMeters, isNotNull);

      // Stop following
      controller.stopFollowing();
      expect(controller.isFollowing, isFalse);

      controller.dispose();
    });

    test('arrival threshold triggers onArrived callback when within 30 meters', () async {
      bool arrivedCalled = false;
      final controller = RouteController(
        routeService: fakeRouteService,
        locationPlatform: fakeLocationPlatform,
        destination: destination,
        pickupPointName: 'Stan Teknik',
        onArrived: () {
          arrivedCalled = true;
        },
      );

      controller.setInitialLocation(startPos);
      await Future<void>.delayed(Duration.zero);

      controller.startFollowing();
      expect(controller.hasArrived, isFalse);
      expect(arrivedCalled, isFalse);

      // Position ~200m away: -0.916000 vs -0.914000
      fakeLocationPlatform.emitPosition(const LatLng(-0.916000, 100.459000));
      await Future<void>.delayed(Duration.zero);
      expect(controller.hasArrived, isFalse);
      expect(arrivedCalled, isFalse);

      // Position ~15m away: ~0.00013 degrees latitude difference is ~14.4m
      fakeLocationPlatform.emitPosition(const LatLng(-0.914130, 100.459000));
      await Future<void>.delayed(Duration.zero);

      expect(controller.hasArrived, isTrue);
      expect(arrivedCalled, isTrue);

      controller.dispose();
    });
  });
}

