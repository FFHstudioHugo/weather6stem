using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(Immersive_PathCreator))]
public class Immersive_PathEditor : Editor {

    Immersive_PathCreator creator;

    private SerializedObject serializedCreator;
    private SerializedProperty serializedMeshPool;

    bool showControlTips = true;
    bool showGizmosOptions = true;
    bool showSplineOptions = true;
    bool showPopulationOptions = true;
    bool showMeshPool = true;
    bool showRoadOptions = true;

    int selectedHandleIndex = -1;

    Immersive_Path Path
    {
        get
        {
            return creator.path;
        }
    }

    const float segmentSelectDistanceThreshold = 10f;
    int selectedSegmentIndex = -1;

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        EditorGUI.BeginChangeCheck();
        /////////////////////////////////////////// CONTROL TIPS
        showControlTips = EditorGUILayout.Foldout(showControlTips, "Control Tips", true, EditorStyles.boldLabel);

        if (showControlTips)
        {

            EditorGUILayout.HelpBox("Add Anchor point : Shift + Left Click", MessageType.None, true);
            EditorGUILayout.HelpBox("Delete Anchor Point : Right Click", MessageType.None, true);

            EditorGUILayout.Separator();
        }

        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

        /////////////////////////////////////////// GIZMOS OPTIONS
        showGizmosOptions = EditorGUILayout.Foldout(showGizmosOptions, "Gizmos Options", true, EditorStyles.boldLabel);

        if (showGizmosOptions)
        {

            bool displayControlPoints = GUILayout.Toggle(creator.displayControlPoints, "Display Control Points");
            if (displayControlPoints != creator.displayControlPoints)
            {
                Undo.RecordObject(creator, "Toggle display control points");
                creator.displayControlPoints = displayControlPoints;
            }

            EditorGUILayout.Separator();

            EditorGUILayout.BeginHorizontal();
            creator.anchorCol = EditorGUILayout.ColorField("Anchor Color", creator.anchorCol);
            creator.anchorDiameter = EditorGUILayout.FloatField("Anchor Size", creator.anchorDiameter);
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.Separator();

            EditorGUILayout.BeginHorizontal();
            creator.controlCol = EditorGUILayout.ColorField("Control Color", creator.controlCol);
            creator.controlDiameter = EditorGUILayout.FloatField("Control Size", creator.controlDiameter);
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.Separator();

            EditorGUILayout.BeginHorizontal();
            creator.segmentCol = EditorGUILayout.ColorField("Line Color", creator.segmentCol);
            creator.segmentWidth = EditorGUILayout.FloatField("Line Size", creator.segmentWidth);
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.Separator();
        }

        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

        /////////////////////////////////////////// PATH OPTIONS
        showSplineOptions = EditorGUILayout.Foldout(showSplineOptions, "Path options",true, EditorStyles.boldLabel);

        if (showSplineOptions)
        {
            if (GUILayout.Button("Create New"))
            {
                Undo.RecordObject(creator, "Create New Path");
                creator.CreatePath();
            }

            bool isClosed = GUILayout.Toggle(Path.IsClosed, "Closed");
            if (isClosed != Path.IsClosed)
            {
                Undo.RecordObject(creator, "Toggle Closed");
                Path.IsClosed = isClosed;
            }

            bool autoSetControlPoints = GUILayout.Toggle(Path.AutoSetControlPoints, "Auto Set Control Points (CAREFULL, WIP)");
            if (autoSetControlPoints != Path.AutoSetControlPoints)
            {
                Undo.RecordObject(creator, "Toggle auto set controls");
                Path.AutoSetControlPoints = autoSetControlPoints;
            }

            EditorGUILayout.Separator();
        }
        
        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

        ////////////////////////////////////// POPULATION OPTIONS

        showPopulationOptions = EditorGUILayout.Foldout(showPopulationOptions, "Population options", true, EditorStyles.boldLabel);

        if (showPopulationOptions)
        {
            showMeshPool = EditorGUILayout.Foldout(showMeshPool, "Objects pool");

            if (showMeshPool)
            {
                for (int i = 0; i < creator.meshPool.Count - 1; i++)
                {
                    EditorGUILayout.BeginHorizontal();
                    creator.meshPool[i] = (GameObject)EditorGUILayout.ObjectField(creator.meshPool[i], typeof(GameObject), true);

                    EditorGUILayout.Space();
                    if (GUILayout.Button("Remove"))
                    {
                        Undo.RecordObject(creator, "Remove Object from mesh pool");
                        creator.meshPool.Remove(creator.meshPool[i]);
                    }
                    EditorGUILayout.Space();
                    EditorGUILayout.EndHorizontal();
                }

                EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button("Add Object"))
                {
                    Undo.RecordObject(creator, "Add Object to mesh pool");
                    creator.meshPool.Add(null);
                }
                EditorGUILayout.Separator();
                EditorGUILayout.EndHorizontal();

                EditorGUILayout.Separator();
            }

            bool randomizePool = GUILayout.Toggle(creator.randomizePool, "Randomize Pool");
            if (randomizePool != creator.randomizePool)
            {
                Undo.RecordObject(creator, "Toggle randomize pool");
                creator.randomizePool = randomizePool;
            }
            creator.spacing = EditorGUILayout.FloatField("Spacing", creator.spacing);
            creator.resolution = EditorGUILayout.FloatField("Resolution", creator.resolution);

            EditorGUILayout.BeginHorizontal();

            if (GUILayout.Button("Populate"))
            {
                Undo.RecordObject(creator, "Populate");
                PopulateWithMeshes();
            }

            if (GUILayout.Button("Destroy Population"))
            {
                Undo.RecordObject(creator, "Destroy Population");
                DestroyPopulation();
            }
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.Separator();
        }

            
        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

        ////////////////////////////////////// ROAD OPTIONS

        showRoadOptions = EditorGUILayout.Foldout(showRoadOptions, "Road options", true, EditorStyles.boldLabel);

        if (showRoadOptions)
        {
            if (creator.roadAutoUpdate && Event.current.type == EventType.Repaint)
            {
                UpdateRoad();
            }

            creator.roadSpacing = EditorGUILayout.Slider("Resolution", creator.roadSpacing,0.1f,1.5f);
            creator.roadWidth = EditorGUILayout.Slider("RoadWidth", creator.roadWidth, 0, 20);

            bool roadAutoUpdate = GUILayout.Toggle(creator.roadAutoUpdate, "Auto update");
            if (roadAutoUpdate != creator.roadAutoUpdate)
            {
                Undo.RecordObject(creator, "Toggle road auto update");
                creator.roadAutoUpdate = roadAutoUpdate;
            }

            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("Update Road"))
            {
                Undo.RecordObject(creator, "Update road");
                UpdateRoad();
            }
            if (GUILayout.Button("Delete Road"))
            {
                Undo.RecordObject(creator, "Delete road");
                DeleteRoad();
            }

            EditorGUILayout.EndHorizontal();
        }

        if (EditorGUI.EndChangeCheck())
        {
            SceneView.RepaintAll();
        }
    }

    private void OnSceneGUI()
    {
        Input();
        Draw();
    }

    //////////////////////////////////////////////////// Population Methods

    public void PopulateWithMeshes()
    {
        // Destroy current population
        DestroyPopulation();

        // Get population placement
        Vector3[] points = Path.CalculateEvenlySpacePoints(creator.spacing, creator.resolution);

        // Populate
        int poolIndex = 0;
        foreach (Vector3 p in points)
        {
            GameObject g;
            if (creator.randomizePool)
            {
                g = (GameObject)PrefabUtility.InstantiatePrefab(creator.meshPool[(int)Random.Range(0, creator.meshPool.Count - 1)]);
            }
            else
            {
                g = (GameObject)PrefabUtility.InstantiatePrefab(creator.meshPool[poolIndex]);
                poolIndex++;
                if (poolIndex >= creator.meshPool.Count - 1)
                {
                    poolIndex = 0;
                }
            }
            g.transform.parent = creator.transform;
            creator.currentPopulation.Add(g);
            g.transform.localPosition = p;
        }
    }

    public void DestroyPopulation()
    {
        foreach (GameObject go in creator.currentPopulation)
        {
            DestroyImmediate(go);
        }
    }

    /////////////////////////////////////////////////// Road creation methods

    public void UpdateRoad()
    {
        Immersive_Path path = Path;
        Vector3[] points = path.CalculateEvenlySpacePoints(creator.roadSpacing);
        if (creator.roadMeshFilter == null)
        {
            GameObject emptyGo = new GameObject();
            creator.roadGameObject = GameObject.Instantiate(emptyGo, creator.transform);
            creator.roadGameObject.name = "Spline Road";
            creator.roadMeshFilter = creator.roadGameObject.AddComponent<MeshFilter>();
            creator.roadMeshRenderer = creator.roadGameObject.AddComponent<MeshRenderer>();
            DestroyImmediate(emptyGo);
        }
        creator.roadMeshFilter.mesh = CreateRoadMesh(points, path.IsClosed);
    }

    public void DeleteRoad()
    {
        if (creator.roadMeshFilter != null)
        {
            DestroyImmediate(creator.roadGameObject);
            DestroyImmediate(creator.roadMeshFilter);
            DestroyImmediate(creator.roadMeshRenderer);
        }
    }

    Mesh CreateRoadMesh(Vector3[] points, bool isClosed)
    {
        Vector3[] verts = new Vector3[points.Length * 2];
        Vector2[] uvs = new Vector2[verts.Length];
        int numTris = 2 * (points.Length - 1) + ((isClosed) ? 2 : 0);
        int[] tris = new int[numTris * 3];
        int vertIndex = 0;
        int triIndex = 0;

        for (int i = 0; i < points.Length; i++)
        {
            Vector3 forward = Vector3.zero;
            if (i < points.Length - 1 || isClosed)
            {
                forward += points[(i + 1) % points.Length] - points[i];
            }
            if (i > 0 || isClosed)
            {
                forward += points[i] - points[(i - 1 + points.Length) % points.Length];
            }
            forward.Normalize();
            Vector3 left = new Vector3(-forward.y, forward.x, 0);

            verts[vertIndex] = points[i] + left * creator.roadWidth * 0.5f;
            verts[vertIndex + 1] = points[i] - left * creator.roadWidth * 0.5f;

            float completionPercent = i / (float)(points.Length - 1);
            uvs[vertIndex] = new Vector2(0, completionPercent);
            uvs[vertIndex + 1] = new Vector2(1, completionPercent);

            if (i < points.Length - 1 || isClosed)
            {
                tris[triIndex] = vertIndex;
                tris[triIndex + 1] = (vertIndex + 2) % verts.Length;
                tris[triIndex + 2] = vertIndex + 1;

                tris[triIndex + 3] = vertIndex + 1;
                tris[triIndex + 4] = (vertIndex + 2) % verts.Length;
                tris[triIndex + 5] = (vertIndex + 3) % verts.Length;
            }

            vertIndex += 2;
            triIndex += 6;
        }

        Mesh mesh = new Mesh();
        mesh.vertices = verts;
        mesh.triangles = tris;
        mesh.uv = uvs;

        return mesh;
    }

    /////////////////////////////////////////////////// Input Managment

    void Input()
    {
        Event guiEvent = Event.current;
        Vector3 mousePos = HandleUtility.GUIPointToWorldRay(guiEvent.mousePosition).origin;
        if (guiEvent.type == EventType.MouseDown && guiEvent.button == 0 && guiEvent.shift )
        {
            if (selectedSegmentIndex != -1)
            {
                Undo.RecordObject(creator, "Split Segment");
                Path.SplitSegment(creator.transform.InverseTransformPoint(mousePos), selectedSegmentIndex);
            }
            else if (!Path.IsClosed)
            {
                Undo.RecordObject(creator, "Add Segment");
                Path.AddSegment(creator.transform.InverseTransformPoint(mousePos));
            }
        }
        //if (guiEvent.type == EventType.MouseDown && guiEvent.button == 1 && guiEvent.control)
        //{
        //    float minDstToAnchor = creator.anchorDiameter * 1f;
        //    int closestAnchorIndex = -1;

        //    Vector3 newMousePos = creator.transform.InverseTransformPoint(mousePos);
        //    newMousePos.z = 0;

        //    for (int i = 0; i < Path.NumPoints; i += 3)
        //    {
        //        float dst = Vector3.Distance(newMousePos, Path[i]);
        //        if (dst < minDstToAnchor)
        //        {
        //            minDstToAnchor = dst;
        //            closestAnchorIndex = i;
        //        }
        //    }

        //    if (closestAnchorIndex != -1)
        //    {
        //        Undo.RecordObject(creator, "Split Segment");
        //        Path.SplitSegment(newMousePos, closestAnchorIndex % 3);
        //    }
        //}
        if (guiEvent.type == EventType.MouseDown && guiEvent.button == 1)
        {
            float minDstToAnchor = creator.anchorDiameter*1f;
            int closestAnchorIndex = -1;

            Vector3 newMousePos = creator.transform.InverseTransformPoint(mousePos);
            newMousePos.z = 0;

            for (int i = 0; i < Path.NumPoints; i+=3)
            {
                float dst = Vector3.Distance(newMousePos, Path[i]);
                if(dst < minDstToAnchor)
                {
                    minDstToAnchor = dst;
                    closestAnchorIndex = i;
                }
            }

            if (closestAnchorIndex != -1)
            {
                Undo.RecordObject(creator, "Delete Segment");
                Path.DeleteSegment(closestAnchorIndex);
            }
        }
        



        //if(guiEvent.type == EventType.MouseMove)
        //{
        //    float minDstToSegment = segmentSelectDistanceThreshold;
        //    int newSelectedSegmentIndex = -1;

        //    for (int i = 0; i < Path.NumSegments; i++)
        //    {
        //        Vector3[] points = Path.GetPointsInSegment(i);
        //        creator.transform.InverseTransformPoint(mousePos);
        //        Vector3 newMousePos = new Vector3(mousePos.x, mousePos.z, mousePos.y);
        //        newMousePos.y = points[0].z;
        //        float dst = HandleUtility.DistancePointBezier(newMousePos, points[0], points[3], points[1], points[2]);
        //        if (dst < minDstToSegment)
        //        {
        //            minDstToSegment = dst;
        //            newSelectedSegmentIndex = i;
        //        }
        //    }

        //    if (newSelectedSegmentIndex != selectedSegmentIndex)
        //    {
        //        selectedSegmentIndex = newSelectedSegmentIndex;
        //        HandleUtility.Repaint();
        //    }
        //}

        HandleUtility.AddDefaultControl(0);
    }

    void Draw()
    {

        for (int i = 0; i < Path.NumSegments; i++)
        {
            Vector3[] points = Path.GetPointsInSegment(i);
            points[0] = creator.transform.TransformPoint(points[0]);
            points[1] = creator.transform.TransformPoint(points[1]);
            points[2] = creator.transform.TransformPoint(points[2]);
            points[3] = creator.transform.TransformPoint(points[3]);
            if (creator.displayControlPoints)
            {
                Handles.color = Color.black;
                Handles.DrawLine(points[1], points[0]);
                Handles.DrawLine(points[2], points[3]);
            }
            Color segmentColor = (i == selectedSegmentIndex && Event.current.shift) ? creator.selectedSegmentColor : creator.segmentCol;
            Handles.DrawBezier(points[0], points[3], points[1], points[2], segmentColor, null, creator.segmentWidth);
        }

        
        for (int i = 0; i < Path.NumPoints; i++)
        {
            if (i%3 == 0 || creator.displayControlPoints)
            {
                Handles.color = (i % 3 == 0) ? creator.anchorCol : creator.controlCol;
                float handleSize = (i % 3 == 0) ? creator.anchorDiameter : creator.controlDiameter;
                if (selectedHandleIndex == i)
                {
                    Vector3 newPos = Handles.PositionHandle(creator.transform.TransformPoint(Path[i]), Quaternion.identity);
                    //Vector3 newPos = Handles.FreeMoveHandle(creator.transform.TransformPoint(Path[i]), Quaternion.identity, .1f, Vector3.zero, Handles.SphereHandleCap);
                    if (creator.transform.TransformPoint(Path[i]) != newPos)
                    {
                        Undo.RecordObject(creator, "Move point");
                        Path.MovePoint(i, creator.transform.InverseTransformPoint(newPos));
                    }
                }
                else
                {
                    if (Handles.Button(creator.transform.TransformPoint(Path[i]),Quaternion.identity, handleSize, handleSize, Handles.SphereHandleCap))
                    {
                        selectedHandleIndex = i;
                    }
                }
                
            }
            
        }
    }

    private void OnEnable()
    {
        creator = (Immersive_PathCreator)target;
        if(creator.path == null)
        {
            creator.CreatePath();
        }
    } 

}
