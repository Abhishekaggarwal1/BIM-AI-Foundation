using System;
using System.Reflection;
using Autodesk.Revit.UI;
using CleanRevitAddin.Core;
using CleanRevitAddin.UI.Views;

namespace CleanRevitAddin;

public class App : IExternalApplication
{
    public static readonly DockablePaneId DockablePaneId = new(new Guid("8F3E5A2B-7D1C-4E9A-B0F2-6C8E4A1D9B3C"));

    public Result OnStartup(UIControlledApplication application)
    {
        // 1. Initialize thread-safe async dispatcher
        RevitTask.Initialize();

        // 2. Register Dockable Pane
        var dockablePage = new MainDockablePage();
        application.RegisterDockablePane(DockablePaneId, "BIM Foundation Panel", dockablePage);

        // 3. Build Ribbon UI
        string tabName = "BIM Tools";
        try { application.CreateRibbonTab(tabName); } catch { /* Ignore if exists */ }

        RibbonPanel panel = application.CreateRibbonPanel(tabName, "General");
        string location = Assembly.GetExecutingAssembly().Location;

        var cmdSample = new PushButtonData(
            "cmdSample",
            "Sample\nCommand",
            location,
            "CleanRevitAddin.Commands.SampleCommand"
        )
        {
            ToolTip = "Executes sample safe transaction with failure handling"
        };

        var cmdShowPane = new PushButtonData(
            "cmdShowPane",
            "Show\nPanel",
            location,
            "CleanRevitAddin.Commands.ShowDockablePaneCommand"
        )
        {
            ToolTip = "Displays the BIM Foundation Dockable Panel"
        };

        panel.AddItem(cmdSample);
        panel.AddItem(cmdShowPane);

        return Result.Succeeded;
    }

    public Result OnShutdown(UIControlledApplication application)
    {
        return Result.Succeeded;
    }
}
