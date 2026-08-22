import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../inventory/domain/entities/item.dart';

/// Firestore serialization model for [Item].
class ItemModel {
  const ItemModel({
    required this.id,
    required this.homeId,
    required this.currentStorageId,
    required this.name,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.category,
    this.imageUrl,
    this.tags = const [],
  });

  final String id;
  final String homeId;
  final String currentStorageId;
  final String name;
  final int quantity;
  final String? description;
  final String? category;
  final String? imageUrl;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ItemModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final rawTags = data['tags'] as List<dynamic>?;
    final tags = rawTags != null
        ? rawTags.map((e) => e.toString()).toList()
        : <String>[];

    return ItemModel(
      id: doc.id,
      homeId: data['home_id'] as String? ?? '',
      currentStorageId: data['current_storage_id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      description: data['description'] as String?,
      category: data['category'] as String?,
      imageUrl: data['image_url'] as String?,
      tags: tags,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'home_id': homeId,
      'current_storage_id': currentStorageId,
      'name': name,
      'quantity': quantity,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (imageUrl != null) 'image_url': imageUrl,
      'tags': tags,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  Item toEntity() => Item(
        id: id,
        homeId: homeId,
        currentStorageId: currentStorageId,
        name: name,
        quantity: quantity,
        description: description,
        category: category,
        imageUrl: imageUrl,
        tags: tags,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory ItemModel.fromEntity(Item item) => ItemModel(
        id: item.id,
        homeId: item.homeId,
        currentStorageId: item.currentStorageId,
        name: item.name,
        quantity: item.quantity,
        description: item.description,
        category: item.category,
        imageUrl: item.imageUrl,
        tags: item.tags,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );
}
