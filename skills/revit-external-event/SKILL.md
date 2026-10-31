---
name: revit-external-event
description: |
  Implements thread-safe asynchronous operations and WPF-to-Revit dispatching via ExternalEvent and TaskCompletionSource.
  Use whenever user requests background processing, web API calls, asynchronous UI updates, or modeless WPF interactions in Revit.
compatibility: All Revit versions (2024-2026).
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# Revit ExternalEvent & Async Dispatching Skill

The Revit API does NOT allow out-of-thread access. To make async/await calls from WPF windows, web services, or background tasks, you must dispatch execution back to Revit's main thread via `ExternalEvent`.

## The `RevitTask` Pattern

Include `RevitTask.cs` (located in `examples/RevitTask.cs`) in your add-in.

### 1. Initialization in `App.OnStartup`:
```csharp
public Result OnStartup(UIControlledApplication application)
{
    RevitTask.Initialize();
    return Result.Succeeded;
}
```

### 2. Executing Asynchronous Tasks from ViewModels or Background Threads:
```csharp
// Simple Action:
await RevitTask.RunAsync(app =>
{
    var doc = app.ActiveUIDocument.Document;
    using (var t = new Transaction(doc, "Async Update"))
    {
        t.Start();
        // Modify elements safely
        t.Commit();
    }
});

// Returning a value:
List<string> wallNames = await RevitTask.RunAsync(app =>
{
    var doc = app.ActiveUIDocument.Document;
    return new FilteredElementCollector(doc)
        .OfClass(typeof(Wall))
        .WhereElementIsNotElementType()
        .Select(w => w.Name)
        .ToList();
});
```
