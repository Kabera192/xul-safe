class AttendanceRecordModel {
  final String childId;
  final String childName;
  final String? grade;
  final String? gender;
  final String? photoUrl;

  /// 'MORNING' or 'AFTERNOON'
  final String session;

  /// Step 1 – child got on the bus
  final bool boarded;
  final int? boardedAt;

  /// Step 2 – child arrived at destination (school for MORNING, stop for AFTERNOON)
  final bool droppedOff;
  final int? droppedOffAt;

  /// True when the parent has marked this child absent for this session today.
  final bool isAbsent;

  const AttendanceRecordModel({
    required this.childId,
    required this.childName,
    this.grade,
    this.gender,
    this.photoUrl,
    required this.session,
    required this.boarded,
    this.boardedAt,
    required this.droppedOff,
    this.droppedOffAt,
    this.isAbsent = false,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      childId: (json['childId'] ?? '').toString(),
      childName: (json['childName'] ?? '').toString(),
      grade: json['grade']?.toString(),
      gender: json['gender']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      session: (json['session'] ?? 'MORNING').toString(),
      boarded: json['boarded'] == true,
      boardedAt: _toNullableInt(json['boardedAt']),
      droppedOff: json['droppedOff'] == true,
      droppedOffAt: _toNullableInt(json['droppedOffAt']),
      isAbsent: json['isAbsent'] == true,
    );
  }

  AttendanceRecordModel copyWith({
    bool? boarded,
    int? boardedAt,
    bool? droppedOff,
    int? droppedOffAt,
    bool? isAbsent,
  }) {
    return AttendanceRecordModel(
      childId: childId,
      childName: childName,
      grade: grade,
      gender: gender,
      photoUrl: photoUrl,
      session: session,
      boarded: boarded ?? this.boarded,
      boardedAt: boardedAt ?? this.boardedAt,
      droppedOff: droppedOff ?? this.droppedOff,
      droppedOffAt: droppedOffAt ?? this.droppedOffAt,
      isAbsent: isAbsent ?? this.isAbsent,
    );
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

