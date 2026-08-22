# HomeStock Spatial Algorithms & Geospatial Engine

## 1. Room Boundary Polygon Construction

When the user physically walks to room corners and triggers coordinate capture, an ordered sequence of GPS points is collected:

$$\mathcal{P} = [p_0, p_1, p_2, \dots, p_{n-1}], \quad p_i = (\text{lat}_i, \text{lng}_i)$$

### Validation Invariants
1. **Minimum Vertex Count**: $|\mathcal{P}| \ge 3$
2. **Non-Degeneracy**: Vertices must not be identical within $\epsilon = 10^{-6}$ degrees (~0.1m).
3. **Collinearity Check**: Vertices must not form a 1D line ($|\vec{ab} \times \vec{ac}| > \epsilon$).

---

## 2. Point-in-Polygon (Ray-Casting Algorithm)

To determine whether a storage unit coordinate $S = (\text{lat}_s, \text{lng}_s)$ lies inside a room's boundary polygon $\mathcal{P}$, HomeStock executes the Franklin PNPOLY Ray-Casting algorithm:

```text
Algorithm: RayCasting(S, P)
  inside ← false
  n ← length(P)
  j ← n - 1
  for i ← 0 to n - 1 do
    xi, yi ← P[i].lng, P[i].lat
    xj, yj ← P[j].lng, P[j].lat
    
    intersect ← ((yi > S.lat) ≠ (yj > S.lat)) ∧ 
                (S.lng < (xj - xi) * (S.lat - yi) / (yj - yi) + xi)
    if intersect then
      inside ← ¬inside
    j ← i
  return inside
```

### Complexity
- **Time Complexity**: $\mathcal{O}(n)$ where $n$ is the number of room boundary points (typically $n \in [4, 8]$).
- **Space Complexity**: $\mathcal{O}(1)$ auxiliary memory.

---

## 3. Haversine Distance

The great-circle distance between two GPS coordinates $p_1$ and $p_2$ on a spherical earth of radius $R = 6,371,000\text{ m}$:

$$d = 2R \arcsin\left( \sqrt{\sin^2\left(\frac{\Delta \phi}{2}\right) + \cos(\phi_1)\cos(\phi_2)\sin^2\left(\frac{\Delta \lambda}{2}\right)} \right)$$

where $\phi = \text{radians}(\text{lat})$ and $\lambda = \text{radians}(\text{lng})$.

---

## 4. GPS-to-Canvas Coordinate Normalization

To render the room polygon cleanly on a 2D mobile screen without distortion:

$$\text{drawW} = W - 2 \cdot \text{padW}, \quad \text{drawH} = H - 2 \cdot \text{padH}$$
$$x = \text{padW} + \frac{\text{lng} - \text{minLng}}{\Delta\text{lng}} \cdot \text{drawW}$$
$$y = \text{padH} + \left(1 - \frac{\text{lat} - \text{minLat}}{\Delta\text{lat}}\right) \cdot \text{drawH}$$

Note that latitude increases northward (upward), whereas canvas pixel coordinate $y$ increases downward.
