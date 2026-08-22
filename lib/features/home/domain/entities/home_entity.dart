import 'package:equatable/equatable.dart';

/// Represents a residential home structure managed in HomeStock.
final class HomeEntity extends Equatable {
  const HomeEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.address,
  });

  final String id;
  final String ownerId;
  final String name;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  HomeEntity copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      HomeEntity(
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        name: name ?? this.name,
        address: address ?? this.address,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [id, ownerId, name, address, createdAt, updatedAt];

  @override
  String toString() => 'HomeEntity(id: $id, ownerId: $ownerId, name: $name)';
}
