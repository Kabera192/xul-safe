class ParentProfileModel {
  final int userId;
  final int parentId;
  final String role;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? photoUrl;

  const ParentProfileModel({
    required this.userId,
    required this.parentId,
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

  factory ParentProfileModel.fromApiResponse(Map<String, dynamic> json) {
    return ParentProfileModel(
      userId: _toInt(json['userId']),
      parentId: _toInt(json['profileId']),
      role: json['role']?.toString() ?? 'PARENT',
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