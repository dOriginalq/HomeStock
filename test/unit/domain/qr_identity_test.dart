import 'package:flutter_test/flutter_test.dart';
import 'package:homestock/core/errors/failures.dart';
import 'package:homestock/features/qr/domain/services/qr_identity.dart';

void main() {
  group('QrIdentity.generateStorageId', () {
    test('generates correctly formatted ID', () {
      expect(QrIdentity.generateStorageId(0), 'HS-ST-00000');
      expect(QrIdentity.generateStorageId(1), 'HS-ST-00001');
      expect(QrIdentity.generateStorageId(42), 'HS-ST-00042');
      expect(QrIdentity.generateStorageId(99999), 'HS-ST-99999');
    });

    test('pads numbers correctly', () {
      expect(QrIdentity.generateStorageId(5), 'HS-ST-00005');
      expect(QrIdentity.generateStorageId(100), 'HS-ST-00100');
      expect(QrIdentity.generateStorageId(1000), 'HS-ST-01000');
    });
  });

  group('QrIdentity.toQrPayload', () {
    test('serialises to expected JSON', () {
      const identity = QrIdentity(id: 'HS-ST-00042');
      final payload = identity.toQrPayload();
      expect(payload, '{"id":"HS-ST-00042","v":"1"}');
    });
  });

  group('QrIdentity.fromQrPayload', () {
    test('parses valid payload', () {
      const payload = '{"id":"HS-ST-00042","v":"1"}';
      final result = QrIdentity.fromQrPayload(payload);
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.id, 'HS-ST-00042');
      expect(result.valueOrNull!.version, '1');
    });

    test('round-trip: toQrPayload → fromQrPayload', () {
      const original = QrIdentity(id: 'HS-ST-00007');
      final payload = original.toQrPayload();
      final result = QrIdentity.fromQrPayload(payload);
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.id, original.id);
    });

    test('returns failure for empty string', () {
      final result = QrIdentity.fromQrPayload('');
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<InvalidQrPayloadFailure>());
    });

    test('returns failure for missing id field', () {
      const payload = '{"v":"1"}';
      final result = QrIdentity.fromQrPayload(payload);
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<InvalidQrPayloadFailure>());
    });

    test('returns failure for invalid ID format', () {
      const payload = '{"id":"NOT-VALID","v":"1"}';
      final result = QrIdentity.fromQrPayload(payload);
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<InvalidQrPayloadFailure>());
    });

    test('returns failure for plain string (not JSON)', () {
      const payload = 'just a plain string';
      final result = QrIdentity.fromQrPayload(payload);
      expect(result.isFailure, isTrue);
    });

    test('returns failure for integer id type', () {
      const payload = '{"id":42,"v":"1"}';
      final result = QrIdentity.fromQrPayload(payload);
      expect(result.isFailure, isTrue);
    });

    test('returns failure for wrong prefix', () {
      const payload = '{"id":"XX-ST-00042","v":"1"}';
      final result = QrIdentity.fromQrPayload(payload);
      expect(result.isFailure, isTrue);
    });

    test('returns failure for too-short number part', () {
      const payload = '{"id":"HS-ST-042","v":"1"}';
      final result = QrIdentity.fromQrPayload(payload);
      expect(result.isFailure, isTrue);
    });
  });
}
