import 'package:equatable/equatable.dart';

/// An item stored in a storage unit.
///
/// Items are registered manually — they do NOT receive QR codes.
/// Each item maintains a reference to its current storage unit.
final class Item extends Equatable {
  const Item({
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

  /// Firestore document ID.
  final String id;

  /// Home this item belongs to (for security rules and queries).
  final String homeId;

  /// The storage unit this item is currently in.
  final String currentStorageId;

  final String name;
  final String? description;
  final String? category;

  /// Quantity of this item type in the storage unit.
  final int quantity;

  /// Optional photo stored in Firebase Storage.
  final String? imageUrl;

  final List<String> tags;

  final DateTime createdAt;
  final DateTime updatedAt;

  Item copyWith({
    String? id,
    String? homeId,
    String? currentStorageId,
    String? name,
    String? description,
    String? category,
    int? quantity,
    String? imageUrl,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Item(
        id: id ?? this.id,
        homeId: homeId ?? this.homeId,
        currentStorageId: currentStorageId ?? this.currentStorageId,
        name: name ?? this.name,
        description: description ?? this.description,
        category: category ?? this.category,
        quantity: quantity ?? this.quantity,
        imageUrl: imageUrl ?? this.imageUrl,
        tags: tags ?? this.tags,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
        id, homeId, currentStorageId, name, description,
        category, quantity, imageUrl, tags, createdAt, updatedAt,
      ];

  @override
  String toString() =>
      'Item(id: $id, name: $name, storage: $currentStorageId, qty: $quantity)';
}
