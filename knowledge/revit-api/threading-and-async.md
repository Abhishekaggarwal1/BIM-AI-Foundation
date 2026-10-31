# Threading & Asynchronous Patterns in Autodesk Revit
<!-- BIM-AI-Foundation | Technical Reference -->

## 1. The Core Threading Invariant
The Autodesk Revit API runs inside a **Single-Threaded Apartment (STA)** on the main Windows UI thread. 
* **Rule:** You may ONLY interact with Revit API objects (such as `Document`, `Element`, `FilteredElementCollector`, `Transaction`) while executing on this main thread within an official Revit API callback.
* **Failure Mode:** Calling any Revit API method from a worker thread, a `Task.Run()` block, a timer, or an asynchronous HTTP response will throw an `Autodesk.Revit.Exceptions.InvalidOperationException` or trigger an unrecoverable hard crash (`AccessViolationException`).

---

## 2. The Solution: `IExternalEventHandler` & `ExternalEvent`

To perform long-running background tasks (e.g., fetching data from an external REST API, running a heavy AI model inference, reading an Excel sheet) without freezing the Revit UI, use `ExternalEvent`:

```
┌────────────────────────────────────────┐
│ Worker / UI Thread (Async, Background) │
│ - Fetches web API, heavy calculation   │
└───────────────────┬────────────────────┘
                    │
                    │ 1. Passes payload to handler
                    │ 2. Calls externalEvent.Raise()
                    ▼
┌────────────────────────────────────────┐
│ Revit Main UI Thread (STA)             │
│ - Revit enters idle state              │
│ - Calls IExternalEventHandler.Execute  │
│ - Safe to run Transactions & API calls │
└────────────────────────────────────────┘
```

### Implementing `IExternalEventHandler`

```csharp
using Autodesk.Revit.UI;

public class SimpleRevitHandler : IExternalEventHandler
{
    private Action<UIApplication> _action;

    public void SetAction(Action<UIApplication> action)
    {
        _action = action;
    }

    public void Execute(UIApplication app)
    {
        if (_action == null) return;

        try
        {
            _action(app);
        }
        catch (Exception ex)
        {
            TaskDialog.Show("Handler Error", ex.Message);
        }
        finally
        {
            _action = null;
        }
    }

    public string GetName() => "SimpleRevitHandler";
}
```

---

## 3. Production Pattern: `RevitTask` (TaskCompletionSource Dispatcher)

A clean modern pattern converts `ExternalEvent` into an `async`/`await` compatible `Task<T>`:

```csharp
public static class RevitTask
{
    private static ExternalEvent _externalEvent;
    private static AsyncExternalEventHandler _handler;

    public static void Initialize()
    {
        _handler = new AsyncExternalEventHandler();
        _externalEvent = ExternalEvent.Create(_handler);
    }

    public static Task<T> RunAsync<T>(Func<UIApplication, T> func)
    {
        var tcs = new TaskCompletionSource<T>();
        _handler.Enqueue(app =>
        {
            try
            {
                var result = func(app);
                tcs.SetResult(result);
            }
            catch (Exception ex)
            {
                tcs.SetException(ex);
            }
        });
        _externalEvent.Raise();
        return tcs.Task;
    }

    public static Task RunAsync(Action<UIApplication> action)
    {
        return RunAsync<object>(app =>
        {
            action(app);
            return null;
        });
    }
}
```

### Usage in Modeless WPF / Async ViewModel:
```csharp
[RelayCommand]
public async Task UpdateElementsAsync()
{
    IsBusy = true;

    // 1. Fetch remote data asynchronously (on thread pool)
    var externalData = await _apiClient.FetchDataAsync();

    // 2. Safely apply changes inside Revit on main thread
    await RevitTask.RunAsync(app =>
    {
        var doc = app.ActiveUIDocument.Document;
        using (var t = new Transaction(doc, "Batch Update"))
        {
            t.Start();
            // Modify Revit elements safely
            t.Commit();
        }
    });

    IsBusy = false;
}
```

See `skills/revit-external-event/SKILL.md` for a complete, tested implementation.
