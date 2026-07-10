/// Weekday model for mock data.
class WeekdayModel {
  final String id;
  final String day;
  final String dayShort;
  final int dayNumber;
  final int placeCount;
  final int areaCount;
  final int customerCount;
  final int expectedAmount;
  final int collectedAmount;

  WeekdayModel({
    required this.id,
    required this.day,
    required this.dayShort,
    required this.dayNumber,
    required this.placeCount,
    required this.areaCount,
    required this.customerCount,
    required this.expectedAmount,
    required this.collectedAmount,
  });

  factory WeekdayModel.fromJson(Map<String, dynamic> json) {
    return WeekdayModel(
      id: json['id'] ?? '',
      day: json['day'] ?? '',
      dayShort: json['dayShort'] ?? '',
      dayNumber: json['dayNumber'] ?? 0,
      placeCount: json['placeCount'] ?? 0,
      areaCount: json['areaCount'] ?? 0,
      customerCount: json['customerCount'] ?? 0,
      expectedAmount: json['expectedAmount'] ?? 0,
      collectedAmount: json['collectedAmount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'day': day,
        'dayShort': dayShort,
        'dayNumber': dayNumber,
        'placeCount': placeCount,
        'areaCount': areaCount,
        'customerCount': customerCount,
        'expectedAmount': expectedAmount,
        'collectedAmount': collectedAmount,
      };

  int get pendingAmount => expectedAmount - collectedAmount;
  double get progressPercentage =>
      expectedAmount > 0 ? (collectedAmount / expectedAmount) * 100 : 0;
}
