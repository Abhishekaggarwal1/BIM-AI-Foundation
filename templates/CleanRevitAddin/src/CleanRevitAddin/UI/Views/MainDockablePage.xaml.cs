using System.Windows.Controls;
using Autodesk.Revit.UI;

namespace CleanRevitAddin.UI.Views;

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
