/// Area model for mock data.
class AreaModel {
  final String id;
  final String placeId;
  final String name;
  final int customerCount;
  final int expectedAmount;
  final int collectedAmount;
  final Map<String, double> gps;

  AreaModel({
    required this.id,
    required this.placeId,
    required this.name,
    required this.customerCount,
    required this.expectedAmount,
    required this.collectedAmount,
    required this.gps,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id'] ?? '',
      placeId: json['placeId'] ?? '',
      name: json['name'] ?? '',
      customerCount: json['customerCount'] ?? 0,
      expectedAmount: json['expectedAmount'] ?? 0,
      collectedAmount: json['collectedAmount'] ?? 0,
      gps: Map<String, double>.from(json['gps'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'placeId': placeId,
        'name': name,
        'customerCount': customerCount,
        'expectedAmount': expectedAmount,
        'collectedAmount': collectedAmount,
        'gps': gps,
      };

  int get pendingAmount => expectedAmount - collectedAmount;
  double get progressPercentage =>
      expectedAmount > 0 ? (collectedAmount / expectedAmount) * 100 : 0;

  String get status {
    if (collectedAmount >= expectedAmount) return 'done';
    if (collectedAmount > 0) return 'in_progress';
    return 'pending';
  }
}
