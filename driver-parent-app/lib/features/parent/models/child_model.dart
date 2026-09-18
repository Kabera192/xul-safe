class ChildModel {
  final String id;
  final String fullName;
  final String? gender;
  final String? grade;
  final String? birthDate;
  final String? photoUrl;
  final int? busId;
  final int? createdAt;

  const ChildModel({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.grade,
    required this.birthDate,
    required this.photoUrl,
    required this.busId,
    required this.createdAt,
  });

  factory ChildModel.fromApiResponse(
    Map<String, dynamic> json,
  ) {
    return ChildModel(
      id: (json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      gender: json['gender']?.toString(),
      grade: json['grade']?.toString(),
      birthDate: json['birthDate']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      busId: _toNullableInt(json['busId']),
      createdAt: _toNullableInt(json['createdAt']),
    );
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}