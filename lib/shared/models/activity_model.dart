/// Activity model for mock data (collections and sales).
class ActivityModel {
  final String id;
  final String customerId;
  final String type; // payment, partial_payment, carry_forward, sale, advance
  final int amount;
  final String note;
  final DateTime timestamp;
  final String collectorId;

  ActivityModel({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.note,
    required this.timestamp,
    required this.collectorId,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      type: json['type'] ?? 'payment',
      amount: json['amount'] ?? 0,
      note: json['note'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      collectorId: json['collectorId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'type': type,
        'amount': amount,
        'note': note,
        'timestamp': timestamp.toIso8601String(),
        'collectorId': collectorId,
      };

  /// Get display label for activity type.
  String get typeLabel {
    switch (type) {
      case 'payment':
        return 'Payment';
      case 'partial_payment':
        return 'Partial Payment';
      case 'carry_forward':
        return 'Carry Forward';
      case 'sale':
        return 'Sale';
      case 'advance':
        return 'Advance';
      default:
        return type;
    }
  }

  /// Get icon for activity type.
  String get typeIcon {
    switch (type) {
      case 'payment':
      case 'partial_payment':
        return '💰';
      case 'carry_forward':
        return '📋';
      case 'sale':
        return '🛍️';
      case 'advance':
        return '💳';
      default:
        return '📝';
    }
  }

  /// Check if this activity reduces outstanding.
  bool get reducesOutstanding {
    return type == 'payment' || type == 'partial_payment';
  }

  /// Get formatted timestamp (time only).
  String get timeString => '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

  /// Get time ago string.
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).toStringAsFixed(0)}w ago';
    }
  }
}
