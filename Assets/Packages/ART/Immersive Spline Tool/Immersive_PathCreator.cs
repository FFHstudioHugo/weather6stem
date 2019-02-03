using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class Immersive_PathCreator : MonoBehaviour {

    [HideInInspector]
    public Immersive_Path path;


    // Spline parameters
    [HideInInspector]
    public Color anchorCol = Color.red;
    [HideInInspector]
    public Color controlCol = Color.white;
    [HideInInspector]
    public Color segmentCol = Color.green;
    [HideInInspector]
    public float segmentWidth = 2f;
    [HideInInspector]
    public Color selectedSegmentColor = Color.red;
    [HideInInspector]
    public float anchorDiameter = 0.5f;
    [HideInInspector]
    public float controlDiameter = 0.3f;
    [HideInInspector]
    public bool displayControlPoints = true;

    // Mesh population parameters
    [HideInInspector]
    public List<GameObject> meshPool = new List<GameObject>();
    [HideInInspector, Range(float.Epsilon, float.PositiveInfinity)]
    public float spacing = 1;
    [HideInInspector, Range(0, float.PositiveInfinity)]
    public float resolution;
    [HideInInspector]
    public bool randomizePool;
    [HideInInspector]
    public List<GameObject> currentPopulation = new List<GameObject>();

    // Road creator parameters
    [HideInInspector, Range(0.15f, 1.5f)]
    public float roadSpacing = 1;
    [HideInInspector]
    public float roadWidth = 1;
    [HideInInspector]
    public bool roadAutoUpdate;
    [HideInInspector]
    public GameObject roadGameObject = null;
    [HideInInspector]
    public MeshFilter roadMeshFilter = null;
    [HideInInspector]
    public MeshRenderer roadMeshRenderer = null;

    public void CreatePath()
    {
        path = new Immersive_Path(transform.position);
    }

    private void Reset()
    {
        CreatePath();
    }

    
}

