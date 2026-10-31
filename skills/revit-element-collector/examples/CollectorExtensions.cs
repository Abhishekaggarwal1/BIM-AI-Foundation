using System.Collections.Generic;
using System.Linq;
using Autodesk.Revit.DB;

namespace BIMFoundation.Core.Extensions;

public static class CollectorExtensions
{
    public static IEnumerable<T> GetInstances<T>(this Document doc, BuiltInCategory category) where T : Element
    {
        return new FilteredElementCollector(doc)
            .OfClass(typeof(T))
            .OfCategory(category)
            .WhereElementIsNotElementType()
            .Cast<T>();
    }

    public static IEnumerable<T> GetTypes<T>(this Document doc) where T : ElementType
    {
        return new FilteredElementCollector(doc)
            .OfClass(typeof(T))
            .WhereElementIsElementType()
            .Cast<T>();
    }

    public static IEnumerable<Element> GetInView(this Document doc, ElementId viewId)
    {
        return new FilteredElementCollector(doc, viewId)
            .WhereElementIsNotElementType();
    }
}
