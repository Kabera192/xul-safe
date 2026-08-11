class ChildModel {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? gender;
  final String? photoUrl;
  final String? stopId;

  final String? stopName;
  final String? guardianPhoneNumber;

  final int? createdAt; // ✅ NEW

  const ChildModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.gender,
    required this.photoUrl,
    required this.stopId,
    this.stopName,
    this.guardianPhoneNumber,
    this.createdAt,
  });

  factory ChildModel.fromApiResponse(Map<String, dynamic> json) {
    return ChildModel(
      id: (json['id'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      gender: json['gender']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      stopId: json['busStopId']?.toString(),
      stopName: json['busStopName']?.toString(),
      guardianPhoneNumber: json['guardianPhoneNumber']?.toString(),
      createdAt: _toNullableInt(json['createdAt']), // ✅ NEW
    );
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
