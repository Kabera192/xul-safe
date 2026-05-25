class StopModel {
  final int id;
  final double locationLat;
  final double locationLong;
  final String locationName;
  final int routeId;

  const StopModel({
    required this.id,
    required this.locationLat,
    required this.locationLong,
    required this.locationName,
    required this.routeId,
  });

  factory StopModel.fromApiResponse(Map<String, dynamic> json) {
    return StopModel(
      id: _toInt(json['id']),
      locationLat: _toDouble(json['locationLat']),
      locationLong: _toDouble(json['locationLong']),
      locationName: (json['locationName'] ?? '').toString(),
      routeId: _toInt(json['routeId']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}