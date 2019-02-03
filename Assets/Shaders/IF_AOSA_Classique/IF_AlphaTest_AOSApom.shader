// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Immersive Factory/AlphaTest/AOSA POM"
{
	Properties
	{
		[HDR]_Color("Color", Color) = (1,1,1,0)
		[HDR]_Transparent_Color("Transparent_Color", Color) = (0.4649787,0.764151,0.7151955,0)
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_AlbedoMetal("Albedo Metal", 2D) = "white" {}
		_NormalScale("Normal Scale", Range( 0 , 2)) = 1
		_Normal("Normal", 2D) = "bump" {}
		_MetallicMultiplier("Metallic Multiplier", Range( 0 , 2)) = 1
		_SmoothnessMultiplier("Smoothness Multiplier", Range( 0 , 2)) = 1
		_AOSAH("AOSAH", 2D) = "white" {}
		_POMScale("POM Scale", Range( -0.2 , 0.2)) = 0
		_RefPlane("Ref Plane", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 5.0
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
			float2 uv_texcoord;
			float3 viewDir;
			INTERNAL_DATA
			float3 worldNormal;
			float3 worldPos;
		};

		uniform half _NormalScale;
		uniform sampler2D _Normal;
		uniform sampler2D _AOSAH;
		uniform half _POMScale;
		uniform half _RefPlane;
		uniform float4 _AOSAH_ST;
		uniform float4 _Transparent_Color;
		uniform float4 _Color;
		uniform sampler2D _AlbedoMetal;
		uniform half _MetallicMultiplier;
		uniform half _SmoothnessMultiplier;
		uniform float _Cutoff = 0.5;


		inline float2 POM( sampler2D heightMap, float2 uvs, float2 dx, float2 dy, float3 normalWorld, float3 viewWorld, float3 viewDirTan, int minSamples, int maxSamples, float parallax, float refPlane, float2 tilling, float2 curv, int index )
		{
			float3 result = 0;
			int stepIndex = 0;
			int numSteps = ( int )lerp( (float)maxSamples, (float)minSamples, saturate( dot( normalWorld, viewWorld ) ) );
			float layerHeight = 1.0 / numSteps;
			float2 plane = parallax * ( viewDirTan.xy / viewDirTan.z );
			uvs += refPlane * plane;
			float2 deltaTex = -plane * layerHeight;
			float2 prevTexOffset = 0;
			float prevRayZ = 1.0f;
			float prevHeight = 0.0f;
			float2 currTexOffset = deltaTex;
			float currRayZ = 1.0f - layerHeight;
			float currHeight = 0.0f;
			float intersection = 0;
			float2 finalTexOffset = 0;
			while ( stepIndex < numSteps + 1 )
			{
				currHeight = tex2Dgrad( heightMap, uvs + currTexOffset, dx, dy ).a;
				if ( currHeight > currRayZ )
				{
					stepIndex = numSteps + 1;
				}
				else
				{
					stepIndex++;
					prevTexOffset = currTexOffset;
					prevRayZ = currRayZ;
					prevHeight = currHeight;
					currTexOffset += deltaTex;
					currRayZ -= layerHeight;
				}
			}
			int sectionSteps = 4;
			int sectionIndex = 0;
			float newZ = 0;
			float newHeight = 0;
			while ( sectionIndex < sectionSteps )
			{
				intersection = ( prevHeight - prevRayZ ) / ( prevHeight - currHeight + currRayZ - prevRayZ );
				finalTexOffset = prevTexOffset + intersection * deltaTex;
				newZ = prevRayZ - intersection * layerHeight;
				newHeight = tex2Dgrad( heightMap, uvs + finalTexOffset, dx, dy ).a;
				if ( newHeight > newZ )
				{
					currTexOffset = finalTexOffset;
					currHeight = newHeight;
					currRayZ = newZ;
					deltaTex = intersection * deltaTex;
					layerHeight = intersection * layerHeight;
				}
				else
				{
					prevTexOffset = finalTexOffset;
					prevHeight = newHeight;
					prevRayZ = newZ;
					deltaTex = ( 1 - intersection ) * deltaTex;
					layerHeight = ( 1 - intersection ) * layerHeight;
				}
				sectionIndex++;
			}
			return uvs + finalTexOffset;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 OffsetPOM86 = POM( _AOSAH, i.uv_texcoord, ddx(i.uv_texcoord), ddy(i.uv_texcoord), ase_worldNormal, ase_worldViewDir, i.viewDir, 128, 128, _POMScale, _RefPlane, _AOSAH_ST.xy, float2(0,0), 0 );
			float temp_output_89_0 = ddx( i.uv_texcoord.x );
			float2 temp_cast_0 = (temp_output_89_0).xx;
			float temp_output_88_0 = ddy( i.uv_texcoord.y );
			float2 temp_cast_1 = (temp_output_88_0).xx;
			o.Normal = UnpackScaleNormal( tex2D( _Normal, OffsetPOM86, temp_cast_0, temp_cast_1 ), _NormalScale );
			float2 temp_cast_2 = (temp_output_89_0).xx;
			float2 temp_cast_3 = (temp_output_88_0).xx;
			float4 tex2DNode39 = tex2D( _AlbedoMetal, OffsetPOM86, temp_cast_2, temp_cast_3 );
			float2 temp_cast_4 = (temp_output_89_0).xx;
			float2 temp_cast_5 = (temp_output_88_0).xx;
			float4 tex2DNode4 = tex2D( _AOSAH, OffsetPOM86, temp_cast_4, temp_cast_5 );
			float clampResult57 = clamp( tex2DNode4.b , 0.0 , 1.0 );
			float4 lerpResult73 = lerp( _Transparent_Color , ( _Color * tex2DNode39 ) , pow( clampResult57 , 16.28 ));
			o.Albedo = lerpResult73.rgb;
			float clampResult81 = clamp( ( tex2DNode39.a * _MetallicMultiplier ) , 0.0 , 1.0 );
			o.Metallic = clampResult81;
			float clampResult78 = clamp( ( _SmoothnessMultiplier * tex2DNode4.g ) , 0.0 , 1.0 );
			o.Smoothness = clampResult78;
			o.Occlusion = tex2DNode4.r;
			o.Alpha = 1;
			clip( tex2DNode4.b - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma only_renderers d3d11 glcore gles gles3 d3d11_9x 
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred 

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
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
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
	Fallback "/ImmersiveShader/MSAO"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15600
-1913;23;1906;1010;379.5812;1214.872;1.758079;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;90;206.6876,-344.7402;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;85;178.1934,332.3016;Half;False;Property;_RefPlane;Ref Plane;10;0;Create;True;0;0;False;0;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;166.6522,45.45143;Half;False;Property;_POMScale;POM Scale;9;0;Create;True;0;0;False;0;0;0.06;-0.2;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;84;283.007,142.7515;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;92;42.6252,-182.9501;Float;True;Property;_AOSAH;AOSAH;8;0;Create;True;0;0;False;0;None;15a25740d450b8e40b8b24b150a14d95;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.DdxOpNode;89;605.0118,-363.1841;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DdyOpNode;88;618.3904,-269.4579;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxOcclusionMappingNode;86;758.35,15.97054;Float;False;3;128;False;-1;128;False;-1;4;0.02;0;False;1,1;False;0,0;Texture2D;7;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;2;FLOAT;0.02;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT2;0,0;False;6;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;4;1415.584,-18.31514;Float;True;Property;_AOSAHf;AOSAHf;4;0;Create;True;0;0;False;0;None;81e1bdf295d3cb4498c272ed84a5593f;True;0;False;white;Auto;False;Object;-1;Derivative;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;74;1842.697,367.4477;Half;False;Property;_SmoothnessMultiplier;Smoothness Multiplier;7;0;Create;True;0;0;False;0;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;1833.564,-80.17213;Half;False;Property;_MetallicMultiplier;Metallic Multiplier;6;0;Create;True;0;0;False;0;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;70;1760.604,-818.6651;Float;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;False;0;1,1,1,0;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;39;1408.146,-498.628;Float;True;Property;_AlbedoMetal;Albedo Metal;3;0;Create;True;0;0;False;0;None;4652e881edd715a4394b223802bc2615;True;0;False;white;Auto;False;Object;-1;Derivative;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;57;2052.197,-459.1223;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;913.4042,341.3357;Half;False;Property;_NormalScale;Normal Scale;4;0;Create;True;0;0;False;0;1;0.5;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;72;2448.85,-720.3467;Float;False;Property;_Transparent_Color;Transparent_Color;1;1;[HDR];Create;True;0;0;False;0;0.4649787,0.764151,0.7151955,0;0.3773585,0.3773585,0.3773585,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;58;2288.297,-460.0323;Float;True;2;0;FLOAT;0;False;1;FLOAT;16.28;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;2308.039,303.4296;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;1.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;2168.204,-127.7768;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;1.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;2064.272,-706.9787;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;73;2641.728,-504.9134;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;78;2571.336,275.4767;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;1413.705,-248.3704;Float;True;Property;_Normal;Normal;5;0;Create;True;0;0;False;0;None;3ac75f515cd403846a12fa477492f900;True;0;True;bump;Auto;True;Object;-1;Derivative;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;81;2404.553,-128.8107;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3137.976,-192.6031;Float;False;True;7;Float;ASEMaterialInspector;0;0;Standard;Immersive Factory/AlphaTest/AOSA POM;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;AlphaBlendDebug;AlphaTest;ForwardOnly;False;True;True;True;True;False;True;False;False;False;False;False;False;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;/ImmersiveShader/MSAO;2;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;89;0;90;1
WireConnection;88;0;90;2
WireConnection;86;0;90;0
WireConnection;86;1;92;0
WireConnection;86;2;83;0
WireConnection;86;3;84;0
WireConnection;86;4;85;0
WireConnection;4;0;92;0
WireConnection;4;1;86;0
WireConnection;4;3;89;0
WireConnection;4;4;88;0
WireConnection;39;1;86;0
WireConnection;39;3;89;0
WireConnection;39;4;88;0
WireConnection;57;0;4;3
WireConnection;58;0;57;0
WireConnection;67;0;74;0
WireConnection;67;1;4;2
WireConnection;80;0;39;4
WireConnection;80;1;79;0
WireConnection;69;0;70;0
WireConnection;69;1;39;0
WireConnection;73;0;72;0
WireConnection;73;1;69;0
WireConnection;73;2;58;0
WireConnection;78;0;67;0
WireConnection;3;1;86;0
WireConnection;3;3;89;0
WireConnection;3;4;88;0
WireConnection;3;5;93;0
WireConnection;81;0;80;0
WireConnection;0;0;73;0
WireConnection;0;1;3;0
WireConnection;0;3;81;0
WireConnection;0;4;78;0
WireConnection;0;5;4;1
WireConnection;0;10;4;3
ASEEND*/
//CHKSM=FCF4408A8D058BA843A5166B4A3A7E31A5E66C4C