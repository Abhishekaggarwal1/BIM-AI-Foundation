using Autodesk.Revit.DB;

namespace BIMFoundation.Core.Extensions;

public static class ParameterExtensions
{
    public static string? GetString(this Element element, BuiltInParameter bip)
    {
        Parameter? param = element.get_Parameter(bip);
        return (param != null && param.HasValue) ? param.AsString() : null;
    }

    public static string? GetString(this Element element, string parameterName)
    {
        Parameter? param = element.LookupParameter(parameterName);
        return (param != null && param.HasValue) ? param.AsString() : null;
    }

    public static double? GetLengthMm(this Element element, BuiltInParameter bip)
    {
        Parameter? param = element.get_Parameter(bip);
        if (param == null || !param.HasValue) return null;
        return UnitUtils.ConvertFromInternalUnits(param.AsDouble(), UnitTypeId.Millimeters);
    }

    public static bool SetString(this Element element, BuiltInParameter bip, string value)
    {
        Parameter? param = element.get_Parameter(bip);
        if (param == null || param.IsReadOnly) return false;
        return param.Set(value);
    }

    public static bool SetString(this Element element, string parameterName, string value)
    {
        Parameter? param = element.LookupParameter(parameterName);
        if (param == null || param.IsReadOnly) return false;
        return param.Set(value);
    }

    public static bool SetLengthMm(this Element element, BuiltInParameter bip, double valueInMm)
    {
        Parameter? param = element.get_Parameter(bip);
        if (param == null || param.IsReadOnly) return false;
        double internalFeet = UnitUtils.ConvertToInternalUnits(valueInMm, UnitTypeId.Millimeters);
        return param.Set(internalFeet);
    }
}
