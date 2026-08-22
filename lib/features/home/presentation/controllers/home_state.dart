import 'package:equatable/equatable.dart';

import '../../../rooms/domain/entities/room.dart';
import '../../../storage/domain/entities/storage_unit.dart';

/// State of the Home dashboard screen.
final class HomeState extends Equatable {
  const HomeState({
    required this.isLoading,
    this.rooms = const [],
    this.selectedRoom,
    this.storageUnits = const [],
    this.errorMessage,
    this.selectedStorageMarker,
  });

  final bool isLoading;
  final List<Room> rooms;
  final Room? selectedRoom;
  final List<StorageUnit> storageUnits;
  final String? errorMessage;
  final StorageUnit? selectedStorageMarker;

  /// Denormalized item count across storage units for the selected room.
  int get totalItemCount =>
      storageUnits.fold(0, (sum, unit) => sum + unit.itemCount);

  /// Number of storage units in the selected room.
  int get storageUnitCount => storageUnits.length;

  HomeState copyWith({
    bool? isLoading,
    List<Room>? rooms,
    Room? selectedRoom,
    List<StorageUnit>? storageUnits,
    String? errorMessage,
    StorageUnit? selectedStorageMarker,
    bool clearSelectedMarker = false,
  }) =>
      HomeState(
        isLoading: isLoading ?? this.isLoading,
        rooms: rooms ?? this.rooms,
        selectedRoom: selectedRoom ?? this.selectedRoom,
        storageUnits: storageUnits ?? this.storageUnits,
        errorMessage: errorMessage,
        selectedStorageMarker: clearSelectedMarker
            ? null
            : (selectedStorageMarker ?? this.selectedStorageMarker),
      );

  @override
  List<Object?> get props => [
        isLoading,
        rooms,
        selectedRoom,
        storageUnits,
        errorMessage,
        selectedStorageMarker,
      ];
}
