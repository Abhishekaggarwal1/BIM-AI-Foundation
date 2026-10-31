using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;

namespace CleanRevitAddin.Commands;

[Transaction(TransactionMode.Manual)]
public class ShowDockablePaneCommand : IExternalCommand
{
    public Result Execute(ExternalCommandData commandData, ref string message, ElementSet elements)
    {
        DockablePane pane = commandData.Application.GetDockablePane(App.DockablePaneId);
        pane.Show();
        return Result.Succeeded;
    }
}
