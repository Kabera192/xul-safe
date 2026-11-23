class ChildModel {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? gender;
  final String? photoUrl;
  // The backend assigns a child a single stop, used for both boarding and
  // alighting — see DriverChildSummaryDto.busStopId.
  final String? busStopId;

  final String? guardianPhoneNumber;

  final int? createdAt; // ✅ NEW

  const ChildModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.gender,
    required this.photoUrl,
    required this.busStopId,
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
      busStopId: json['busStopId']?.toString(),
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