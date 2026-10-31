# MVVM Pattern in Revit with CommunityToolkit.Mvvm
<!-- BIM-AI-Foundation | Architecture Reference -->

## 1. Why CommunityToolkit.Mvvm?
`CommunityToolkit.Mvvm` provides ultra-fast, modern C# source generators (`[ObservableProperty]`, `[RelayCommand]`) with zero boilerplate and full compatibility across .NET Framework 4.8 and .NET 8.0.

---

## 2. Standard ViewModel Implementation

```csharp
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using System.Collections.ObjectModel;
using System.Threading.Tasks;

public partial class MainViewModel : ObservableObject
{
    [ObservableProperty]
    private string _statusMessage = "Ready";

    [ObservableProperty]
    private bool _isBusy;

    public ObservableCollection<string> AuditResults { get; } = new();

    [RelayCommand]
    private async Task RunAuditAsync()
    {
        IsBusy = true;
        StatusMessage = "Analyzing model...";
        AuditResults.Clear();

        // Safe execution inside Revit on main thread:
        await RevitTask.RunAsync(app =>
        {
            var doc = app.ActiveUIDocument.Document;
            var collector = new FilteredElementCollector(doc)
                .OfClass(typeof(Wall))
                .WhereElementIsNotElementType();

            foreach (Wall wall in collector)
            {
                if (wall.LookupParameter("Fire Rating") == null)
                {
                    AuditResults.Add($"Wall {wall.Id.Value} missing Fire Rating parameter");
                }
            }
        });

        StatusMessage = $"Audit complete. Found {AuditResults.Count} issues.";
        IsBusy = false;
    }
}
```

---

## 3. Window Parenting & Theme Synchronization

Modeless WPF windows must be parented to Revit's main window handle to prevent them from slipping behind Revit when clicked:

```csharp
var window = new MainWindow();
var helper = new System.Windows.Interop.WindowInteropHelper(window)
{
    Owner = Autodesk.Windows.ComponentManager.ApplicationWindow
};
window.Show();
```
