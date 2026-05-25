class RouteModel {
  final int id;
  final String name;

  const RouteModel({
    required this.id,
    required this.name,
  });

  factory RouteModel.fromApiResponse(Map<String, dynamic> json) {
    return RouteModel(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}