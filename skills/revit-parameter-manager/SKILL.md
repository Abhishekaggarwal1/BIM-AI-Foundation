---
name: revit-parameter-manager
description: |
  Safe parameter retrieval, writing, type checking, and unit conversions using modern ForgeTypeId.
  Use whenever user asks to read, write, bulk-update, or convert units for Revit element parameters.
compatibility: Targets Revit 2024-2026.
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# Revit Parameter Manager Skill

Follow these rules for safe, exception-free parameter manipulation.

## Core Rules

1. **Always check `IsReadOnly` before writing:** Writing to a read-only parameter throws an exception.
2. **Handle StorageType:** Match the parameter storage type (`Double`, `Integer`, `String`, `ElementId`).
3. **Internal Units Invariant:** Parameter doubles are stored in **decimal feet**, **radians**, and **square feet**. Always convert user inputs via `UnitUtils.ConvertToInternalUnits()`.
4. **Use `Element.FindParameter()` on Revit 2025+**:
   ```csharp
   #if REVIT2025_OR_GREATER
   Parameter p = element.FindParameter(BuiltInParameter.ALL_MODEL_MARK);
   #else
   Parameter p = element.get_Parameter(BuiltInParameter.ALL_MODEL_MARK);
   #endif
   ```

## Example: Updating Parameter Safely

```csharp
public static bool SetLengthInMillimeters(Element element, BuiltInParameter bip, double valueInMm)
{
    Parameter param = element.get_Parameter(bip);
    if (param == null || param.IsReadOnly) return false;

    double feet = UnitUtils.ConvertToInternalUnits(valueInMm, UnitTypeId.Millimeters);
    return param.Set(feet);
}
```

Reference `examples/ParameterExtensions.cs` for fluent helper methods.
