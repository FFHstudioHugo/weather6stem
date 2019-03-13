// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASESampleShaders/Translucency"
{
	Properties
	{
		_Specular("Specular", Range( 0 , 1)) = 0
		_Color0("Color 0", Color) = (0,0,0,0)
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
		_Albedo("Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_Depth("Depth", 2D) = "white" {}
		_HeadSpecular("HeadSpecular", 2D) = "white" {}
		_AO("AO", 2D) = "white" {}
		_Tint("Tint", Color) = (0,0,0,0)
		_IOR("IOR", Float) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_SSSintensity("SSSintensity", Float) = 0
		_Color3("Color 3", Color) = (0,0,0,0)
		_Color2("Color 2", Color) = (0,0,0,0)
		_Color1("Color 1", Color) = (0,0,0,0)
		_Transmission("Transmission", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		ZTest LEqual
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			half2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
		};

		struct SurfaceOutputStandardSpecularCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half3 Specular;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Transmission;
			half3 Translucency;
		};

		uniform sampler2D _Normal;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform half4 _Tint;
		uniform sampler2D _Depth;
		uniform float4 _Depth_ST;
		uniform half4 _Color1;
		uniform half4 _Color2;
		uniform half4 _Color3;
		uniform sampler2D _Transmission;
		uniform float4 _Transmission_ST;
		uniform half _SSSintensity;
		uniform sampler2D _HeadSpecular;
		uniform float4 _HeadSpecular_ST;
		uniform half _Specular;
		uniform half _Smoothness;
		uniform half _IOR;
		uniform sampler2D _AO;
		uniform float4 _AO_ST;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;
		uniform half4 _Color0;


		float3 SSS2_g1( float3 Normal , float Depth , float3 ColorSSS1 , float3 ColorSSS2 , float3 ColorSSS3 , float LevelColor1 , float LevelColor2 , float Transmission , float Intensity , float3 lightDirection , out float3 Out_ )
		{
			float remap1 = ((Depth)*4.0+-3.0);
			float nulll = 0.0;
			float M_ = (-1.0);
			float _Gradient = saturate((nulll + ( ((dot(Normal,lightDirection)*(1.0 - remap1)) - M_) * (1.0 - nulll) ) / (2.0 - M_)));
			float Gr = (1.0 - (_Gradient*0.9+0.1));
			float3 _ColorSSS_ = lerp(lerp(ColorSSS1.rgb,ColorSSS2.rgb,saturate((0.0 + ( (_Gradient - 1.0) * (1.0 - 0.0) ) / (LevelColor1 - 1.0)))),ColorSSS3.rgb,saturate((0.0 + ( (_Gradient - LevelColor2) * (1.0 - 0.0) ) / (0.0 - LevelColor2))));
			 float3 FinalResult = (lerp((_ColorSSS_*saturate(lerp(_Gradient,(_Gradient*Gr),(_Gradient*(Transmission+0.3))))),_ColorSSS_,Transmission)*(Intensity*3.0));
			return Out_ = FinalResult;
		}


		inline half4 LightingStandardSpecularCustom(SurfaceOutputStandardSpecularCustom s, half3 viewDir, UnityGI gi )
		{
			#if !DIRECTIONAL
			float3 lightAtten = gi.light.color;
			#else
			float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, _TransShadow );
			#endif
			half3 lightDir = gi.light.dir + s.Normal * _TransNormalDistortion;
			half transVdotL = pow( saturate( dot( viewDir, -lightDir ) ), _TransScattering );
			half3 translucency = lightAtten * (transVdotL * _TransDirect + gi.indirect.diffuse * _TransAmbient) * s.Translucency;
			half4 c = half4( s.Albedo * translucency * _Translucency, 0 );

			half3 transmission = max(0 , -dot(s.Normal, gi.light.dir)) * gi.light.color * s.Transmission;
			half4 d = half4(s.Albedo * transmission , 0);

			SurfaceOutputStandardSpecular r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Specular = s.Specular;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandardSpecular (r, viewDir, gi) + c + d;
		}

		inline void LightingStandardSpecularCustom_GI(SurfaceOutputStandardSpecularCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardSpecularCustom o )
		{
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			half3 tex2DNode12 = UnpackNormal( tex2D( _Normal, uv_Albedo ) );
			o.Normal = tex2DNode12;
			o.Albedo = ( _Tint * tex2D( _Albedo, uv_Albedo ) ).rgb;
			float3 newWorldNormal19 = (WorldNormalVector( i , tex2DNode12 ));
			float3 Normal2_g1 = newWorldNormal19;
			float2 uv_Depth = i.uv_texcoord * _Depth_ST.xy + _Depth_ST.zw;
			half4 tex2DNode7 = tex2D( _Depth, uv_Depth );
			float Depth2_g1 = tex2DNode7.r;
			float3 ColorSSS12_g1 = _Color1.rgb;
			float3 ColorSSS22_g1 = _Color2.rgb;
			float3 ColorSSS32_g1 = _Color3.rgb;
			float LevelColor12_g1 = 0.0;
			float LevelColor22_g1 = 0.0;
			float2 uv_Transmission = i.uv_texcoord * _Transmission_ST.xy + _Transmission_ST.zw;
			half4 tex2DNode25 = tex2D( _Transmission, uv_Transmission );
			float Transmission2_g1 = tex2DNode25.r;
			float Intensity2_g1 = _SSSintensity;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 lightDirection2_g1 = ase_worldlightDir;
			float3 Out_2_g1 = float3( 0,0,0 );
			float3 localSSS2_g1 = SSS2_g1( Normal2_g1 , Depth2_g1 , ColorSSS12_g1 , ColorSSS22_g1 , ColorSSS32_g1 , LevelColor12_g1 , LevelColor22_g1 , Transmission2_g1 , Intensity2_g1 , lightDirection2_g1 , Out_2_g1 );
			o.Emission = Out_2_g1;
			float2 uv_HeadSpecular = i.uv_texcoord * _HeadSpecular_ST.xy + _HeadSpecular_ST.zw;
			o.Specular = ( tex2D( _HeadSpecular, uv_HeadSpecular ) * _Specular ).rgb;
			half3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV30 = dot( newWorldNormal19, ase_worldViewDir );
			float ior30 = _IOR;
			ior30 = pow( ( 1-ior30 )/( 1+ior30 ), 2 );
			float fresnelNode30 = ( ior30 + ( 1.0 - ior30 ) * pow( 1.0 - fresnelNdotV30, 5 ) );
			o.Smoothness = ( _Smoothness * fresnelNode30 );
			float2 uv_AO = i.uv_texcoord * _AO_ST.xy + _AO_ST.zw;
			o.Occlusion = tex2D( _AO, uv_AO ).r;
			o.Transmission = tex2DNode25.rgb;
			o.Translucency = ( tex2DNode7 * _Color0 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardSpecularCustom keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
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
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
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
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandardSpecularCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardSpecularCustom, o )
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
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16301
672;841.6;1461;816;1382.235;595.7417;2.67596;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;17;-1016.736,-72.31985;Float;False;0;9;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;12;-566.9902,-73.27022;Float;True;Property;_Normal;Normal;10;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;32;38.16792,1167.848;Float;False;Property;_IOR;IOR;15;0;Create;True;0;0;False;0;0;0.96;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;19;64.57913,-224.5975;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;7;-567.9905,129.1298;Float;True;Property;_Depth;Depth;11;0;Create;True;0;0;False;0;None;ed266b4e9676b8e41802be6052d8f45c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;10;-505.058,-441.5712;Float;False;Property;_Tint;Tint;14;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;9;-560.7905,-261.6702;Float;True;Property;_Albedo;Albedo;9;0;Create;True;0;0;False;0;None;c1692629d7461774781cbb75a3c8b2eb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;20;-62.461,-569.0763;Float;False;Property;_SSSintensity;SSSintensity;17;0;Create;True;0;0;False;0;0;1.54;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;25;-680.5972,-4.447861;Float;True;Property;_Transmission;Transmission;21;0;Create;True;0;0;False;0;None;d542dd74334fa654a95f83b6a9495cc3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;6;-528.7906,325.7297;Float;False;Property;_Color0;Color 0;1;0;Create;True;0;0;False;0;0,0,0,0;0.226415,0.09291559,0.09291559,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;22;60.97088,70.47901;Float;False;Property;_Color2;Color 2;19;0;Create;True;0;0;False;0;0,0,0,0;0.3207546,0.2399607,0.1860982,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;23;59.91452,240.3633;Float;False;Property;_Color3;Color 3;18;0;Create;True;0;0;False;0;0,0,0,0;0.45283,0.2698049,0.2499109,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;16;-44.67231,511.963;Float;False;Property;_Specular;Specular;0;0;Create;True;0;0;False;0;0;0.57;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;27;-66.91969,609.8835;Float;True;Property;_HeadSpecular;HeadSpecular;12;0;Create;True;0;0;False;0;None;bfdb52a1fecaa2346ac0c50b81101aa6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;21;56.63535,-91.41142;Float;False;Property;_Color1;Color 1;20;0;Create;True;0;0;False;0;0,0,0,0;0.9811321,0.6484619,0.3285866,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;212.0298,973.2472;Float;False;Property;_Smoothness;Smoothness;16;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;30;318.8687,1144.953;Float;False;SchlickIOR;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;98.59587,-322.0663;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;28;-573.0217,498.9568;Float;True;Property;_AO;AO;13;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;343.8547,618.5494;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-93.79053,185.3298;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;18;564.8176,624.5451;Float;False;SSS;-1;;1;a4ca5d79f10f333459d2cc94232a3dbc;0;9;4;FLOAT3;0,0,0;False;3;FLOAT;0.5;False;8;FLOAT;0;False;9;FLOAT;0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;11;FLOAT;1;False;10;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;679.4497,1062.916;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;759.8079,0.6406744;Half;False;True;2;Half;ASEMaterialInspector;0;0;StandardSpecular;ASESampleShaders/Translucency;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;3;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;2;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;12;1;17;0
WireConnection;19;0;12;0
WireConnection;9;1;17;0
WireConnection;30;0;19;0
WireConnection;30;2;32;0
WireConnection;11;0;10;0
WireConnection;11;1;9;0
WireConnection;26;0;27;0
WireConnection;26;1;16;0
WireConnection;8;0;7;0
WireConnection;8;1;6;0
WireConnection;18;4;19;0
WireConnection;18;3;7;0
WireConnection;18;5;21;0
WireConnection;18;6;22;0
WireConnection;18;7;23;0
WireConnection;18;11;20;0
WireConnection;18;10;25;0
WireConnection;31;0;29;0
WireConnection;31;1;30;0
WireConnection;0;0;11;0
WireConnection;0;1;12;0
WireConnection;0;2;18;0
WireConnection;0;3;26;0
WireConnection;0;4;31;0
WireConnection;0;5;28;0
WireConnection;0;6;25;0
WireConnection;0;7;8;0
ASEEND*/
//CHKSM=D213DA8C0964EFFE20F0848795E047756BFB6CC6