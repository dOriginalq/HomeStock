import 'dart:convert';

import '../../features/inventory/domain/entities/item.dart';
import '../../features/movement/domain/entities/movement_record.dart';
import '../../features/rooms/domain/entities/room.dart';
import '../../features/storage/domain/entities/storage_unit.dart';
import '../../shared/data/mock_database.dart';

/// Utility to export residential spatial inventory and audit histories
/// to JSON and CSV formats for academic research evaluation.
abstract final class DatasetExporter {
  /// Exports the entire active home structure to structured JSON.
  static String exportHomeToJson({MockDatabase? db}) {
    final database = db ?? MockDatabase.instance;
    final data = {
      'exported_at': DateTime.now().toIso8601String(),
      'homes': database.homes.map((h) => {
            'id': h.id,
            'name': h.name,
            'address': h.address,
          }).toList(),
      'rooms': database.rooms.map((r) => {
            'id': r.id,
            'name': r.name,
            'storage_count': r.storageUnitCount,
            'item_count': r.totalItemCount,
            'boundary_points': r.boundary?.points
                .map((p) => {
                      'index': p.index,
                      'latitude': p.latitude,
                      'longitude': p.longitude,
                      'accuracy_m': p.accuracyMetres,
                    })
                .toList(),
          }).toList(),
      'storage_units': database.storageUnits.map((s) => {
            'id': s.id,
            'room_id': s.roomId,
            'qr_id': s.qrId,
            'name': s.name,
            'type': s.type,
            'capacity': s.capacityItems,
            'categories': s.expectedCategories,
            'item_count': s.itemCount,
            'position': s.position != null
                ? {
                    'latitude': s.position!.latitude,
                    'longitude': s.position!.longitude,
                    'accuracy_m': s.position!.accuracyMetres,
                  }
                : null,
          }).toList(),
      'items': database.items.map((i) => {
            'id': i.id,
            'storage_id': i.currentStorageId,
            'name': i.name,
            'category': i.category,
            'quantity': i.quantity,
            'description': i.description,
          }).toList(),
      'movement_records': database.movementRecords.map((m) => {
            'id': m.id,
            'item_id': m.itemId,
            'from_storage': m.fromStorageId,
            'to_storage': m.toStorageId,
            'note': m.note,
            'timestamp': m.movedAt.toIso8601String(),
          }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Exports movement history records to CSV format for statistical analysis.
  static String exportMovementToCsv(List<MovementRecord> records) {
    final buffer = StringBuffer();
    buffer.writeln('record_id,item_id,from_storage_id,to_storage_id,note,moved_at');
    for (final r in records) {
      final safeNote = r.note?.replaceAll('"', '""') ?? '';
      buffer.writeln(
        '"${r.id}","${r.itemId}","${r.fromStorageId}","${r.toStorageId}","$safeNote","${r.movedAt.toIso8601String()}"',
      );
    }
    return buffer.toString();
  }
}
