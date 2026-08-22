# ADR 001: Third-Party Dependency Isolation & Minimization Strategy

## Context & Problem Statement
HomeStock is a long-term research prototype designed to yield reproducible benchmarks and maintainable architecture. Proliferation of unvetted third-party packages causes dependency drift, native plugin breakage across Flutter upgrades, and fragile unit test execution.

## Decision
1. **Prefer Dart Standard Libraries**: Ray-casting point-in-polygon, Haversine distance, and coordinate normalisation are written entirely in pure Dart with zero external libraries.
2. **Interface Abstraction**: Every platform-dependent capability (GPS location, QR camera scanning, cloud storage, Firestore) must implement an abstract domain interface.
3. **Auditability**: All dependencies in `pubspec.yaml` are justified by non-trivial platform integration requirements (e.g. camera, GPS hardware sensors, Firebase).

## Consequences
- Full domain and spatial engine unit testability without platform channels or mocking overhead.
- Simple replacement strategy if alternative sensor SDKs are evaluated in future research.
