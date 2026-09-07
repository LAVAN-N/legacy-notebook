// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  sku: json['sku'] as String,
  name: json['name'] as String,
  brand: json['brand'] as String,
  categoryId: json['categoryId'] as String,
  minimumStock: (json['minimumStock'] as num).toInt(),
  stock: (json['stock'] as num).toInt(),
  costPrice: (json['costPrice'] as num).toDouble(),
  sellingPrice: (json['sellingPrice'] as num).toDouble(),
  mrp: (json['mrp'] as num).toDouble(),
  imageUrl: json['imageUrl'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'sku': instance.sku,
  'name': instance.name,
  'brand': instance.brand,
  'categoryId': instance.categoryId,
  'minimumStock': instance.minimumStock,
  'stock': instance.stock,
  'costPrice': instance.costPrice,
  'sellingPrice': instance.sellingPrice,
  'mrp': instance.mrp,
  'imageUrl': instance.imageUrl,
  'description': instance.description,
};
