class BusModel {
  final int id;
  final String plateNumber;
  final String station;
  final int driverId;
  final int routeId;

  const BusModel({
    required this.id,
    required this.plateNumber,
    required this.station,
    required this.driverId,
    required this.routeId,
  });

  factory BusModel.fromApiResponse(Map<String, dynamic> json) {
    return BusModel(
      id: _toInt(json['id']),
      plateNumber: (json['plateNumber'] ?? '').toString(),
      station: (json['station'] ?? '').toString(),
      driverId: _toInt(json['driverId']),
      routeId: _toInt(json['routeId']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}