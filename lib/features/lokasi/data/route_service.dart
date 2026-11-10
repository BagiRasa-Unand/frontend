import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'location_service.dart';

/// Modes of transport available for routing.
enum TravelMode {
  walking,
  motor,
}

/// Result of a routing request or fallback straight-line calculation.
class RouteResult {
  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.duration,
    required this.isEstimate,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final Duration duration;
  final bool isEstimate;
}

/// Service that handles OSRM route requests, rate-limiting, and caching.
class RouteService {
  RouteService({
    http.Client? client,
    DateTime Function()? clock,
  })  : _client = client ?? http.Client(),
        _clock = clock ?? DateTime.now;

  final http.Client _client;
  final DateTime Function() _clock;

  DateTime? _lastRequestTime;
  final Map<String, RouteResult> _cache = {};

  /// Retrieves the route between [origin] and [destination] for the selected [mode].
  ///
  /// Respects a 1-request-per-second rate limit. If network request is blocked,
  /// fails, or times out, falls back to a straight-line estimate.
  Future<RouteResult> getRoute(
    LatLng origin,
    LatLng destination,
    TravelMode mode,
  ) async {
    final key = _cacheKey(origin, destination, mode);
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    // Rate-limiting: at most 1 network request per second
    if (_lastRequestTime != null) {
      final elapsed = _clock().difference(_lastRequestTime!);
      if (elapsed < const Duration(seconds: 1)) {
        return _fallbackEstimate(origin, destination, mode);
      }
    }

    // Note: motor uses the public OSRM car profile endpoint
    final profile = mode == TravelMode.walking ? 'routed-foot' : 'routed-car';
    final url = Uri.parse(
      'https://routing.openstreetmap.de/$profile/route/v1/driving/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson',
    );

    _lastRequestTime = _clock();

    try {
      final response = await _client.get(
        url,
        headers: {
          'User-Agent': 'BagiRasa/1.0 (student project)',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        return _fallbackEstimate(origin, destination, mode);
      }

      final dynamic data = jsonDecode(response.body);
      if (data is! Map<String, dynamic> || data['code'] != 'Ok') {
        return _fallbackEstimate(origin, destination, mode);
      }

      final routes = data['routes'];
      if (routes is! List || routes.isEmpty) {
        return _fallbackEstimate(origin, destination, mode);
      }

      final route = routes[0];
      if (route is! Map<String, dynamic>) {
        return _fallbackEstimate(origin, destination, mode);
      }

      final distance = (route['distance'] as num).toDouble();
      final durationSec = (route['duration'] as num).toDouble();
      final geometry = route['geometry'];
      if (geometry is! Map<String, dynamic>) {
        return _fallbackEstimate(origin, destination, mode);
      }

      final coordinates = geometry['coordinates'];
      if (coordinates is! List || coordinates.isEmpty) {
        return _fallbackEstimate(origin, destination, mode);
      }

      final points = <LatLng>[];
      for (final coord in coordinates) {
        if (coord is List && coord.length >= 2) {
          // GeoJSON coordinates are [longitude, latitude]
          final lng = (coord[0] as num).toDouble();
          final lat = (coord[1] as num).toDouble();
          points.add(LatLng(lat, lng));
        }
      }

      if (points.isEmpty) {
        return _fallbackEstimate(origin, destination, mode);
      }

      final result = RouteResult(
        points: points,
        distanceMeters: distance,
        duration: Duration(seconds: durationSec.round()),
        isEstimate: false,
      );

      _cache[key] = result;
      return result;
    } catch (_) {
      return _fallbackEstimate(origin, destination, mode);
    }
  }

  RouteResult _fallbackEstimate(
    LatLng origin,
    LatLng destination,
    TravelMode mode,
  ) {
    final distance = LocationService.distanceMeters(origin, destination);
    // Speed: walking ~1.4 m/s (5 km/h), motor ~8.3 m/s (30 km/h)
    final speed = mode == TravelMode.walking ? 1.4 : 8.3;
    final seconds = (distance / speed).round();

    return RouteResult(
      points: [origin, destination],
      distanceMeters: distance,
      duration: Duration(seconds: seconds),
      isEstimate: true,
    );
  }

  String _cacheKey(LatLng origin, LatLng destination, TravelMode mode) {
    final oLat = origin.latitude.toStringAsFixed(4);
    final oLng = origin.longitude.toStringAsFixed(4);
    final dLat = destination.latitude.toStringAsFixed(4);
    final dLng = destination.longitude.toStringAsFixed(4);
    return '${mode.name}_${oLat}_${oLng}_${dLat}_$dLng';
  }
}

