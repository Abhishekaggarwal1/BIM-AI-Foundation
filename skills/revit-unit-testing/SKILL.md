---
name: revit-unit-testing
description: |
  Authoring automated unit tests and integration tests for Revit add-ins using xUnitRevit, Revit.TestRunner, or headless test runners.
  Use whenever user asks to test Revit plugins, write unit tests for Revit API code, setup CI test automation, or mock Revit documents.
compatibility: Revit 2024-2026 / xUnit.net / NUnit.
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# Revit Automated Unit Testing Skill

Testing Revit add-ins requires running inside an active Revit API context or headless Revit instance.

---

## 1. Architectural Strategy: Decoupling via Clean Architecture

The most effective way to test 80% of your plugin code without launching Revit is **Clean Architecture**:
* **Domain Layer:** Pure calculations, algorithms, geometry math, and business rules. Needs **zero Revit API references**; runs in standard `dotnet test` in milliseconds.
* **Infrastructure Layer:** Revit API wrappers. Tested via in-process test runners like **xUnitRevit** or **Revit.TestRunner**.

---

## 2. In-Process Revit Test Template (xUnitRevit)

```csharp
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using Xunit;

namespace BimAddin.Tests
{
    public class WallCollectorTests
    {
        [Fact]
        public void Collector_FindsWallsInActiveView()
        {
            // Context provided by xUnitRevit runner
            UIApplication uiapp = RevitTestContext.UIApplication;
            Document doc = uiapp.ActiveUIDocument.Document;

            var collector = new FilteredElementCollector(doc)
                .OfClass(typeof(Wall))
                .WhereElementIsNotElementType();

            Assert.NotNull(collector);
        }
    }
}
```
