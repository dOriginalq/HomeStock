import '../../../../core/result/result.dart';
import 'qr_identity.dart';

/// Contract for camera QR code scanning.
///
/// Isolated behind this interface so UI/domain never interacts directly with
/// mobile_scanner or any specific camera package.
abstract interface class QrScannerService {
  /// Scans a single QR code and parses the [QrIdentity].
  Future<Result<QrIdentity>> scanStorageQr();
}
