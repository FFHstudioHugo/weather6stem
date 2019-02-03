
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering.PostProcessing;

[ExecuteInEditMode]


public class ImmersiveWeatherControl : MonoBehaviour
    {

    

    [Header("Set the time of day and weather")]
  
    [Range(0f, 24f)]
    
    public float Hour;

        public enum WeatherEnum { dry = 0, wet, drying, snowy, fullsnow };
        public WeatherEnum WeatherState;

        [Tooltip("Wetness Indicator")]

    public  float Wetnessvalue;
        public float Snownessvellue;
       

        private bool Isplaying = false;
        private float normalizedSun;
       

        private float Envirronment_Lighting_Intensity;
        Vector3 SunOrientation;
        float NR;
        float SunHorizon;


        [Header("Set the lighting of the scene")]

   
    public float lightintensity = 2f;
   
    private float rotationLight;
    public float Longitude;

    public Material Skybox;
    [Range(0f, 3.2f)]
        public float Skybox_Exposure_Multiplier = 1f;
        [Range(0f, 5f)]
        public float Environment_Lighting_Multiplier = 1f;

        [Range(0f, 3.2f)]
        float SunIntensity;



    [Header("Set the Fog")]
    public Color Fog_Color;
    public float Fog_Intensity;


    [Header("Quality Options")]
    public bool Atmospheric_Scatterring = true;
    public enum QualitySettingEnum { Build_Quality = 0, DevQuality = 1};
    public QualitySettingEnum QualitySetting;
    public GameObject m_VolumeDev;
    public GameObject m_VolumeBuild;


    [Header("Atmospheric Scaterring")]

    public AtmosphericScattering atm;
    private AtmosphericScatteringDeferred atmd;

    [Range(0f, 1.1f)]
    public float AtmosphericGlobalPower;
    public float RayleighDensity;
    public float RayleighColor;
    public float MiePower;




    [HideInInspector]
    public float AtmosphericPower;


    [Header("Day and night Cycle curves")]
    public AnimationCurve DayLightIntensity;
    public AnimationCurve AtmosphericIntensity;
   

    private Camera maincam;
  private   Vector3 camt;



    public GameObject FXWeather;
    public Animator WeatherStack;
    public Light Sun;
    public Transform SunPivot;


    private  Vector3 Fxoffset ;
    Vector3 ab;
    bool execute;
   

    // public int qualityLevel = QualitySettings.GetQualityLevel();


    void Start()
    {
        Fxoffset.x = 14.5f;
        Fxoffset.y = 7.4f;
        Fxoffset.z = 13.5f;
        Sun.transform.localEulerAngles = SunOrientation;
            NR = SunOrientation.x + 180;



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

            case WeatherEnum.snowy:
                {
                    Snowy();
                }
                break;

            case WeatherEnum.fullsnow:
                {
                    FullSnow();
                }
                break;

        }


    }

    // Update is called once per frame
    void Update()
    {
       
        SunSet();
        QUalitySwitch();

    }

    void QUalitySwitch() {
        maincam = Camera.main;
        camt = maincam.transform.position;

        FXWeather.transform.localPosition = camt;

        switch (QualitySetting)
        {
            case QualitySettingEnum.Build_Quality:
                {

                    m_VolumeBuild.GetComponent<PostProcessVolume>().enabled = true;
                    m_VolumeDev.GetComponent<PostProcessVolume>().enabled = false;
                    for (int i = 0; i < QualitySettings.names.Length; i++)
                    {
                        if (QualitySettings.names[i] == "Build Quality")
                        {
                            QualitySettings.SetQualityLevel(i);

                        }
                    }

                }
                break;

            case QualitySettingEnum.DevQuality:
                {

                    m_VolumeDev.GetComponent<PostProcessVolume>().enabled = true;
                    m_VolumeBuild.GetComponent<PostProcessVolume>().enabled = false;
                    for (int i = 0; i < QualitySettings.names.Length; i++)
                    {
                        if (QualitySettings.names[i] == "Dev Quality")
                        {
                            QualitySettings.SetQualityLevel(i);

                        }
                    }
                }
                break;
        }
        if (Atmospheric_Scatterring == true && execute == false)
        {

            execute = true;

            maincam.GetComponent<AtmosphericScatteringDeferred>().enabled = true;
            atm.enabled = true;
            execute = false;
            return;

        }
        if (Atmospheric_Scatterring == false && execute == false)
        {
            execute = true;

            maincam.GetComponent<AtmosphericScatteringDeferred>().enabled = false;
            atm.enabled = false;
            execute = false;
            return;

        }


       

    }

        public void SunSet()
    {
    

        SunOrientation = new Vector3((Hour - 12) * 15, 0, 0);
            Sun.transform.localEulerAngles = SunOrientation;
            SunPivot.localEulerAngles = new Vector3(90, Longitude, 0);

            Envirronment_Lighting_Intensity = 1 * (1 + (SunIntensity / 5));

            RenderSettings.ambientIntensity = Environment_Lighting_Multiplier * Envirronment_Lighting_Intensity;

            SunIntensity = DayLightIntensity.Evaluate(Hour) * lightintensity;
            Sun.intensity = SunIntensity;

         Skybox.SetFloat("_Exposure", Skybox_Exposure_Multiplier * (9.6f * (normalizedSun * 2)));
        normalizedSun = SunIntensity / 3.2f;
        AtmosphericPower =  AtmosphericIntensity.Evaluate(Hour)*AtmosphericGlobalPower;
      float wetnessg = Mathf.Clamp( Wetnessvalue- Snownessvellue,0,1);
        RenderSettings.fogColor = Fog_Color * AtmosphericIntensity.Evaluate(Hour);
        RenderSettings.fogDensity = Fog_Intensity/10;





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

            case WeatherEnum.snowy:
                {
                    Snowy();
                }
                break;

            case WeatherEnum.fullsnow:
                {
                    FullSnow();
                }
                break;

        }




        Shader.SetGlobalFloat("_GlobalWetness", wetnessg);
        Shader.SetGlobalFloat("_GlobalSnowness", Snownessvellue);
    }

    void Snowy()
    {
     

            Snownessvellue = 0.2f;
        Wetnessvalue = 0;
    }


    void FullSnow()
    {

      
            Snownessvellue = 0.8f;
        Wetnessvalue = 0;

    }


    void Wet()
    {

      
        Wetnessvalue = 1;
        Snownessvellue = 0;
   

    }


    void Drying()
    {
     
      
            Wetnessvalue = 0.67f;
        Snownessvellue = 0;
   

    }


    void Dry()
    {
       
            Wetnessvalue = 0;
            Snownessvellue = 0;
      

    }
 

}

