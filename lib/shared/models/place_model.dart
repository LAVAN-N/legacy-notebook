/// Place model for mock data.
class PlaceModel {
  final String id;
  final String weekdayId;
  final String name;
  final int areaCount;
  final int customerCount;
  final int expectedAmount;
  final int collectedAmount;
  final Map<String, double> gps;
  final double distance;

  PlaceModel({
    required this.id,
    required this.weekdayId,
    required this.name,
    required this.areaCount,
    required this.customerCount,
    required this.expectedAmount,
    required this.collectedAmount,
    required this.gps,
    required this.distance,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'] ?? '',
      weekdayId: json['weekdayId'] ?? '',
      name: json['name'] ?? '',
      areaCount: json['areaCount'] ?? 0,
      customerCount: json['customerCount'] ?? 0,
      expectedAmount: json['expectedAmount'] ?? 0,
      collectedAmount: json['collectedAmount'] ?? 0,
      gps: Map<String, double>.from(json['gps'] ?? {}),
      distance: (json['distance'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'weekdayId': weekdayId,
        'name': name,
        'areaCount': areaCount,
        'customerCount': customerCount,
        'expectedAmount': expectedAmount,
        'collectedAmount': collectedAmount,
        'gps': gps,
        'distance': distance,
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
