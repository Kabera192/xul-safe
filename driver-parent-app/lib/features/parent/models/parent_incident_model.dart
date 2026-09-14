class ParentIncidentModel {
  final int id;
  final String type;
  final String description;
  final String status;
  final String journeyImpact;

  final int createdAt;
  final int? resolvedAt;

  final List<String> affectedChildIds;

  const ParentIncidentModel({
    required this.id,
    required this.type,
    required this.description,
    required this.status,
    required this.journeyImpact,
    required this.createdAt,
    required this.resolvedAt,
    required this.affectedChildIds,
  });

  factory ParentIncidentModel.fromJson(Map<String, dynamic> json) {
    return ParentIncidentModel(
      id: (json['id'] as num).toInt(),
      type: json['type']?.toString() ?? 'OTHER',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'ACTIVE',
      journeyImpact: json['journeyImpact']?.toString() ?? 'NONE',
      createdAt: (json['createdAt'] as num).toInt(),
      resolvedAt: json['resolvedAt'] != null
          ? (json['resolvedAt'] as num).toInt()
          : null,
      affectedChildIds: (json['affectedChildIds'] as List<dynamic>? ?? const [])
          .map((id) => id.toString())
          .toList(),
    );
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  bool get isResolved => status.toUpperCase() == 'RESOLVED';

  bool get affectsJourney => journeyImpact.toUpperCase() != 'NONE';

  DateTime get createdDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt);

  DateTime? get resolvedDateTime => resolvedAt == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(resolvedAt!);
}