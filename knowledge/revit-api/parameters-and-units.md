# Parameters & Units in Revit API
<!-- BIM-AI-Foundation | Technical Reference -->

## 1. StorageTypes & Safe Value Access

Revit parameters store data in one of four underlying `StorageType` values:

| StorageType | Getter Method | Setter Method | Example Data |
| :--- | :--- | :--- | :--- |
| **`Double`** | `param.AsDouble()` | `param.Set(doubleVal)` | Length, Area, Volume, Angle |
| **`Integer`** | `param.AsInteger()` | `param.Set(intVal)` | Yes/No booleans (0 or 1), Counts, Phase IDs |
| **`String`** | `param.AsString()` | `param.Set(stringVal)` | Comments, Mark, Description |
| **`ElementId`**| `param.AsElementId()` | `param.Set(elementId)` | Material ID, Level ID, Type ID |

### Safe Parameter Read Extension
```csharp
public static object GetParameterValue(Parameter parameter)
{
    if (parameter == null || !parameter.HasValue) return null;

    switch (parameter.StorageType)
    {
        case StorageType.Double:
            return parameter.AsDouble();
        case StorageType.Integer:
            return parameter.AsInteger();
        case StorageType.String:
            return parameter.AsString();
        case StorageType.ElementId:
            return parameter.AsElementId();
        default:
            return parameter.AsValueString();
    }
}
```

---

## 2. Safe Parameter Write
Never write to a parameter without checking `IsReadOnly`:

```csharp
public static bool SetParameterSafe(Parameter parameter, string value)
{
    if (parameter == null || parameter.IsReadOnly) return false;
    return parameter.Set(value);
}

public static bool SetParameterSafe(Parameter parameter, double valueInInternalUnits)
{
    if (parameter == null || parameter.IsReadOnly) return false;
    return parameter.Set(valueInInternalUnits);
}
```

---

## 3. The Internal Units Invariant

Revit **always** measures and stores geometric values internally in standard imperial units, regardless of UI project units:
* **Length:** Decimal Feet ($1\text{ ft} = 0.3048\text{ m} = 304.8\text{ mm}$)
* **Angle:** Radians ($180^\circ = \pi\text{ rad}$)
* **Area:** Square Feet
* **Volume:** Cubic Feet

### Converting Units with `UnitUtils` & `ForgeTypeId`
Modern Revit uses `ForgeTypeId` constants located in `UnitTypeId`:

```csharp
using Autodesk.Revit.DB;

// Convert 2500 mm into Revit internal units (decimal feet):
double lengthInMm = 2500.0;
double internalFeet = UnitUtils.ConvertToInternalUnits(lengthInMm, UnitTypeId.Millimeters);

// Convert Revit internal units (decimal feet) back to Millimeters for display:
double displayMm = UnitUtils.ConvertFromInternalUnits(internalFeet, UnitTypeId.Millimeters);

// Converting Square Meters to Square Feet:
double areaInSqMeters = 50.0;
double internalSqFeet = UnitUtils.ConvertToInternalUnits(areaInSqMeters, UnitTypeId.SquareMeters);
```

---

## 4. Parameter Retrieval Hierarchy

When querying parameters on an `Element`:

1. **BuiltInParameter (Highest Speed & Language-Independent):**
   ```csharp
   #if REVIT2025_OR_GREATER
   Parameter p = element.FindParameter(BuiltInParameter.ALL_MODEL_MARK);
   #else
   Parameter p = element.get_Parameter(BuiltInParameter.ALL_MODEL_MARK);
   #endif
   ```
2. **LookupParameter (String Name Lookups):**
   ```csharp
   // Note: String lookups are case-sensitive and language-dependent
   Parameter p = element.LookupParameter("Comments");
   ```
3. **Shared Parameter GUID:**
   ```csharp
   Guid sharedParamGuid = new Guid("12345678-1234-1234-1234-123456789abc");
   Parameter p = element.get_Parameter(sharedParamGuid);
   ```
