/// User model for mock data.
class UserModel {
  final String id;
  final String name;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String role;
  final String avatar;
  final String? photo;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.role,
    required this.avatar,
    this.photo,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'collector',
      avatar: json['avatar'] ?? '',
      photo: json['photo'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
        'role': role,
        'avatar': avatar,
        'photo': photo,
        'createdAt': createdAt.toIso8601String(),
      };
}
