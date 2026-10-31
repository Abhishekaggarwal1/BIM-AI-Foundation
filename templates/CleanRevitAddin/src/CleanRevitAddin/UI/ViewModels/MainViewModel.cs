using System.Collections.ObjectModel;
using System.Threading.Tasks;
using Autodesk.Revit.DB;
using CleanRevitAddin.Core;
using CleanRevitAddin.Core.Extensions;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;

namespace CleanRevitAddin.UI.ViewModels;

public partial class MainViewModel : ObservableObject
{
    [ObservableProperty]
    [NotifyPropertyChangedFor(nameof(IsNotBusy))]
    private bool _isBusy;

    public bool IsNotBusy => !IsBusy;

    [ObservableProperty]
    private string _statusMessage = "Ready";

    public ObservableCollection<string> LogEntries { get; } = new();

    [RelayCommand]
    private async Task ExecuteSampleActionAsync()
    {
        IsBusy = true;
        StatusMessage = "Processing in Revit...";
        LogEntries.Add("Dispatching task to Revit STA thread...");

        await RevitTask.RunAsync(app =>
        {
            Document doc = app.ActiveUIDocument.Document;
            var walls = doc.GetInstances<Wall>(BuiltInCategory.OST_Walls);

            int count = 0;
            foreach (var wall in walls)
            {
                count++;
            }

            LogEntries.Add($"Found {count} walls in active document.");
        });

        StatusMessage = "Task completed successfully.";
        IsBusy = false;
    }
}
