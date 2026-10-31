using System.Collections.Generic;
using System.Linq;
using Autodesk.Revit.DB;
using Autodesk.Revit.DB.Architecture;

namespace BIMFoundation.Core;

public record ValidationIssue(long ElementId, string Category, string Description);

public static class ModelValidator
{
    public static List<ValidationIssue> AuditModelHealth(Document doc)
    {
        var issues = new List<ValidationIssue>();

        // 1. Audit Unplaced/Unbounded Rooms:
        var rooms = new FilteredElementCollector(doc)
            .OfCategory(BuiltInCategory.OST_Rooms)
            .WhereElementIsNotElementType()
            .Cast<Room>();

        foreach (var room in rooms)
        {
            if (room.Location == null || room.Area < 1e-4)
            {
                issues.Add(new ValidationIssue(room.Id.Value, "Rooms", $"Room '{room.Number}' is unplaced or unclosed."));
            }
        }

        // 2. Audit Doors with missing Marks:
        var doors = new FilteredElementCollector(doc)
            .OfCategory(BuiltInCategory.OST_Doors)
            .WhereElementIsNotElementType();

        foreach (var door in doors)
        {
            string? mark = door.get_Parameter(BuiltInParameter.ALL_MODEL_MARK)?.AsString();
            if (string.IsNullOrWhiteSpace(mark))
            {
                issues.Add(new ValidationIssue(door.Id.Value, "Doors", "Door is missing Mark parameter value."));
            }
        }

        return issues;
    }
}
