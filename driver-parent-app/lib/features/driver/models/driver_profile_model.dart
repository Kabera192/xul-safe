class DriverProfileModel {
  final int userId;
  final int driverId;
  final String role;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? photoUrl;

  const DriverProfileModel({
    required this.userId,
    required this.driverId,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.photoUrl,
  });

  String get fullName {
    final first = firstName.trim();
    final last = lastName.trim();
    return '$first $last'.trim();
  }

  String get maskedPassword => '********';

  factory DriverProfileModel.fromApiResponse(Map<String, dynamic> json) {
    return DriverProfileModel(
      userId: _toInt(json['userId']),
      driverId: _toInt(json['profileId']),
      role: json['role']?.toString() ?? 'DRIVER',
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      photoUrl: json['photoUrl']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}