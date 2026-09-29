class IncidentAttachmentModel {
  final int id;
  final String type;
  final int createdAt;

  const IncidentAttachmentModel({
    required this.id,
    required this.type,
    required this.createdAt,
  });

  factory IncidentAttachmentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return IncidentAttachmentModel(
      id: (json['id'] as num).toInt(),
      type: json['type']?.toString() ?? '',
      createdAt: (json['createdAt'] as num).toInt(),
    );
  }

  bool get isImage => type.toUpperCase() == 'IMAGE';

  bool get isAudio => type.toUpperCase() == 'AUDIO';

  DateTime get createdDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt);
}