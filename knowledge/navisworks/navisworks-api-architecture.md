# Navisworks API Architecture & Best Practices
<!-- BIM-AI-Foundation | Technical Reference -->

The Autodesk Navisworks .NET API allows developers to automate multi-model coordination, clash resolution, viewpoints, and custom DockPane palettes.

---

## 1. Document Model & Selection Tree

```text
Autodesk.Navisworks.Api.Application
 └── ActiveDocument
      ├── Models (Native NWD/NWC, DWG, RVT appended models)
      ├── CurrentSelection (User selected ModelItem collection)
      ├── SavedViewpoints (Camera positions, animations, cut planes)
      └── SelectionSets (Saved searches and explicit selections)
```

### ModelItem Hierarchy
Navisworks models are structured as hierarchical trees:
* **Root Items:** Model boundaries / appended files.
* **Composite Items:** Groups, families, or assemblies.
* **Geometry Items:** Primitive geometry containing triangles, vertices, and materials.
* To get category/properties:
  ```csharp
  PropertyCategory category = item.PropertyCategories.FindCategoryByName(PropertyCategoryNames.Element);
  DataProperty prop = category.Properties.FindPropertyByName(DataPropertyNames.ElementId);
  ```

---

## 2. Clash Detective API (`Autodesk.Navisworks.Api.Clash`)

Automating clash results is one of the highest-value workflows in AEC coordination:

```csharp
DocumentClash docClash = DocumentClash.GetClash(doc);
ClashTest test = docClash.TestsData.Tests[0] as ClashTest;

// Batch update status of resolved clashes:
using (Transaction tr = doc.BeginTransaction("Group Clashes"))
{
    foreach (SavedItem child in test.Children)
    {
        if (child is ClashResult result && result.Status == ClashResultStatus.New)
        {
            // Update comments or group
        }
    }
}
```

---

## 3. Deployment & Plugin Autoloader

Deploying Navisworks add-ins uses the Autodesk Autoloader mechanism:
* Place plugin DLLs in:
  `%APPDATA%\Autodesk\Navisworks Manage 202X\Plugins\<PluginName>\<PluginName>.dll`
* Or deploy a `.bundle` package containing `PackageContents.xml` into:
  `%APPDATA%\Autodesk\ApplicationPlugins\`
