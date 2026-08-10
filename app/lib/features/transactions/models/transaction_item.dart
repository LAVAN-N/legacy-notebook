import '../../../core/utils/formatters.dart';
import '../../../data/models/customer.dart';

class TransactionItem {
  final String id;
  final String customerId;
  final String customerName;
  final Customer? customer;
  final DateTime date;
  final String type; // 'SALE' or 'COLLECTION'
  final String
      status; // 'READY', 'CREDIT', 'PAYMENT', 'PARTIAL_PAYMENT', 'CARRY_FORWARD', 'LEND', 'LEND_COLLECTION'
  final int amount;
  final String subtitle;
  final String remarks;

  TransactionItem({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customer,
    required this.date,
    required this.type,
    required this.status,
    required this.amount,
    required this.subtitle,
    required this.remarks,
  });
}

class CollectionDetails {
  final String target;
  final String note;

  CollectionDetails({required this.target, required this.note});

  factory CollectionDetails.parse(String? reason) {
    if (reason == null || !reason.startsWith('COLLECTION_TARGET:')) {
      return CollectionDetails(target: 'SALE', note: reason ?? '');
    }
    try {
      final query = reason.substring('COLLECTION_TARGET:'.length);
      final params = Uri.splitQueryString(query);
      return CollectionDetails(
        target: params['target'] ?? 'SALE',
        note: params['note'] ?? '',
      );
    } catch (_) {
      return CollectionDetails(target: 'SALE', note: reason);
    }
  }
}

class LendDetails {
  final int principal;
  final int charge;
  final String note;

  LendDetails({required this.principal, required this.charge, required this.note});

  factory LendDetails.parse(String remarks) {
    if (!remarks.startsWith('LEND_DETAILS:')) {
      return LendDetails(principal: 0, charge: 0, note: remarks);
    }
    try {
      final query = remarks.substring('LEND_DETAILS:'.length);
      final params = Uri.splitQueryString(query);
      return LendDetails(
        principal: int.parse(params['principal'] ?? '0'),
        charge: int.parse(params['charge'] ?? '0'),
        note: params['note'] ?? '',
      );
    } catch (_) {
      return LendDetails(principal: 0, charge: 0, note: remarks);
    }
  }

  String toSimpleInfo() {
    if (principal == 0 && charge == 0) return note;
    final notePart = note.isNotEmpty ? ' ($note)' : '';
    return 'Principal: ${rupees(principal)} + Charge: ${rupees(charge)}$notePart';
  }
}
