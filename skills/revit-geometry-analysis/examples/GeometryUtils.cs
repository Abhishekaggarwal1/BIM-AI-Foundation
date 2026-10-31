using System.Collections.Generic;
using Autodesk.Revit.DB;

namespace BIMFoundation.Core.Utils;

public static class GeometryUtils
{
    public static List<Solid> ExtractSolids(GeometryElement? geomElement)
    {
        var solids = new List<Solid>();
        if (geomElement == null) return solids;

        foreach (GeometryObject obj in geomElement)
        {
            if (obj is Solid solid && solid.Volume > 1e-6)
            {
                solids.Add(solid);
            }
            else if (obj is GeometryInstance instance)
            {
                GeometryElement? instGeom = instance.GetInstanceGeometry();
                if (instGeom != null)
                {
                    solids.AddRange(ExtractSolids(instGeom));
                }
            }
        }

        return solids;
    }

    public static Solid? Intersect(Solid solidA, Solid solidB)
    {
        try
        {
            return BooleanOperationsUtils.ExecuteBooleanOperation(
                solidA, 
                solidB, 
                BooleanOperationsType.Intersect
            );
        }
        catch
        {
            return null;
        }
    }
}
