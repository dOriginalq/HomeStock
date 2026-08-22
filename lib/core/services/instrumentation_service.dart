import 'dart:developer' as developer;

/// Record representing a measured experiment metric for research evaluation.
final class ExperimentMetric {
  const ExperimentMetric({
    required this.name,
    required this.durationMs,
    required this.timestamp,
    required this.success,
    this.metadata = const {},
    this.errorMessage,
  });

  final String name;
  final int durationMs;
  final DateTime timestamp;
  final bool success;
  final Map<String, dynamic> metadata;
  final String? errorMessage;

  Map<String, dynamic> toJson() => {
        'name': name,
        'duration_ms': durationMs,
        'timestamp': timestamp.toIso8601String(),
        'success': success,
        'metadata': metadata,
        if (errorMessage != null) 'error_message': errorMessage,
      };

  @override
  String toString() =>
      'Metric($name: ${durationMs}ms, success: $success, meta: $metadata)';
}

/// Research instrumentation service.
///
/// Designed to measure latencies, success rates, and performance for academic
/// evaluation without polluting business logic.
///
/// Can be enabled/disabled at runtime; zero overhead when disabled.
class InstrumentationService {
  InstrumentationService({this.enabled = true});

  bool enabled;
  final List<ExperimentMetric> _metrics = [];

  List<ExperimentMetric> get metrics => List.unmodifiable(_metrics);

  /// Measures execution time of an asynchronous operation [action].
  Future<T> measure<T>({
    required String name,
    required Future<T> Function() action,
    Map<String, dynamic> metadata = const {},
  }) async {
    if (!enabled) return action();

    final stopwatch = Stopwatch()..start();
    try {
      final result = await action();
      stopwatch.stop();
      _record(
        ExperimentMetric(
          name: name,
          durationMs: stopwatch.elapsedMilliseconds,
          timestamp: DateTime.now(),
          success: true,
          metadata: metadata,
        ),
      );
      return result;
    } catch (e) {
      stopwatch.stop();
      _record(
        ExperimentMetric(
          name: name,
          durationMs: stopwatch.elapsedMilliseconds,
          timestamp: DateTime.now(),
          success: false,
          metadata: metadata,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    }
  }

  void _record(ExperimentMetric metric) {
    _metrics.add(metric);
    developer.log(
      '📊 [RESEARCH METRIC] ${metric.name}: ${metric.durationMs}ms (Success: ${metric.success})',
      name: 'HomeStock.Instrumentation',
    );
  }

  /// Clears recorded metrics.
  void clear() => _metrics.clear();

  /// Exports metrics as JSON list for dataset generation.
  List<Map<String, dynamic>> exportJson() =>
      _metrics.map((m) => m.toJson()).toList();
}
