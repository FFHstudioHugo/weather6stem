// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Immersive Factory/Standard"
{
	Properties
	{
		[Header(StandardPBR)]
		_AlbedoMap("AlbedoMap", 2D) = "white" {}
		_MetalR_SmoothG("MetalR_SmoothG", 2D) = "white" {}
		_MetallicSmoothnessMap("MetallicSmoothnessMap", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "white" {}
		[Toggle(_RIMLIGHT_ON)] _RimLight("RimLight", Float) = 0
		_RimlightPower("Rimlight:Power", Float) = 3
		_RimlightScale("Rimlight:Scale", Float) = 10
		_RimlightBias("Rimlight:Bias", Float) = 0
		[HDR]_RimlightColor("Rimlight:Color", Color) = (0,0,0,0)
		_EmissionMap("EmissionMap", 2D) = "white" {}
		[Toggle(_EMISSIONBOOL_ON)] _EmissionBool("EmissionBool", Float) = 0
		_AlbedoColor("AlbedoColor", Color) = (0,0,0,0)
		[Toggle(_ALBEDO_ON)] _Albedo("Albedo", Float) = 0
		[KeywordEnum(None,MetalRGB_SmoothAlpha,Separate_MetallicSmoothness,MetalR_SmoothG)] _Metallic("Metallic", Float) = 0
		_MetallicMap("MetallicMap", 2D) = "white" {}
		_SmoothnessMap("SmoothnessMap", 2D) = "white" {}
		_SmoothnessSlider("SmoothnessSlider", Range( 0 , 1)) = 0
		_MetallicSlider("MetallicSlider", Range( 0 , 1)) = 0
		[Toggle(_NORMAL_ON)] _Normal("Normal", Float) = 0
		_Offset("Offset", Vector) = (0,0,0,0)
		_Tiling("Tiling", Vector) = (1,1,0,0)
		_EmissiveIntensity("Emissive Intensity", Range( 0 , 10)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 5.0
		#pragma shader_feature _NORMAL_ON
		#pragma shader_feature _ALBEDO_ON
		#pragma shader_feature _RIMLIGHT_ON
		#pragma shader_feature _EMISSIONBOOL_ON
		#pragma shader_feature _METALLIC_NONE _METALLIC_METALRGB_SMOOTHALPHA _METALLIC_SEPARATE_METALLICSMOOTHNESS _METALLIC_METALR_SMOOTHG
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _NormalMap;
		uniform float2 _Tiling;
		uniform float2 _Offset;
		uniform float4 _AlbedoColor;
		uniform sampler2D _AlbedoMap;
		uniform sampler2D _EmissionMap;
		uniform float _EmissiveIntensity;
		uniform float _RimlightBias;
		uniform float _RimlightScale;
		uniform float _RimlightPower;
		uniform float4 _RimlightColor;
		uniform float _MetallicSlider;
		uniform float _SmoothnessSlider;
		uniform sampler2D _MetallicSmoothnessMap;
		uniform sampler2D _MetallicMap;
		uniform sampler2D _SmoothnessMap;
		uniform sampler2D _MetalR_SmoothG;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_TexCoord9_g6 = i.uv_texcoord * _Tiling + _Offset;
			#ifdef _NORMAL_ON
				float3 staticSwitch37_g6 = UnpackNormal( tex2D( _NormalMap, uv_TexCoord9_g6 ) );
			#else
				float3 staticSwitch37_g6 = float3(0,0,1);
			#endif
			o.Normal = staticSwitch37_g6;
			#ifdef _ALBEDO_ON
				float4 staticSwitch35_g6 = tex2D( _AlbedoMap, uv_TexCoord9_g6 );
			#else
				float4 staticSwitch35_g6 = _AlbedoColor;
			#endif
			o.Albedo = staticSwitch35_g6.rgb;
			#ifdef _EMISSIONBOOL_ON
				float4 staticSwitch24_g6 = ( tex2D( _EmissionMap, uv_TexCoord9_g6 ) * _EmissiveIntensity );
			#else
				float4 staticSwitch24_g6 = float4( 0,0,0,0 );
			#endif
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNDotV16_g6 = dot( normalize( ase_worldNormal ), ase_worldViewDir );
			float fresnelNode16_g6 = ( _RimlightBias + _RimlightScale * pow( 1.0 - fresnelNDotV16_g6, _RimlightPower ) );
			#ifdef _RIMLIGHT_ON
				float4 staticSwitch34_g6 = ( staticSwitch24_g6 + ( fresnelNode16_g6 * _RimlightColor ) );
			#else
				float4 staticSwitch34_g6 = staticSwitch24_g6;
			#endif
			o.Emission = staticSwitch34_g6.rgb;
			float2 appendResult25_g6 = (float2(_MetallicSlider , _SmoothnessSlider));
			#if defined(_METALLIC_NONE)
				float2 staticSwitch30_g6 = appendResult25_g6;
			#elif defined(_METALLIC_METALRGB_SMOOTHALPHA)
			float4 tex2DNode26_g6 = tex2D( _MetallicSmoothnessMap, uv_TexCoord9_g6 );
			float grayscale49_g6 = Luminance(tex2DNode26_g6.rgb);
			float2 appendResult50_g6 = (float2(grayscale49_g6 , tex2DNode26_g6.a));
				float2 staticSwitch30_g6 = appendResult50_g6;
			#elif defined(_METALLIC_SEPARATE_METALLICSMOOTHNESS)
			float grayscale18_g6 = Luminance(tex2D( _MetallicMap, uv_TexCoord9_g6 ).rgb);
			float grayscale20_g6 = Luminance(tex2D( _SmoothnessMap, uv_TexCoord9_g6 ).rgb);
			float2 appendResult23_g6 = (float2(grayscale18_g6 , grayscale20_g6));
				float2 staticSwitch30_g6 = appendResult23_g6;
			#elif defined(_METALLIC_METALR_SMOOTHG)
			float4 tex2DNode45_g6 = tex2D( _MetalR_SmoothG, uv_TexCoord9_g6 );
			float2 appendResult46_g6 = (float2(tex2DNode45_g6.r , tex2DNode45_g6.g));
				float2 staticSwitch30_g6 = appendResult46_g6;
			#else
				float2 staticSwitch30_g6 = appendResult25_g6;
			#endif
			o.Metallic = staticSwitch30_g6.x;
			o.Smoothness = staticSwitch30_g6.y;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma exclude_renderers xbox360 xboxone ps4 psp2 n3ds wiiu 
		#pragma surface surf Standard keepalpha fullforwardshadows nodynlightmap 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal( v.normal );
				fixed3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			fixed4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "CustomShaderStandardEditor"
}
/*ASEBEGIN
Version=14501
226;92;952;655;842.6577;696.1888;1.777586;True;False
Node;AmplifyShaderEditor.FunctionNode;104;75.97916,-267.0284;Float;False;StandardPBR;0;;6;8419a5eee1f517246a64b2db1fd47dd3;0;0;5;FLOAT;39;FLOAT;40;COLOR;38;FLOAT3;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;526.5915,-252.6627;Float;False;True;7;Float;CustomShaderStandardEditor;0;0;Standard;Immersive Factory/Standard;False;False;False;False;False;False;False;True;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;False;False;False;False;False;False;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;0;0;104;0
WireConnection;0;1;104;1
WireConnection;0;2;104;38
WireConnection;0;3;104;39
WireConnection;0;4;104;40
ASEEND*/
//CHKSM=675A67F4DF0B94916263F2464E09C6E586549FD0