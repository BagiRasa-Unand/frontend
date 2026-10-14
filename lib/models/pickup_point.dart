class PickupPoint {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const PickupPoint({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  PickupPoint copyWith({String? name, String? address}) {
    return PickupPoint(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
