using System;
using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using CleanRevitAddin.Core;

namespace CleanRevitAddin.Commands;

[Transaction(TransactionMode.Manual)]
[Regeneration(RegenerationOption.Manual)]
public class SampleCommand : IExternalCommand
{
    public Result Execute(ExternalCommandData commandData, ref string message, ElementSet elements)
    {
        UIDocument uiDoc = commandData.Application.ActiveUIDocument;
        Document doc = uiDoc.Document;

        try
        {
            using (var transaction = new Transaction(doc, "BIM Foundation Sample Modification"))
            {
                // Attach failure preprocessor to suppress popup warnings
                var failureOptions = transaction.GetFailureHandlingOptions();
                failureOptions.SetFailuresPreprocessor(new WarningSwallower());
                failureOptions.SetClearAfterRollback(true);
                transaction.SetFailureHandlingOptions(failureOptions);

                transaction.Start();

                // Example read-write: audit project info
                ProjectInfo info = doc.ProjectInformation;
                Parameter statusParam = info.get_Parameter(BuiltInParameter.PROJECT_STATUS);
                if (statusParam != null && !statusParam.IsReadOnly)
                {
                    statusParam.Set("Audited by BIM-AI-Foundation");
                }

                transaction.Commit();
            }

            TaskDialog.Show("Success", "Sample command executed successfully with failure handling!");
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            message = ex.Message;
            return Result.Failed;
        }
    }
}
