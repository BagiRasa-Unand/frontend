import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../data/location_platform.dart';
import '../data/location_service.dart';
import '../data/route_service.dart';
import 'countdown_controller.dart';

/// Presentation state for the route navigation view.
enum RouteViewState {
  loading,
  ready,
  needsLocation,
}

/// Controller managing route fetching, transport mode toggling, live position
/// tracking, and arrival detection.
class RouteController extends ChangeNotifier {
  RouteController({
    required this.routeService,
    required this.locationPlatform,
    required this.destination,
    required this.pickupPointName,
    this.pickupDeadline,
    this.onArrived,
  }) {
    if (pickupDeadline != null) {
      countdownController = CountdownController(pickupDeadline: pickupDeadline!);
    }
  }

  final RouteService routeService;
  final LocationPlatform locationPlatform;
  final LatLng destination;
  final String pickupPointName;
  final DateTime? pickupDeadline;
  final VoidCallback? onArrived;

  CountdownController? countdownController;

  RouteViewState _state = RouteViewState.loading;
  RouteViewState get state => _state;

  TravelMode _mode = TravelMode.walking;
  TravelMode get mode => _mode;

  LatLng? _currentPosition;
  LatLng? get currentPosition => _currentPosition;

  RouteResult? _routeResult;
  RouteResult? get routeResult => _routeResult;

  double? _liveRemainingDistance;
  double? get remainingDistanceMeters =>
      _liveRemainingDistance ?? _routeResult?.distanceMeters;

  Duration? get estimatedDuration => _routeResult?.duration;

  bool _isFollowing = false;
  bool get isFollowing => _isFollowing;

  bool _hasArrived = false;
  bool get hasArrived => _hasArrived;

  StreamSubscription<LatLng>? _positionSubscription;

  /// Sets the initial user coordinates.
  ///
  /// If [pos] is null, switches to [RouteViewState.needsLocation].
  /// Otherwise, fetches the route between [pos] and [destination].
  void setInitialLocation(LatLng? pos) {
    if (pos == null) {
      _currentPosition = null;
      _state = RouteViewState.needsLocation;
      notifyListeners();
      return;
    }

    _currentPosition = pos;
    fetchRoute();
  }

  /// Fetches the route from the current position to the destination.
  Future<void> fetchRoute() async {
    if (_currentPosition == null) {
      _state = RouteViewState.needsLocation;
      notifyListeners();
      return;
    }

    _state = RouteViewState.loading;
    notifyListeners();

    _routeResult = await routeService.getRoute(
      _currentPosition!,
      destination,
      _mode,
    );
    _liveRemainingDistance = _routeResult?.distanceMeters;
    _state = RouteViewState.ready;
    notifyListeners();
  }

  /// Toggles transport mode between walking and motor.
  void toggleMode(TravelMode newMode) {
    if (_mode == newMode) return;
    _mode = newMode;
    fetchRoute();
  }

  /// Starts live GPS subscription to update coordinates and distance during travel.
  void startFollowing() {
    _isFollowing = true;
    _hasArrived = false;
    _positionSubscription?.cancel();

    _positionSubscription = locationPlatform
        .positionStream(distanceFilterMeters: 10)
        .listen((newPos) {
      _currentPosition = newPos;
      _liveRemainingDistance = LocationService.distanceMeters(newPos, destination);

      if (_liveRemainingDistance != null &&
          _liveRemainingDistance! <= 30.0 &&
          !_hasArrived) {
        _hasArrived = true;
        onArrived?.call();
      }
      notifyListeners();
    });

    notifyListeners();
  }

  /// Stops live following subscription.
  void stopFollowing() {
    _isFollowing = false;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    notifyListeners();
  }

  /// Re-evaluates current route.
  void refresh() {
    fetchRoute();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    countdownController?.dispose();
    super.dispose();
  }
}

