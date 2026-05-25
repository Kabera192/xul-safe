class ChildModel {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? gender;
  final String? photoUrl;
  final int? pickupStopId;
  final int? dropoffStopId;

  final String? pickupStopName;
  final String? dropoffStopName;
  final String? guardianPhoneNumber;

  final int? createdAt; // ✅ NEW

  const ChildModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.gender,
    required this.photoUrl,
    required this.pickupStopId,
    required this.dropoffStopId,
    this.pickupStopName,
    this.dropoffStopName,
    this.guardianPhoneNumber,
    this.createdAt,
  });

  factory ChildModel.fromApiResponse(Map<String, dynamic> json) {
    return ChildModel(
      id: _toInt(json['id']),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      gender: json['gender']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      pickupStopId: _toNullableInt(json['pickupStopId']),
      dropoffStopId: _toNullableInt(json['dropoffStopId']),
      pickupStopName: json['pickupStopName']?.toString(),
      dropoffStopName: json['dropoffStopName']?.toString(),
      guardianPhoneNumber: json['guardianPhoneNumber']?.toString(),
      createdAt: _toNullableInt(json['createdAt']), // ✅ NEW
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}