using System;
using System.Collections.Concurrent;
using System.Threading.Tasks;
using Autodesk.Revit.UI;

namespace CleanRevitAddin.Core;

public static class RevitTask
{
    private static ExternalEvent? _externalEvent;
    private static AsyncExternalEventHandler? _handler;

    public static void Initialize()
    {
        if (_handler != null) return;
        _handler = new AsyncExternalEventHandler();
        _externalEvent = ExternalEvent.Create(_handler);
    }

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

        public void Enqueue(Action<UIApplication> action) => _queue.Enqueue(action);

        public void Execute(UIApplication app)
        {
            while (_queue.TryDequeue(out var action))
            {
                action(app);
            }
        }

        public string GetName() => "CleanRevitAddinAsyncDispatcher";
    }
}
