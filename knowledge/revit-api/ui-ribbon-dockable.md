# Ribbon UI & Dockable Panels in Revit API
<!-- BIM-AI-Foundation | Technical Reference -->

## 1. Creating Ribbon Tabs and Buttons

Ribbon components are registered inside `IExternalApplication.OnStartup`:

```csharp
using Autodesk.Revit.UI;
using System.Reflection;
using System.Windows.Media.Imaging;

public class App : IExternalApplication
{
    public Result OnStartup(UIControlledApplication application)
    {
        string tabName = "BIM Tools";
        
        // 1. Create or access Ribbon Tab:
        try { application.CreateRibbonTab(tabName); } catch { /* Tab may already exist */ }

        // 2. Create Panel:
        RibbonPanel panel = application.CreateRibbonPanel(tabName, "Automation");

        // 3. Define Button Data:
        string assemblyPath = Assembly.GetExecutingAssembly().Location;
        var buttonData = new PushButtonData(
            "cmdRunAudit",
            "Model Audit",
            assemblyPath,
            "CleanRevitAddin.Commands.AuditCommand"
        )
        {
            ToolTip = "Performs QA/QC audit on model elements",
            LargeImage = new BitmapImage(new Uri("pack://application:,,,/CleanRevitAddin;component/Resources/Icons/Audit32.png")),
            Image = new BitmapImage(new Uri("pack://application:,,,/CleanRevitAddin;component/Resources/Icons/Audit16.png"))
        };

        // 4. Add to Panel:
        panel.AddItem(buttonData);

        return Result.Succeeded;
    }

    public Result OnShutdown(UIControlledApplication application) => Result.Succeeded;
}
```

---

## 2. Registering a Dockable Pane (Palette)

Dockable Panes can be docked alongside the Properties or Project Browser windows in Revit.

### Step 1: Implement `IDockablePaneProvider` in a WPF Page:
```csharp
using Autodesk.Revit.UI;
using System.Windows.Controls;

public partial class MainDockablePage : Page, IDockablePaneProvider
{
    public MainDockablePage()
    {
        InitializeComponent();
    }

    public void SetupDockablePane(DockablePaneProviderData data)
    {
        data.FrameworkElement = this;
        data.InitialState = new DockablePaneState
        {
            DockPosition = DockPosition.Right,
            TabBehind = DockablePanes.BuiltInDockablePanes.ProjectBrowser
        };
    }
}
```

### Step 2: Register in `OnStartup`:
```csharp
public static readonly DockablePaneId PaneId = new DockablePaneId(new Guid("A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D"));

public Result OnStartup(UIControlledApplication application)
{
    var page = new MainDockablePage();
    application.RegisterDockablePane(PaneId, "BIM Foundation Panel", page);
    return Result.Succeeded;
}
```

### Step 3: Show/Hide Command:
```csharp
[Transaction(TransactionMode.Manual)]
public class ShowPaneCommand : IExternalCommand
{
    public Result Execute(ExternalCommandData commandData, ref string message, ElementSet elements)
    {
        DockablePane pane = commandData.Application.GetDockablePane(App.PaneId);
        pane.Show();
        return Result.Succeeded;
    }
}
```
