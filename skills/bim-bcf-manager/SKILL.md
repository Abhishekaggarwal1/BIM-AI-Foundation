---
name: bim-bcf-manager
description: |
  Generating, parsing, and exchanging BIM Collaboration Format (BCF 2.1 & 3.0) XML archives and BCF REST API payloads.
  Use whenever user asks to create BCF topics, export clash viewpoints, capture 3D camera viewpoints in Revit/Navisworks, or connect to BCF servers (BIMcollab, Revizto).
compatibility: BCF 2.1 / BCF 3.0 (buildingSMART standard).
metadata:
  author: BIM-AI-Foundation
  version: "1.0.0"
  standard: agentskills.io
---

# BIM Collaboration Format (BCF) Manager Skill

BCF is the buildingSMART open standard for tracking issues, clashes, and RFIs across multidisciplinary BIM models without exchanging entire models.

---

## 1. BCF Zip Structure (BCF-XML)

A `.bcfzip` or `.bcf` file is a ZIP archive containing GUID-named directories for each topic:
```text
issue_guid/
├── markup.bcf         # Topic title, status, comments, assignees, dates (XML)
├── viewpoint.bcfv     # Camera position, view direction, component visibility (XML)
└── snapshot.png       # Viewport screenshot
```

---

## 2. Generating Viewpoints in Revit API

To capture a camera viewpoint matching BCF perspective camera specifications:

```csharp
using Autodesk.Revit.DB;

public void ExportViewpoint(View3D view3d, string bcfXmlPath)
{
    XYZ eye = view3d.GetOrientation().EyePosition;
    XYZ forward = view3d.GetOrientation().ForwardDirection;
    XYZ up = view3d.GetOrientation().UpDirection;

    // Map to BCF PerspectiveCamera XML schema
    string cameraXml = $@"
    <PerspectiveCamera>
        <CameraViewPoint><X>{eye.X}</X><Y>{eye.Y}</Y><Z>{eye.Z}</Z></CameraViewPoint>
        <CameraDirection><X>{forward.X}</X><Y>{forward.Y}</Y><Z>{forward.Z}</Z></CameraDirection>
        <CameraUpVector><X>{up.X}</X><Y>{up.Y}</Y><Z>{up.Z}</Z></CameraUpVector>
        <FieldOfView>60</FieldOfView>
    </PerspectiveCamera>";
}
```
