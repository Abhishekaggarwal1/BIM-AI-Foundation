using System;
using System.Windows.Forms;
using Autodesk.Navisworks.Api;
using Autodesk.Navisworks.Api.Plugins;

namespace CleanNavisworksAddin
{
    [Plugin("CleanNavisworksAddin", "BIMAIFOUNDATION", DisplayName = "BIM Clash Auditor", ToolTip = "Audits active Navisworks document and clash tests")]
    [AddInPlugin(AddInLocation.AddIn)]
    public class Plugin : AddInPlugin
    {
        public override int Execute(params string[] parameters)
        {
            Document doc = Autodesk.Navisworks.Api.Application.ActiveDocument;
            if (doc == null)
            {
                MessageBox.Show("No active Navisworks model loaded.", "BIM-AI-Foundation");
                return 0;
            }

            int modelCount = doc.Models.Count;
            int selectionCount = doc.CurrentSelection.SelectedItems.Count;

            MessageBox.Show(
                $"Document Title: {doc.Title}\nAppended Models: {modelCount}\nSelected Items: {selectionCount}",
                "Navisworks Model Audit"
            );

            return 0;
        }
    }
}
