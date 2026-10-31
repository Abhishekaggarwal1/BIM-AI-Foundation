---
name: revit-failure-handler
description: |
  Suppressing warning dialogs, handling transaction failures, and implementing IFailuresPreprocessor.
  Use whenever user asks to suppress Revit warnings, prevent modal popups during batch actions, or handle errors gracefully.
compatibility: Targets Revit 2024-2026.
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# Revit Failure Handler Skill

Revit automatically pops up modal warning dialogs (e.g. "Highlighted walls overlap") that will freeze automated routines unless intercepted.

## Suppressing Warnings on a Transaction:

```csharp
using (var transaction = new Transaction(document, "Batch Operation"))
{
    FailureHandlingOptions options = transaction.GetFailureHandlingOptions();
    options.SetFailuresPreprocessor(new WarningSwallower());
    options.SetClearAfterRollback(true);
    transaction.SetFailureHandlingOptions(options);

    transaction.Start();
    // Batch operations...
    transaction.Commit();
}
```

Reference `examples/WarningSwallower.cs` for the full preprocessor implementation.
