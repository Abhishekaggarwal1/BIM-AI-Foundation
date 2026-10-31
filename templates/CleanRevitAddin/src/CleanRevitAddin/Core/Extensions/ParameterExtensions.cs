using Autodesk.Revit.DB;

namespace CleanRevitAddin.Core.Extensions;

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

    public static bool SetString(this Element element, BuiltInParameter bip, string value)
    {
        Parameter? param = element.get_Parameter(bip);
        if (param == null || param.IsReadOnly) return false;
        return param.Set(value);
    }
}
