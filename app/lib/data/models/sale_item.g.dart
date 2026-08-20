// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SaleItem _$SaleItemFromJson(Map<String, dynamic> json) => _SaleItem(
  id: json['id'] as String,
  saleId: json['saleId'] as String,
  productId: json['productId'] as String,
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: (json['unitPrice'] as num).toInt(),
  totalPrice: (json['totalPrice'] as num).toInt(),
  status: json['status'] as String? ?? 'purchased',
  collectedAmount: (json['collectedAmount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SaleItemToJson(_SaleItem instance) => <String, dynamic>{
  'id': instance.id,
  'saleId': instance.saleId,
  'productId': instance.productId,
  'quantity': instance.quantity,
  'unitPrice': instance.unitPrice,
  'totalPrice': instance.totalPrice,
  'status': instance.status,
  'collectedAmount': instance.collectedAmount,
};
