import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';
import 'package:first_project/features/lokasi/data/location_service.dart';
import 'package:first_project/features/lokasi/data/route_service.dart';

void main() {
  group('RouteService tests', () {
    const origin = LatLng(-0.9140, 100.4590);
    const destination = LatLng(-0.9130, 100.4600);

    const validOsmResponse = '''
{
  "code": "Ok",
  "routes": [
    {
      "geometry": {
        "coordinates": [
          [100.4590, -0.9140],
          [100.4600, -0.9130]
        ],
        "type": "LineString"
      },
      "distance": 250.0,
      "duration": 178.5
    }
  ]
}
''';

    test('successful parse correctly swaps lng/lat to LatLng', () async {
      final client = MockClient((request) async {
        // verify User-Agent header
        expect(request.headers['User-Agent'], 'BagiRasa/1.0 (student project)');
        return http.Response(validOsmResponse, 200);
      });

      final service = RouteService(client: client);
      final result = await service.getRoute(origin, destination, TravelMode.walking);

      expect(result.isEstimate, isFalse);
      expect(result.distanceMeters, 250.0);
      expect(result.duration, const Duration(seconds: 179));
      expect(result.points.length, 2);

      // Verify GeoJSON [lng, lat] swapped to LatLng(latitude, longitude)
      expect(result.points[0].latitude, -0.9140);
      expect(result.points[0].longitude, 100.4590);
      expect(result.points[1].latitude, -0.9130);
      expect(result.points[1].longitude, 100.4600);
    });

    test('non-200 status code returns fallback estimate', () async {
      final client = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final service = RouteService(client: client);
      final result = await service.getRoute(origin, destination, TravelMode.walking);

      expect(result.isEstimate, isTrue);
      expect(result.points, equals([origin, destination]));
      final expectedDist = LocationService.distanceMeters(origin, destination);
      expect(result.distanceMeters, closeTo(expectedDist, 0.01));
      expect(result.duration.inSeconds, equals((expectedDist / 1.4).round()));
    });

    test('request timeout returns fallback estimate', () async {
      final client = MockClient((request) async {
        throw TimeoutException('Request timed out');
      });

      final service = RouteService(client: client);
      final result = await service.getRoute(origin, destination, TravelMode.walking);

      expect(result.isEstimate, isTrue);
      expect(result.points, equals([origin, destination]));
    });

    test('code NoRoute returns fallback estimate', () async {
      final client = MockClient((request) async {
        return http.Response('{"code":"NoRoute","routes":[]}', 200);
      });

      final service = RouteService(client: client);
      final result = await service.getRoute(origin, destination, TravelMode.walking);

      expect(result.isEstimate, isTrue);
      expect(result.points, equals([origin, destination]));
    });

    test('malformed JSON returns fallback estimate', () async {
      final client = MockClient((request) async {
        return http.Response('{not valid json', 200);
      });

      final service = RouteService(client: client);
      final result = await service.getRoute(origin, destination, TravelMode.walking);

      expect(result.isEstimate, isTrue);
      expect(result.points, equals([origin, destination]));
    });

    test('fallback numbers use correct speeds for walking vs motor', () async {
      final client = MockClient((request) async {
        return http.Response('error', 400);
      });

      final service = RouteService(client: client);

      final walkingResult = await service.getRoute(origin, destination, TravelMode.walking);
      final straightLineDist = LocationService.distanceMeters(origin, destination);
      expect(walkingResult.distanceMeters, closeTo(straightLineDist, 0.01));
      expect(walkingResult.duration.inSeconds, equals((straightLineDist / 1.4).round()));

      // Different point to not hit cache/rate limit
      const origin2 = LatLng(-0.9200, 100.4500);
      const dest2 = LatLng(-0.9100, 100.4600);
      // Wait or provide mock clock
      DateTime fakeTime = DateTime(2026, 1, 1, 12, 0, 0);
      final serviceWithClock = RouteService(
        client: client,
        clock: () => fakeTime,
      );

      final motorResult = await serviceWithClock.getRoute(origin2, dest2, TravelMode.motor);
      final straightLineDist2 = LocationService.distanceMeters(origin2, dest2);
      expect(motorResult.distanceMeters, closeTo(straightLineDist2, 0.01));
      expect(motorResult.duration.inSeconds, equals((straightLineDist2 / 8.3).round()));
    });

    test('cache: identical second call does not hit network client', () async {
      int requestCount = 0;
      final client = MockClient((request) async {
        requestCount++;
        return http.Response(validOsmResponse, 200);
      });

      final service = RouteService(client: client);
      final res1 = await service.getRoute(origin, destination, TravelMode.walking);
      expect(requestCount, 1);
      expect(res1.isEstimate, isFalse);

      final res2 = await service.getRoute(origin, destination, TravelMode.walking);
      expect(requestCount, 1); // Not incremented, served from cache
      expect(res2.distanceMeters, res1.distanceMeters);
      expect(res2.duration, res1.duration);
    });

    test('rate limit: calls within 1 second return fallback without hitting client', () async {
      int requestCount = 0;
      DateTime fakeTime = DateTime(2026, 1, 1, 12, 0, 0);

      final client = MockClient((request) async {
        requestCount++;
        return http.Response(validOsmResponse, 200);
      });

      final service = RouteService(
        client: client,
        clock: () => fakeTime,
      );

      // First call hits client
      const pair1Dest = LatLng(-0.9150, 100.4580);
      final r1 = await service.getRoute(origin, pair1Dest, TravelMode.walking);
      expect(requestCount, 1);
      expect(r1.isEstimate, isFalse);

      // Advance clock by only 500ms (< 1 second) and use different coordinates (not cached)
      fakeTime = fakeTime.add(const Duration(milliseconds: 500));
      const pair2Dest = LatLng(-0.9160, 100.4570);
      final r2 = await service.getRoute(origin, pair2Dest, TravelMode.walking);
      expect(requestCount, 1); // Client was NOT called
      expect(r2.isEstimate, isTrue); // Fallback estimate returned

      // Advance clock by another 600ms (total 1100ms > 1 second from last request)
      fakeTime = fakeTime.add(const Duration(milliseconds: 600));
      const pair3Dest = LatLng(-0.9170, 100.4560);
      final r3 = await service.getRoute(origin, pair3Dest, TravelMode.walking);
      expect(requestCount, 2); // Client was called now!
      expect(r3.isEstimate, isFalse);
    });
  });
}
