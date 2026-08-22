import 'dart:convert';

import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/result/result.dart';

/// QR code identity for a storage unit.
///
/// The QR code encodes a JSON payload:
/// ```json
/// {"id": "HS-ST-00042", "v": "1"}
/// ```
///
/// - [id]: stable storage identifier (never changes after creation)
/// - [version]: payload schema version (allows future format changes)
final class QrIdentity {
  const QrIdentity({required this.id, this.version = '1'});

  final String id;
  final String version;

  /// Generates the QR code payload string.
  String toQrPayload() => jsonEncode({'id': id, 'v': version});

  /// Parses a QR code payload string into a [QrIdentity].
  ///
  /// Returns [Result.failure] with [InvalidQrPayloadFailure] if the payload
  /// is malformed or missing required fields.
  static Result<QrIdentity> fromQrPayload(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;

      if (!json.containsKey('id') || json['id'] is! String) {
        return Result.failure(
          const InvalidQrPayloadFailure(
            message: 'QR payload missing "id" field.',
          ),
        );
      }

      final id = json['id'] as String;

      // Validate the ID format: HS-ST-NNNNN
      if (!_isValidStorageId(id)) {
        return Result.failure(
          InvalidQrPayloadFailure(
            message: 'QR payload contains invalid storage ID: $id',
          ),
        );
      }

      final version = (json['v'] as String?) ?? '1';
      return Result.success(QrIdentity(id: id, version: version));
    } on FormatException catch (e) {
      return Result.failure(
        InvalidQrPayloadFailure(message: 'QR payload is not valid JSON: $e'),
      );
    } on TypeError catch (e) {
      return Result.failure(
        InvalidQrPayloadFailure(message: 'QR payload has unexpected type: $e'),
      );
    }
  }

  /// Validates that [id] matches the expected format: HS-ST-NNNNN.
  static bool _isValidStorageId(String id) {
    final prefix = AppConstants.qrIdPrefix;
    if (!id.startsWith(prefix)) return false;
    final numberPart = id.substring(prefix.length);
    return RegExp(r'^\d{5}$').hasMatch(numberPart);
  }

  /// Generates a storage ID string from a sequential [number].
  ///
  /// Example: generateStorageId(42) → 'HS-ST-00042'
  static String generateStorageId(int number) {
    assert(number >= 0 && number <= 99999, 'Storage ID number out of range');
    return '${AppConstants.qrIdPrefix}${number.toString().padLeft(5, '0')}';
  }

  @override
  String toString() => 'QrIdentity(id: $id, v: $version)';
}
