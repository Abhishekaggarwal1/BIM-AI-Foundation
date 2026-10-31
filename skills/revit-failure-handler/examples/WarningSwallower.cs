using Autodesk.Revit.DB;

namespace BIMFoundation.Core;

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
                // Delete warning so no modal dialog appears:
                failuresAccessor.DeleteWarning(message);
            }
            else if (severity == FailureSeverity.Error)
            {
                // Critical unresolvable error: rollback transaction
                return FailureProcessingResult.ProceedWithRollBack;
            }
        }

        return FailureProcessingResult.Continue;
    }
}
