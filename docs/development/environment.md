# HomeStock Development Environment Specification

## 1. System & Toolchain
- **OS**: Microsoft Windows 11 Pro (Build 26100.0)
- **Flutter SDK**: 3.29.0 / stable (Installed at `C:\flutter`, added to User Path)
- **Dart SDK**: 3.7.0
- **JDK**: Eclipse Adoptium OpenJDK 21.0.11 / Oracle Java 25
- **Git**: 2.55.0.windows.2
- **GitHub CLI**: `gh` available

## 2. Directory Structure
```text
C:\Users\FqpF\Documents\Codes\HomeStock
├── lib/
│   ├── app/
│   ├── core/
│   ├── features/
│   │   ├── authentication/
│   │   ├── home/
│   │   ├── inventory/
│   │   ├── movement/
│   │   ├── qr/
│   │   ├── rooms/
│   │   ├── search/
│   │   └── storage/
│   └── shared/
├── test/
│   ├── unit/
│   └── widget/
├── docs/
│   ├── algorithms/
│   ├── architecture/
│   ├── database/
│   ├── decisions/
│   ├── development/
│   └── research/
└── pubspec.yaml
```
