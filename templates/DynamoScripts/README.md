# Dynamo Python Scripts Template

Production-ready, battle-tested Python scripts for Autodesk Revit Dynamo graphs.

---

## Included Templates:

1. **`StandardDynamoPythonTemplate.py`:** Clean boilerplate with defensive list normalization, `RevitServices` imports, `UnwrapElement`, and safe transaction scoping.
2. **`BatchParameterSetter.py`:** Batch sets text, numerical, or length parameters on unwrapped Revit elements.
3. **`RoomAuditScript.py`:** Scans model for unplaced or redundant rooms, returning clean status lists to Dynamo ports.

---

## How to Use in Dynamo:

1. In Dynamo, search for and place a **Python Script** node.
2. Double-click the node to open the Python script editor.
3. Copy and paste the contents of any script into the editor.
4. Wire your Dynamo nodes into `IN[0]`, `IN[1]`, etc., and run the graph.
