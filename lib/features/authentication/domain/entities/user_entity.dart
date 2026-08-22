import 'package:equatable/equatable.dart';

/// Represents an authenticated user in the HomeStock system.
final class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.createdAt,
    this.displayName,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
  }) =>
      UserEntity(
        id: id ?? this.id,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, createdAt];

  @override
  String toString() => 'UserEntity(id: $id, email: $email, name: $displayName)';
}
