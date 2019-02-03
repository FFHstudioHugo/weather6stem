using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


[ExecuteInEditMode]
public class ImmersiveWeatherControlSimplified : MonoBehaviour {
    public Animator WeatherStack;
    public enum WeatherEnum { dry = 0, wet, drying };
    public WeatherEnum WeatherState;
    private float Editorvalue;
    public float Wetnessvalue;
    private bool Isplaying = false;
  


    // Use this for initialization

 


    

    void Start ()
    {
      
        switch (WeatherState)
        {
            case WeatherEnum.wet:

                {
                    Wet();
                }
                break;
            case WeatherEnum.dry:

                {
                    Dry();
                }
                break;
            case WeatherEnum.drying:

                {
                    Drying();
                }
                break;
        }
        /*  */

    }
	
	// Update is called once per frame
	void Update () {
        CheckandSet();
    }

    

    void CheckandSet ()
    {
       

        switch (WeatherState)
        {
            case WeatherEnum.wet:

                {
                    Wet();
                }
                break;
            case WeatherEnum.dry:

                {
                    Dry();
                }
                break;
            case WeatherEnum.drying:

                {
                    Drying();
                }
                break;
        }
        
        Shader.SetGlobalFloat("_Wet", Wetnessvalue);
    }

    void Wet()
    {
        WeatherStack.SetTrigger("Wet");
#if UNITY_EDITOR
        Debug.Log("Unity Editor");

        if (EditorApplication.isPlaying == false ) { Wetnessvalue = 1; }
        return;
#endif

    }

    void Drying()
    {
        WeatherStack.SetTrigger("Drying");
#if UNITY_EDITOR
        if (EditorApplication.isPlaying == false) { Wetnessvalue = 0.67f; }
        return;
#endif

    }

    void Dry()
    {
        WeatherStack.SetTrigger("Dry");
#if UNITY_EDITOR
        if (EditorApplication.isPlaying == false) { Wetnessvalue = 0; }
        return;
#endif

    }
}
