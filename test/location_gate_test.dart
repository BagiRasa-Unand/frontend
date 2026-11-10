import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:first_project/features/lokasi/data/location_platform.dart';
import 'package:first_project/features/lokasi/data/location_service.dart';
import 'package:first_project/features/lokasi/logic/location_gate_controller.dart';
import 'package:first_project/features/lokasi/presentation/location_gate_view.dart';

class FakeLocationPlatform implements LocationPlatform {
  bool serviceEnabled = true;
  LocationPermission permission = LocationPermission.denied;
  LatLng? currentPosition = const LatLng(-0.9140, 100.4590);
  bool requestPermissionCalled = false;
  bool openLocationSettingsCalled = false;
  bool openAppSettingsCalled = false;

  @override
  Future<bool> isServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async {
    requestPermissionCalled = true;
    return permission;
  }

  @override
  Future<LatLng?> getCurrentLatLng() async => currentPosition;

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

Widget buildTestWidget({
  required LocationService service,
  required LocationGateController controller,
  bool allowManual = false,
  ValueChanged<LocationGateResult>? onResult,
  VoidCallback? onCancel,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: service),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: LocationGateView(
            controller: controller,
            allowManual: allowManual,
            onResult: onResult,
            onCancel: onCancel,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('gateStateFor mapping pure function', () {
    test('maps all LocationStatus values accurately', () {
      expect(
        gateStateFor(LocationStatus.serviceDisabled),
        equals(LocationGateState.gpsOff),
      );
      expect(
        gateStateFor(LocationStatus.deniedForever),
        equals(LocationGateState.permissionDeniedForever),
      );
      expect(
        gateStateFor(LocationStatus.denied),
        equals(LocationGateState.permissionNeeded),
      );
      expect(
        gateStateFor(LocationStatus.granted),
        equals(LocationGateState.permissionNeeded),
      );
    });
  });

  group('LocationGateView UI and variant rendering', () {
    late FakeLocationPlatform fakePlatform;
    late LocationService service;

    setUp(() {
      fakePlatform = FakeLocationPlatform();
      service = LocationService(fakePlatform);
    });

    testWidgets('renders permissionNeeded variant and taps IZINKAN calls requestPermission', (tester) async {
      tester.view.physicalSize = const Size(1170, 2703); // 390x901 @ 3.0x
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakePlatform.serviceEnabled = true;
      fakePlatform.permission = LocationPermission.denied;
      await service.checkStatus();

      final controller = LocationGateController(service: service);

      await tester.pumpWidget(buildTestWidget(
        service: service,
        controller: controller,
      ));
      await tester.pumpAndSettle();

      // Check text in permissionNeeded variant
      expect(find.text('Akses Lokasi Dibutuhkan'), findsOneWidget);
      expect(find.text('Kenapa Butuh Lokasimu?'), findsOneWidget);
      expect(find.text('IZINKAN'), findsOneWidget);
      expect(find.text('Nanti Saja'), findsOneWidget);
      expect(find.text('Kantin Terdekat'), findsOneWidget);
      expect(find.text('Estimasi Waktu Tempuh'), findsOneWidget);
      expect(find.text('Makanan Masih Hangat'), findsOneWidget);

      // Tap primary action button (IZINKAN)
      final buttonFinder = find.text('IZINKAN');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(fakePlatform.requestPermissionCalled, isTrue);
    });

    testWidgets('renders gpsOff variant and taps AKTIFKAN GPS calls openLocationSettings', (tester) async {
      tester.view.physicalSize = const Size(1170, 2703);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakePlatform.serviceEnabled = false;
      await service.checkStatus();

      final controller = LocationGateController(service: service);

      await tester.pumpWidget(buildTestWidget(
        service: service,
        controller: controller,
      ));
      await tester.pumpAndSettle();

      // Check text in gpsOff variant
      expect(find.text('Layanan GPS Nonaktif'), findsOneWidget);
      expect(find.text('GPS Perangkat Mati'), findsOneWidget);
      expect(find.text('AKTIFKAN GPS'), findsOneWidget);

      // Tap primary action button (AKTIFKAN GPS)
      final buttonFinder = find.text('AKTIFKAN GPS');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(fakePlatform.openLocationSettingsCalled, isTrue);
    });

    testWidgets('renders permissionDeniedForever variant and taps BUKA PENGATURAN calls openAppSettings', (tester) async {
      tester.view.physicalSize = const Size(1170, 2703);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakePlatform.serviceEnabled = true;
      fakePlatform.permission = LocationPermission.deniedForever;
      await service.checkStatus();

      final controller = LocationGateController(service: service);

      await tester.pumpWidget(buildTestWidget(
        service: service,
        controller: controller,
      ));
      await tester.pumpAndSettle();

      // Check text in deniedForever variant
      expect(find.text('Izin Lokasi Diblokir'), findsOneWidget);
      expect(find.text('Izin Lokasi Diperlukan'), findsOneWidget);
      expect(find.text('BUKA PENGATURAN'), findsOneWidget);

      // Tap primary action button (BUKA PENGATURAN)
      final buttonFinder = find.text('BUKA PENGATURAN');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(fakePlatform.openAppSettingsCalled, isTrue);
    });

    testWidgets('toggles allowManual visibility', (tester) async {
      tester.view.physicalSize = const Size(1170, 2703);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakePlatform.serviceEnabled = true;
      fakePlatform.permission = LocationPermission.denied;
      await service.checkStatus();

      final controller = LocationGateController(service: service);

      // allowManual = false
      await tester.pumpWidget(buildTestWidget(
        service: service,
        controller: controller,
        allowManual: false,
      ));
      await tester.pumpAndSettle();
      expect(find.text('Pilih lokasi manual'), findsNothing);

      // allowManual = true
      await tester.pumpWidget(buildTestWidget(
        service: service,
        controller: controller,
        allowManual: true,
      ));
      await tester.pumpAndSettle();
      expect(find.text('Pilih lokasi manual'), findsOneWidget);
    });

    testWidgets('taps Nanti Saja triggers onCancel callback', (tester) async {
      tester.view.physicalSize = const Size(1170, 2703);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      fakePlatform.serviceEnabled = true;
      fakePlatform.permission = LocationPermission.denied;
      await service.checkStatus();

      final controller = LocationGateController(service: service);
      bool cancelCalled = false;

      await tester.pumpWidget(buildTestWidget(
        service: service,
        controller: controller,
        onCancel: () {
          cancelCalled = true;
        },
      ));
      await tester.pumpAndSettle();

      final cancelFinder = find.text('Nanti Saja');
      await tester.ensureVisible(cancelFinder);
      await tester.tap(cancelFinder);
      await tester.pumpAndSettle();

      expect(cancelCalled, isTrue);
    });
  });
}
