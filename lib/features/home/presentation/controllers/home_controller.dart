import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/data/mock_database.dart';
import '../../../rooms/data/repositories/mock_room_repository.dart';
import '../../../rooms/domain/entities/room.dart';
import '../../../rooms/domain/repositories/room_repository.dart';
import '../../../storage/data/repositories/mock_storage_repository.dart';
import '../../../storage/domain/entities/storage_unit.dart';
import '../../../storage/domain/repositories/storage_repository.dart';
import 'home_state.dart';

// Providers for Dependency Injection
final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return MockRoomRepository();
});

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return MockStorageRepository();
});

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  final roomRepo = ref.watch(roomRepositoryProvider);
  final storageRepo = ref.watch(storageRepositoryProvider);
  return HomeController(
    roomRepository: roomRepo,
    storageRepository: storageRepo,
  );
});

class HomeController extends StateNotifier<HomeState> {
  HomeController({
    required RoomRepository roomRepository,
    required StorageRepository storageRepository,
    String homeId = 'home-001',
  })  : _roomRepository = roomRepository,
        _storageRepository = storageRepository,
        _homeId = homeId,
        super(const HomeState(isLoading: true)) {
    _init();
  }

  final RoomRepository _roomRepository;
  final StorageRepository _storageRepository;
  final String _homeId;

  StreamSubscription<List<Room>>? _roomsSub;
  StreamSubscription<List<StorageUnit>>? _storageSub;

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);

    // Watch rooms
    _roomsSub = _roomRepository.watchRooms(_homeId).listen((rooms) {
      if (rooms.isEmpty) {
        state = state.copyWith(isLoading: false, rooms: []);
        return;
      }

      // Preserve currently selected room or default to the first (e.g. Bedroom)
      final currentSelected = state.selectedRoom;
      final selected = currentSelected != null
          ? rooms.firstWhere(
              (r) => r.id == currentSelected.id,
              orElse: () => rooms.first,
            )
          : rooms.first;

      state = state.copyWith(
        isLoading: false,
        rooms: rooms,
        selectedRoom: selected,
      );

      _watchStorageForRoom(selected.id);
    });
  }

  void _watchStorageForRoom(String roomId) {
    _storageSub?.cancel();
    _storageSub = _storageRepository
        .watchStorageUnitsForRoom(homeId: _homeId, roomId: roomId)
        .listen((units) {
      state = state.copyWith(storageUnits: units);
    });
  }

  /// Selects a different room and reloads its boundaries, storage units, and item counts.
  void selectRoom(Room room) {
    state = state.copyWith(
      selectedRoom: room,
      clearSelectedMarker: true,
    );
    _watchStorageForRoom(room.id);
  }

  /// Tapping a storage marker on the map highlights/selects it.
  void selectStorageMarker(StorageUnit? unit) {
    state = state.copyWith(selectedStorageMarker: unit);
  }

  @override
  void dispose() {
    _roomsSub?.cancel();
    _storageSub?.cancel();
    super.dispose();
  }
}
