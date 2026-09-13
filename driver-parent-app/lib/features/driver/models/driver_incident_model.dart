class DriverIncidentModel {
  final int id;
  final String type;
  final String description;
  final String status;
  final String journeyImpact;

  final int? createdBy;
  final int? createdAt;

  final int? resolvedBy;
  final int? resolvedAt;

  final Set<int> affectedBusIds;
  final Set<String> affectedChildIds;
  final Set<String> relatedTrackingIds;

  const DriverIncidentModel({
    required this.id,
    required this.type,
    required this.description,
    required this.status,
    required this.journeyImpact,
    required this.createdBy,
    required this.createdAt,
    required this.resolvedBy,
    required this.resolvedAt,
    required this.affectedBusIds,
    required this.affectedChildIds,
    required this.relatedTrackingIds,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  bool get isResolved => status.toUpperCase() == 'RESOLVED';

  DriverIncidentModel copyWith({
    int? id,
    String? type,
    String? description,
    String? status,
    String? journeyImpact,
    int? createdBy,
    int? createdAt,
    int? resolvedBy,
    int? resolvedAt,
    Set<int>? affectedBusIds,
    Set<String>? affectedChildIds,
    Set<String>? relatedTrackingIds,
  }) {
    return DriverIncidentModel(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      status: status ?? this.status,
      journeyImpact: journeyImpact ?? this.journeyImpact,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      affectedBusIds: affectedBusIds ?? this.affectedBusIds,
      affectedChildIds: affectedChildIds ?? this.affectedChildIds,
      relatedTrackingIds: relatedTrackingIds ?? this.relatedTrackingIds,
    );
  }

  factory DriverIncidentModel.fromApiResponse(
    Map<String, dynamic> json,
  ) {
    return DriverIncidentModel(
      id: _toInt(json['id']),
      type: (json['type'] ?? 'OTHER').toString(),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? 'ACTIVE').toString(),
      journeyImpact: (json['journeyImpact'] ?? 'NONE').toString(),
      createdBy: _toNullableInt(json['createdBy']),
      createdAt: _toNullableInt(json['createdAt']),
      resolvedBy: _toNullableInt(json['resolvedBy']),
      resolvedAt: _toNullableInt(json['resolvedAt']),
      affectedBusIds: _toIntSet(json['affectedBusIds']),
      affectedChildIds: _toStringSet(json['affectedChildIds']),
      relatedTrackingIds: _toStringSet(json['relatedTrackingIds']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static Set<int> _toIntSet(dynamic value) {
    if (value is! Iterable) {
      return <int>{};
    }

    return value
        .map(_toNullableInt)
        .whereType<int>()
        .toSet();
  }

  static Set<String> _toStringSet(dynamic value) {
    if (value is! Iterable) {
      return <String>{};
    }

    return value
        .map((item) => item?.toString() ?? '')
        .where((item) => item.isNotEmpty)
        .toSet();
  }
}