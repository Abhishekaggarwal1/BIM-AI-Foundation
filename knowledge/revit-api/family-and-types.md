# Families & Types in Revit API
<!-- BIM-AI-Foundation | Technical Reference -->

## 1. Family Hierarchy

```
Family (e.g., "Single-Flush Door")
  │
  ├── FamilySymbol (Type: e.g., "36" x 84"")
  │     ├── Type Parameters (shared across all instances of this type)
  │     │
  │     └── FamilyInstance (Physical placement in project)
  │           └── Instance Parameters (unique to this specific placement)
```

---

## 2. The Critical Symbol Activation Rule

Before placing an instance of any `FamilySymbol`, you **MUST** ensure the symbol is active. Placing an inactive symbol throws an exception:

```csharp
using Autodesk.Revit.DB;
using Autodesk.Revit.DB.Structure;

public static FamilyInstance PlaceFamilySymbol(
    Document doc, 
    FamilySymbol symbol, 
    XYZ location, 
    Level level)
{
    // Check and activate symbol:
    if (!symbol.IsActive)
    {
        symbol.Activate();
        doc.Regenerate(); // Required after activating symbol
    }

    return doc.Create.NewFamilyInstance(
        location,
        symbol,
        level,
        StructuralType.NonStructural
    );
}
```

---

## 3. Loading Families with `IFamilyLoadOptions`

When loading a `.rfa` family file into a project where the family may already exist:

```csharp
public class OverwriteFamilyLoadOptions : IFamilyLoadOptions
{
    public bool OnFamilyFound(bool familyInUse, out bool overwriteParameterValues)
    {
        // Set true to overwrite existing parameter values with family definitions
        overwriteParameterValues = true;
        return true; // Overwrite the family
    }

    public bool OnSharedFamilyFound(
        Family sharedFamily, 
        bool familyInUse, 
        out FamilySource source, 
        out bool overwriteParameterValues)
    {
        source = FamilySource.Family;
        overwriteParameterValues = true;
        return true;
    }
}
```

### Loading the Family:
```csharp
string familyPath = @"C:\Families\CustomDoor.rfa";
Family loadedFamily;

bool success = document.LoadFamily(
    familyPath, 
    new OverwriteFamilyLoadOptions(), 
    out loadedFamily
);
```
