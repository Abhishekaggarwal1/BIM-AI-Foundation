# Rhino.Inside.Revit & Grasshopper Integration
<!-- BIM-AI-Foundation | Technical Reference -->

Rhino.Inside.Revit runs as an unmanaged C++ add-in that boots the .NET runtime and loads `Rhino.Inside` into the same process as `Revit.exe`.

---

## 1. Key Invariants

1. **Revit Transaction Tracking:** Grasshopper components that output to Revit participate in Grasshopper's solution lifecycle. Always wrap write operations in `Revit.Transaction` or let RiR native components manage transaction groups.
2. **Tolerance Differences:**
   * Rhino default: 0.001 units (meters/feet).
   * Revit short-curve limit: Revit **cannot represent curves shorter than 1/32" (~0.79 mm)**. Any Rhino Brep edge shorter than this limit will fail when converting to a Revit `Solid`.
3. **Orientation & Units:** Ensure Grasshopper document units match Revit project units before converting geometry.
