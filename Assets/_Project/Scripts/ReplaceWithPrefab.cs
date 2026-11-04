using UnityEngine;
using UnityEditor;

public class ReplaceWithPrefab : EditorWindow
{
    public GameObject prefabToSpawn;

    [MenuItem("Tools/Replace With Prefab")]
    public static void ShowWindow()
    {
        GetWindow<ReplaceWithPrefab>("Replace With Prefab");
    }

    private void OnGUI()
    {
        GUILayout.Label("Batch Replace Selected Objects", EditorStyles.boldLabel);
        EditorGUILayout.Space();

        prefabToSpawn = (GameObject)EditorGUILayout.ObjectField("Tree Prefab", prefabToSpawn, typeof(GameObject), false);

        EditorGUILayout.Space();

        if (GUILayout.Button("Replace Selected Objects", GUILayout.Height(30)))
        {
            if (prefabToSpawn == null)
            {
                Debug.LogError("Please assign a prefab to spawn first!");
                return;
            }

            GameObject[] selectedObjects = Selection.gameObjects;

            if (selectedObjects.Length == 0)
            {
                Debug.LogWarning("No objects selected in the Hierarchy or Scene!");
                return;
            }

            Undo.RegisterFullObjectHierarchyUndo(selectedObjects[0], "Replace Objects");

            foreach (GameObject oldObj in selectedObjects)
            {
                // Instantiate the tree prefab
                GameObject newObj = (GameObject)PrefabUtility.InstantiatePrefab(prefabToSpawn);
                
                // Match the transform of the old pipe
                newObj.transform.position = oldObj.transform.position;
                newObj.transform.rotation = oldObj.transform.rotation;
                newObj.transform.localScale = oldObj.transform.localScale;
                
                // Keep the same parent in the hierarchy if it had one
                if (oldObj.transform.parent != null)
                {
                    newObj.transform.SetParent(oldObj.transform.parent);
                }

                // Delete the old pipe
                DestroyImmediate(oldObj);
            }

            Debug.Log($"Successfully replaced {selectedObjects.Length} pipes with trees!");
        }
    }
}