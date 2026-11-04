using UnityEngine;
using UnityEditor;

public class ApplyMaterialToSelected : EditorWindow
{
    public Material materialToApply;

    [MenuItem("Tools/Apply Material To Selected")]
    public static void ShowWindow()
    {
        GetWindow<ApplyMaterialToSelected>("Apply Material");
    }

    private void OnGUI()
    {
        GUILayout.Label("Batch Apply Material to Selected Objects", EditorStyles.boldLabel);
        EditorGUILayout.Space();

        materialToApply = (Material)EditorGUILayout.ObjectField("Material", materialToApply, typeof(Material), false);

        EditorGUILayout.Space();

        if (GUILayout.Button("Apply Material", GUILayout.Height(30)))
        {
            if (materialToApply == null)
            {
                Debug.LogError("Please assign a material first!");
                return;
            }

            GameObject[] selectedObjects = Selection.gameObjects;

            if (selectedObjects.Length == 0)
            {
                Debug.LogWarning("No objects selected in the Hierarchy or Scene!");
                return;
            }

            Undo.RegisterFullObjectHierarchyUndo(selectedObjects[0], "Apply Material to Selected");

            int count = 0;
            foreach (GameObject obj in selectedObjects)
            {
                MeshRenderer renderer = obj.GetComponent<MeshRenderer>();
                if (renderer != null)
                {
                    renderer.sharedMaterial = materialToApply;
                    count++;
                }
            }

            Debug.Log($"Successfully applied material to {count} objects!");
        }
    }
}