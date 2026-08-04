import 'package:freezed_annotation/freezed_annotation.dart';

part 'outstanding.freezed.dart';
part 'outstanding.g.dart';

@freezed
class Outstanding with _$Outstanding {
  const factory Outstanding({
    required String customerId,
    required int totalFinanced,
    required int totalCollected,
    required int outstandingAmount, // totalFinanced - totalCollected
    @Default(0) int totalLendFinanced,
    @Default(0) int totalLendCollected,
    @Default(0) int totalSaleFinanced,
    @Default(0) int totalSaleCollected,
  }) = _Outstanding;

  const Outstanding._();

  int get lendOutstanding => totalLendFinanced - totalLendCollected;
  int get saleOutstanding => totalSaleFinanced - totalSaleCollected;

  factory Outstanding.fromJson(Map<String, dynamic> json) => _$OutstandingFromJson(json);
}
