# Transactions, Failures & Warnings in Revit API
<!-- BIM-AI-Foundation | Technical Reference -->

## 1. Transaction Types & Lifecycle

Revit provides three transaction-related constructs:

| Type | Purpose | Nesting Rules |
| :--- | :--- | :--- |
| **`Transaction`** | Modifies the document database. Created with `new Transaction(doc, "Name")`. | **Cannot be nested.** Only one active transaction per document. |
| **`SubTransaction`** | Smaller atomic unit within an open `Transaction`. | Can only exist **inside an open Transaction**. Useful in complex loops. |
| **`TransactionGroup`** | Groups multiple consecutive Transactions together into a single user Undo step using `Assimilate()`. | Can contain multiple Transactions. |

---

## 2. Safe Transaction Pattern

```csharp
using Autodesk.Revit.DB;

public void ExecuteSafeModification(Document document)
{
    using (var transaction = new Transaction(document, "Update Wall Parameters"))
    {
        try
        {
            transaction.Start();

            // Perform Revit database modifications here...
            
            // Call document.Regenerate() ONLY if subsequent code depends on updated geometry/relations:
            document.Regenerate();

            TransactionStatus status = transaction.Commit();
            if (status != TransactionStatus.Committed)
            {
                // Transaction was rolled back or aborted by Revit failure handling
            }
        }
        catch (Exception ex)
        {
            if (transaction.HasStarted() && !transaction.HasEnded())
            {
                transaction.RollBack();
            }
            throw;
        }
    }
}
```

---

## 3. TransactionGroup with `Assimilate()`
When performing a batch operation (e.g., creating 500 rooms across 10 levels), you do not want 500 undo steps in Revit’s Undo menu:

```csharp
using (var group = new TransactionGroup(document, "Batch Create Rooms"))
{
    group.Start();

    for (int i = 0; i < 10; i++)
    {
        using (var t = new Transaction(document, $"Create Room Batch {i}"))
        {
            t.Start();
            // Create batch
            t.Commit();
        }
    }

    // Merges all internal transactions into a single Undo entry in Revit:
    group.Assimilate();
}
```

---

## 4. Handling Warnings & Failures (`IFailuresPreprocessor`)

During automated modifications (e.g., joining walls, deleting overlapping elements), Revit often raises modal warning popups (e.g., *"Highlighted walls overlap"*). If not handled programmatically, these popups halt automated batch runs and demand user clicks.

### Implementing a Warning Suppressor:
```csharp
using Autodesk.Revit.DB;

public class WarningSwallower : IFailuresPreprocessor
{
    public FailureProcessingResult PreprocessFailures(FailuresAccessor failuresAccessor)
    {
        var failureMessages = failuresAccessor.GetFailureMessages();

        foreach (var message in failureMessages)
        {
            FailureSeverity severity = message.GetSeverity();

            if (severity == FailureSeverity.Warning)
            {
                // Delete warning so no dialog appears to the user
                failuresAccessor.DeleteWarning(message);
            }
            else if (severity == FailureSeverity.Error)
            {
                // Unresolvable error: abort transaction
                return FailureProcessingResult.ProceedWithRollBack;
            }
        }

        return FailureProcessingResult.Continue;
    }
}
```

### Attaching to a Transaction:
```csharp
using (var t = new Transaction(document, "Automated Generation"))
{
    FailureHandlingOptions options = t.GetFailureHandlingOptions();
    options.SetFailuresPreprocessor(new WarningSwallower());
    options.SetClearAfterRollback(true);
    t.SetFailureHandlingOptions(options);

    t.Start();
    // Batch operations...
    t.Commit();
}
```
