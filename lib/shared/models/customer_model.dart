/// Customer model for mock data.
class CustomerModel {
  final String id;
  final String areaId;
  final String name;
  final String phone;
  final String? alternatePhone;
  final String code;
  final String? photo;
  final int outstanding;
  final String status;
  final DateTime? lastVisit;
  final String address;
  final String? landmark;
  final Map<String, double> gps;
  final String? guardianName;
  final DateTime? dob;
  final String? occupation;

  CustomerModel({
    required this.id,
    required this.areaId,
    required this.name,
    required this.phone,
    this.alternatePhone,
    required this.code,
    this.photo,
    required this.outstanding,
    required this.status,
    this.lastVisit,
    required this.address,
    this.landmark,
    required this.gps,
    this.guardianName,
    this.dob,
    this.occupation,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? '',
      areaId: json['areaId'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      alternatePhone: json['alternatePhone'],
      code: json['code'] ?? '',
      photo: json['photo'],
      outstanding: json['outstanding'] ?? 0,
      status: json['status'] ?? 'pending',
      lastVisit: json['lastVisit'] != null ? DateTime.parse(json['lastVisit']) : null,
      address: json['address'] ?? '',
      landmark: json['landmark'],
      gps: Map<String, double>.from(json['gps'] ?? {}),
      guardianName: json['guardianName'],
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      occupation: json['occupation'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'areaId': areaId,
        'name': name,
        'phone': phone,
        'alternatePhone': alternatePhone,
        'code': code,
        'photo': photo,
        'outstanding': outstanding,
        'status': status,
        'lastVisit': lastVisit?.toIso8601String(),
        'address': address,
        'landmark': landmark,
        'gps': gps,
        'guardianName': guardianName,
        'dob': dob?.toIso8601String(),
        'occupation': occupation,
      };

  /// Get first name for display.
  String get firstName => name.split(' ').first;

  /// Get initials for avatar.
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  /// Mask phone number (show last 4 digits).
  String get maskedPhone {
    if (phone.length < 4) return phone;
    return '•••• ${phone.substring(phone.length - 4)}';
  }
}
