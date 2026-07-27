// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: json['id'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      categoryId: json['categoryId'] as String,
      minimumStock: (json['minimumStock'] as num).toInt(),
      stock: (json['stock'] as num).toInt(),
      costPrice: (json['costPrice'] as num).toInt(),
      sellingPrice: (json['sellingPrice'] as num).toInt(),
      mrp: (json['mrp'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
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
