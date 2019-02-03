using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[ExecuteInEditMode]
public class testLight : MonoBehaviour {

    public Light Sun;
    public AnimationCurve DayLightIntensity;
    float SunIntensity;
    public float lightintensity = 2f;
    public float rotationLight;

   private float Hour_of_journey;
    float NR;
    [Range(0f, 24f)]
    public float Hour;
    public float Longitude;
   
    Vector3 SunOrientation;
    // Use this for initialization
    void Start () {
        Sun.transform.localEulerAngles = SunOrientation;
         NR = SunOrientation.x + 180;

    }
	
	// Update is called once per frame
	void Update () {
        truc();
    }

    public void truc()
    {
        SunOrientation = new Vector3 ((Hour-12)*15, 0 , 0);
        //  SunIntensity = Sun.intensity;
       // Hour_of_journey = (NR) / 15;
        Sun.transform.localEulerAngles = SunOrientation;

        if (rotationLight < -180)
        {
            Sun.intensity = 0;
          
        }
        if (rotationLight > 270)
        {
            Sun.intensity = 0;

        }
        else {
            Sun.intensity = DayLightIntensity.Evaluate(Hour)*lightintensity;

        }
        return;
    }
}
