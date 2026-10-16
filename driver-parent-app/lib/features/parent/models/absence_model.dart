class AbsenceModel {
  final int id;
  final String absenceType; // 'MORNING' | 'EVENING' | 'MULTIPLE_DAYS'
  final String startDate; // yyyy-MM-dd
  final String endDate; // yyyy-MM-dd
  final String status;

  const AbsenceModel({
    required this.id,
    required this.absenceType,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  factory AbsenceModel.fromApiResponse(Map<String, dynamic> json) {
    return AbsenceModel(
      id: _toInt(json['id']),
      absenceType: (json['absenceType'] ?? 'MORNING').toString(),
      startDate: (json['startDate'] ?? '').toString(),
      endDate: (json['endDate'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}
