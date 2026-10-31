using Autodesk.Revit.DB;

namespace CleanRevitAddin.Core;

public class WarningSwallower : IFailuresPreprocessor
{
    public FailureProcessingResult PreprocessFailures(FailuresAccessor failuresAccessor)
    {
        var messages = failuresAccessor.GetFailureMessages();

        foreach (var message in messages)
        {
            FailureSeverity severity = message.GetSeverity();

            if (severity == FailureSeverity.Warning)
            {
                failuresAccessor.DeleteWarning(message);
            }
            else if (severity == FailureSeverity.Error)
            {
                return FailureProcessingResult.ProceedWithRollBack;
            }
        }

        return FailureProcessingResult.Continue;
    }
}
