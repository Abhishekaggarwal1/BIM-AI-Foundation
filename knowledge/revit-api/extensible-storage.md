# Extensible Storage in Revit API
<!-- BIM-AI-Foundation | Technical Reference -->

## 1. What is Extensible Storage?
Extensible Storage allows add-in developers to store structured custom data directly inside any Revit `Element` or inside a standalone `DataStorage` element in the `.rvt` project file. Data survives project saves, syncs, and detachment.

---

## 2. Defining and Registering a Schema

Schemas are uniquely identified by a `Guid` and can only be registered once per Revit session:

```csharp
using Autodesk.Revit.DB;
using Autodesk.Revit.DB.ExtensibleStorage;

public static class PluginSchema
{
    public static readonly Guid SchemaGuid = new Guid("98765432-1234-4321-ABCD-1234567890AB");

    public static Schema GetOrCreateSchema()
    {
        Schema existingSchema = Schema.Lookup(SchemaGuid);
        if (existingSchema != null) return existingSchema;

        var builder = new SchemaBuilder(SchemaGuid);
        builder.SetSchemaName("BIMMetadataSchema");
        builder.SetReadAccessLevel(AccessLevel.Public);
        builder.SetWriteAccessLevel(AccessLevel.Public);
        builder.SetVendorId("BIMFoundation");

        // Define Fields:
        builder.AddSimpleField("SyncTimestamp", typeof(string));
        builder.AddSimpleField("StatusScore", typeof(int));
        builder.AddSimpleField("AuditPassed", typeof(bool));

        return builder.Finish();
    }
}
```

---

## 3. Writing and Reading Data from an Element

```csharp
// Writing Entity to Element (must be inside an open Transaction):
public static void SaveMetadata(Element element, string timestamp, int score, bool passed)
{
    Schema schema = PluginSchema.GetOrCreateSchema();
    Entity entity = new Entity(schema);

    entity.Set("SyncTimestamp", timestamp);
    entity.Set("StatusScore", score);
    entity.Set("AuditPassed", passed);

    element.SetEntity(entity);
}

// Reading Entity from Element:
public static (string timestamp, int score, bool passed) ReadMetadata(Element element)
{
    Schema schema = PluginSchema.GetOrCreateSchema();
    Entity entity = element.GetEntity(schema);

    if (!entity.IsValid()) return (null, 0, false);

    string ts = entity.Get<string>("SyncTimestamp");
    int score = entity.Get<int>("StatusScore");
    bool passed = entity.Get<bool>("AuditPassed");

    return (ts, score, passed);
}
```
