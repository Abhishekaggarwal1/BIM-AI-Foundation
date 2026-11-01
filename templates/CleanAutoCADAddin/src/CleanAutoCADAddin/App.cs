using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.Runtime;

[assembly: ExtensionApplication(typeof(CleanAutoCADAddin.App))]

namespace CleanAutoCADAddin
{
    public class App : IExtensionApplication
    {
        public void Initialize()
        {
            var doc = Application.DocumentManager.MdiActiveDocument;
            doc?.Editor.WriteMessage("\n[BIM-AI-Foundation] CleanAutoCADAddin initialized successfully!\n");
        }

        public void Terminate()
        {
            // Clean up resources if necessary
        }
    }
}
