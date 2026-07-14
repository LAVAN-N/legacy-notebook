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
      price: (json['price'] as num).toInt(),
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
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
    };
