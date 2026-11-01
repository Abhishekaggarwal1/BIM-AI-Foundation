using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Geometry;
using Autodesk.AutoCAD.Runtime;

[assembly: CommandClass(typeof(CleanAutoCADAddin.Commands))]

namespace CleanAutoCADAddin
{
    public class Commands
    {
        [CommandMethod("BIM_DRAWGRID", CommandFlags.Modal)]
        public void DrawGrid()
        {
            Document doc = Application.DocumentManager.MdiActiveDocument;
            if (doc == null) return;

            Database db = doc.Database;
            Editor ed = doc.Editor;

            PromptDoubleOptions pdo = new PromptDoubleOptions("\nEnter grid spacing in drawing units: ")
            {
                AllowNegative = false,
                AllowZero = false,
                DefaultValue = 1000.0
            };

            PromptDoubleResult pdr = ed.GetDouble(pdo);
            if (pdr.Status != PromptStatus.OK) return;

            double spacing = pdr.Value;

            using (DocumentLock docLock = doc.LockDocument())
            using (Transaction tr = db.TransactionManager.StartTransaction())
            {
                try
                {
                    BlockTable bt = (BlockTable)tr.GetObject(db.BlockTableId, OpenMode.ForRead);
                    BlockTableRecord btr = (BlockTableRecord)tr.GetObject(bt[BlockTableRecord.ModelSpace], OpenMode.ForWrite);

                    int lineCount = 0;
                    for (int i = 0; i <= 4; i++)
                    {
                        double pos = i * spacing;
                        // Vertical grid line
                        Line vLine = new Line(new Point3d(pos, 0, 0), new Point3d(pos, 4 * spacing, 0));
                        btr.AppendEntity(vLine);
                        tr.AddNewlyCreatedDBObject(vLine, true);

                        // Horizontal grid line
                        Line hLine = new Line(new Point3d(0, pos, 0), new Point3d(4 * spacing, pos, 0));
                        btr.AppendEntity(hLine);
                        tr.AddNewlyCreatedDBObject(hLine, true);

                        lineCount += 2;
                    }

                    tr.Commit();
                    ed.WriteMessage($"\n[BIM-AI-Foundation] Successfully generated {lineCount} grid lines.");
                }
                catch (System.Exception ex)
                {
                    ed.WriteMessage($"\n[ERROR] Command failed: {ex.Message}");
                    tr.Abort();
                }
            }
        }

        [CommandMethod("BIM_AUDITLAYERS", CommandFlags.Modal)]
        public void AuditLayers()
        {
            Document doc = Application.DocumentManager.MdiActiveDocument;
            if (doc == null) return;

            Database db = doc.Database;
            Editor ed = doc.Editor;

            using (Transaction tr = db.TransactionManager.StartTransaction())
            {
                LayerTable lt = (LayerTable)tr.GetObject(db.LayerTableId, OpenMode.ForRead);

                ed.WriteMessage("\n================ Active Drawing Layers ================");
                int count = 0;
                foreach (ObjectId layerId in lt)
                {
                    LayerTableRecord ltr = (LayerTableRecord)tr.GetObject(layerId, OpenMode.ForRead);
                    ed.WriteMessage($"\n- Layer: {ltr.Name} (Locked: {ltr.IsLocked}, Off: {ltr.IsOff})");
                    count++;
                }
                ed.WriteMessage($"\nTotal layers audited: {count}\n");
                tr.Commit();
            }
        }
    }
}
