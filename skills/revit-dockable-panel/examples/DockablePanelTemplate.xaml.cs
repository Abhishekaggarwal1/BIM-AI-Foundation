using System.Windows.Controls;
using Autodesk.Revit.UI;

namespace BIMFoundation.UI.Views;

public partial class DockablePanelTemplate : Page, IDockablePaneProvider
{
    public DockablePanelTemplate()
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
