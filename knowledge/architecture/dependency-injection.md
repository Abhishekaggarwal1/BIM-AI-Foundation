# Dependency Injection in Revit Add-ins
<!-- BIM-AI-Foundation | Architecture Reference -->

## 1. Managing DI Lifecycle inside Revit
Revit plugins run for the lifetime of the Revit process. When using `Microsoft.Extensions.DependencyInjection`, manage the container in `IExternalApplication.OnStartup`:

```csharp
using Microsoft.Extensions.DependencyInjection;
using Autodesk.Revit.UI;

public class App : IExternalApplication
{
    public static IServiceProvider ServiceProvider { get; private set; }

    public Result OnStartup(UIControlledApplication application)
    {
        var services = new ServiceCollection();

        // 1. Register Services
        services.AddSingleton<IModelAuditService, ModelAuditService>();
        services.AddSingleton<IRevitTaskRunner, RevitTaskRunner>();

        // 2. Register ViewModels
        services.AddTransient<MainViewModel>();

        // 3. Register Views
        services.AddTransient<MainDockablePage>();

        ServiceProvider = services.BuildServiceProvider();

        return Result.Succeeded;
    }

    public Result OnShutdown(UIControlledApplication application)
    {
        if (ServiceProvider is IDisposable disposable)
        {
            disposable.Dispose();
        }
        return Result.Succeeded;
    }
}
```
