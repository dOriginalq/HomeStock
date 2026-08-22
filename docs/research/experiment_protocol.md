# HomeStock Research Protocol & Experiment Instrumentation

## 1. Research Objectives
This prototype investigates the spatial cognitive efficacy and retrieval speed of QR-identified storage hierarchy vs. traditional flat inventory catalogs.

## 2. Instrumented Metrics
Via `InstrumentationService`:
1. **QR Scan & Decode Latency ($T_{\text{scan}}$)**: Duration from camera frame acquisition to valid `QrIdentity` parse.
2. **Spatial Location Resolution Latency ($T_{\text{res}}$)**: Time to perform point-in-polygon containment check and map storage unit to room boundary.
3. **Item Retrieval Latency ($T_{\text{search}}$)**: Time from search query input to full hierarchical resolution (`Item -> Storage -> Room`).
4. **Movement Transaction Latency ($T_{\text{move}}$)**: Time to execute atomic transfer, update dual-storage counts, and append immutable `MovementRecord`.

## 3. Benchmark Datasets
- Synthetic residential datasets stored in `experiments/datasets/`:
  - 10 rooms (rectangular & non-convex L-shaped polygons)
  - 50 storage units (Shelves, Drawers, Wardrobes)
  - 500 household items across standard residential categories.
