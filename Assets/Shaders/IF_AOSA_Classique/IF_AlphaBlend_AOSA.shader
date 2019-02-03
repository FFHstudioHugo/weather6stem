// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Immersive Factory/AlphaBlend/AOSA"
{
	Properties
	{
		[HDR]_Color("Color", Color) = (1,1,1,0)
		_AlbedoMetalness("Albedo Metalness", 2D) = "black" {}
		_AOSmoothAlphaOther("AO Smooth Alpha Other", 2D) = "white" {}
		_SmothnessMultiplier("Smothness Multiplier", Range( 0 , 1)) = 1
		_MetallicMultiplier("Metallic Multiplier", Range( 0 , 1)) = 1
		_Normal("Normal", 2D) = "bump" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 5.0
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float4 _Color;
		uniform sampler2D _AlbedoMetalness;
		uniform float4 _AlbedoMetalness_ST;
		uniform half _MetallicMultiplier;
		uniform half _SmothnessMultiplier;
		uniform sampler2D _AOSmoothAlphaOther;
		uniform float4 _AOSmoothAlphaOther_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float2 uv_AlbedoMetalness = i.uv_texcoord * _AlbedoMetalness_ST.xy + _AlbedoMetalness_ST.zw;
			float4 tex2DNode81 = tex2D( _AlbedoMetalness, uv_AlbedoMetalness );
			o.Albedo = ( _Color * tex2DNode81 ).rgb;
			float clampResult89 = clamp( ( _MetallicMultiplier * tex2DNode81.a ) , 0.0 , 1.0 );
			o.Metallic = clampResult89;
			float2 uv_AOSmoothAlphaOther = i.uv_texcoord * _AOSmoothAlphaOther_ST.xy + _AOSmoothAlphaOther_ST.zw;
			float4 tex2DNode86 = tex2D( _AOSmoothAlphaOther, uv_AOSmoothAlphaOther );
			float clampResult83 = clamp( ( _SmothnessMultiplier * tex2DNode86.g ) , 0.0 , 1.0 );
			o.Smoothness = clampResult83;
			o.Occlusion = tex2DNode86.r;
			o.Alpha = ( tex2DNode86.b * i.vertexColor.a );
		}

		ENDCG
		CGPROGRAM
		#pragma only_renderers d3d11 glcore gles gles3 d3d11_9x 
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				half4 color : COLOR0;
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
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.vertexColor = IN.color;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "/ImmersiveShader/MSAO"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15500
-1913;29;1906;1004;-1084.708;782.0347;1.47808;True;False
Node;AmplifyShaderEditor.SamplerNode;81;1638.229,-487.3843;Float;True;Property;_AlbedoMetalness;Albedo Metalness;1;0;Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;86;1624.441,-270.1603;Float;True;Property;_AOSmoothAlphaOther;AO Smooth Alpha Other;2;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;87;2079.126,-425.5845;Half;False;Property;_MetallicMultiplier;Metallic Multiplier;4;0;Create;True;0;0;False;0;1;0.25;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;2006.484,185.4062;Half;False;Property;_SmothnessMultiplier;Smothness Multiplier;3;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;79;1884.693,-726.5505;Float;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;False;0;1,1,1,0;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;2424.031,-360.2526;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;90;2805.19,341.3061;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;2408.336,166.4117;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;89;2680.848,-311.775;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;85;1655.372,-42.73273;Float;True;Property;_Normal;Normal;5;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;83;2661.267,152.1916;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;2223.419,-576.4096;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;3156.974,152.1118;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3507.279,-178.4887;Float;False;True;7;Float;ASEMaterialInspector;0;0;Standard;Immersive Factory/AlphaBlend/AOSA;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;1;True;True;0;False;Transparent;AlphaBlendDebug;Transparent;All;False;True;True;True;True;False;True;False;False;False;False;False;False;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;/ImmersiveShader/MSAO;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;88;0;87;0
WireConnection;88;1;81;4
WireConnection;80;0;78;0
WireConnection;80;1;86;2
WireConnection;89;0;88;0
WireConnection;83;0;80;0
WireConnection;82;0;79;0
WireConnection;82;1;81;0
WireConnection;91;0;86;3
WireConnection;91;1;90;4
WireConnection;0;0;82;0
WireConnection;0;1;85;0
WireConnection;0;3;89;0
WireConnection;0;4;83;0
WireConnection;0;5;86;1
WireConnection;0;9;91;0
ASEEND*/
//CHKSM=0E62A980B44BC35725FCB4C3E15AF529F10A3991