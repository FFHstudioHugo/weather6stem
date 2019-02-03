using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WetnessControl : MonoBehaviour {

    public List<Material> wetMaterials;
    public Shader wetShader;
 
    public enum WeatherEnum { dry =0 , wet , drying };
    public WeatherEnum WeatherState;


    void Start () {
    
    }

    
    void Update() {
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
      //  Shader.SetGlobalFloat("_SnowPower", value);
        // wetfloor.SetFloat("_Wetness", weather);
        /*  if (Input.GetKeyDown("space"))
              Wet();

          if (Input.GetKeyDown("a"))
              Drying();

          if (Input.GetKeyDown("r"))
              Dry();*/
        //WEATHER LIST ENUM UPDATE BY THE LIST 

    }

        
 
    void Wet () {
        Shader.EnableKeyword("_WET");
        Shader.DisableKeyword("_DRYING");
    }
    void Drying()
    {
        Shader.EnableKeyword("_DRYING");
        Shader.DisableKeyword("_WET");
    }
    void Dry()
    {
        Shader.DisableKeyword("_DRYING");
        Shader.DisableKeyword("_WET");
    }
}
