using System;
using System.Collections.Concurrent;
using System.Threading.Tasks;
using Autodesk.Revit.UI;

namespace BIMFoundation.Core;

/// <summary>
/// Provides thread-safe asynchronous execution of Revit API code from background threads, WPF ViewModels, or web services.
/// </summary>
public static class RevitTask
{
    private static ExternalEvent? _externalEvent;
    private static AsyncExternalEventHandler? _handler;

    /// <summary>
    /// Must be called once on Revit's main thread during IExternalApplication.OnStartup.
    /// </summary>
    public static void Initialize()
    {
        if (_handler != null) return;
        _handler = new AsyncExternalEventHandler();
        _externalEvent = ExternalEvent.Create(_handler);
    }

    /// <summary>
    /// Dispatches a function returning a value to the Revit main thread and awaits its completion.
    /// </summary>
    public static Task<T> RunAsync<T>(Func<UIApplication, T> func)
    {
        if (_externalEvent == null || _handler == null)
            throw new InvalidOperationException("RevitTask must be initialized in App.OnStartup before use.");

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

    /// <summary>
    /// Dispatches an action to the Revit main thread and awaits its completion.
    /// </summary>
    public static Task RunAsync(Action<UIApplication> action)
    {
        return RunAsync<object?>(app =>
        {
            action(app);
            return null;
        });
    }

    private class AsyncExternalEventHandler : IExternalEventHandler
    {
        private readonly ConcurrentQueue<Action<UIApplication>> _queue = new();

        public void Enqueue(Action<UIApplication> action)
        {
            _queue.Enqueue(action);
        }

        public void Execute(UIApplication app)
        {
            while (_queue.TryDequeue(out var action))
            {
                action(app);
            }
        }

        public string GetName() => "RevitTaskAsyncDispatcher";
    }
}
