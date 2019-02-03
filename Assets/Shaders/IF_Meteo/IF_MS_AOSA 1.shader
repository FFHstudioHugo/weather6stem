// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Immersive Factory/Opaque/MeteoSystem/Ground(AOSA)"
{
	Properties
	{
		_AlbedoMetal("Albedo Metal", 2D) = "black" {}
		_AOSAE("AOSA(E)", 2D) = "gray" {}
		_Normal("Normal", 2D) = "bump" {}
		[HDR]_BaseColor("BaseColor", Color) = (1,1,1,0)
		_BaseLayerTiling("BaseLayerTiling", Float) = 0.5
		_BaseMetalness("Base Metalness", Range( 0 , 1)) = 0
		_BaseSmoothness("Base Smoothness", Range( 0 , 1)) = 1
		[HDR]_Snow_Color("Snow_Color", Color) = (0,0,0,0)
		_SnowNormal("SnowNormal", 2D) = "bump" {}
		_SnowSMH("SnowSMH", 2D) = "white" {}
		_SnowCoverageTiling("SnowCoverageTiling", Range( 0 , 0.5)) = 0.5
		_SnowDetailTiling("SnowDetailTiling", Range( 0 , 0.5)) = 0.5
		_SnowHeight("SnowHeight", Float) = 0
		_Snow_Smothness("Snow_Smothness", Float) = 0
		_Puddles_Tilling("Puddles_Tilling", Range( 0 , 1)) = 0
		_Puddles_Forces("Puddles_Forces", Range( 0 , 1)) = 0
		_RainMask("RainMask", 2D) = "white" {}
		_Puddles_Flipbook("Puddles_Flipbook", 2D) = "bump" {}
		_Wet_Coverage_Tiling("Wet_Coverage_Tiling", Float) = 0
		_TessValue( "Max Tessellation", Range( 1, 32 ) ) = 12
		_TessMin( "Tess Min Distance", Float ) = 14.6
		_TessMax( "Tess Max Distance", Float ) = 28.14
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "DisableBatching" = "True" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#pragma target 5.0
		#pragma exclude_renderers xbox360 xboxone ps4 psp2 n3ds wiiu 
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
		};

		uniform sampler2D _SnowSMH;
		uniform float _SnowCoverageTiling;
		uniform float _SnowHeight;
		uniform float _GlobalSnowness;
		uniform sampler2D _SnowNormal;
		uniform float _SnowDetailTiling;
		uniform sampler2D _Puddles_Flipbook;
		uniform float _Puddles_Tilling;
		uniform float _Puddles_Forces;
		uniform sampler2D _Normal;
		uniform float _BaseLayerTiling;
		uniform sampler2D _RainMask;
		uniform float _Wet_Coverage_Tiling;
		uniform float _GlobalWetness;
		uniform float4 _Snow_Color;
		uniform half4 _BaseColor;
		uniform sampler2D _AlbedoMetal;
		uniform float _BaseMetalness;
		uniform sampler2D _AOSAE;
		uniform half _BaseSmoothness;
		uniform float _Snow_Smothness;
		uniform float _TessValue;
		uniform float _TessMin;
		uniform float _TessMax;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, _TessMin, _TessMax, _TessValue );
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float temp_output_9_0_g533 = _SnowCoverageTiling;
			float2 appendResult7_g533 = (float2((0.5 + (( ase_worldPos.x * temp_output_9_0_g533 ) - 0.0) * (1.0 - 0.5) / (1.0 - 0.0)) , (0.5 + (( ase_worldPos.z * temp_output_9_0_g533 ) - 0.0) * (1.0 - 0.5) / (1.0 - 0.0))));
			float2 temp_output_55_0_g532 = appendResult7_g533;
			float4 tex2DNode57_g532 = tex2Dlod( _SnowSMH, float4( temp_output_55_0_g532, 0, 0.0) );
			float temp_output_82_0_g532 = ( _GlobalSnowness * 5.0 );
			float temp_output_106_0_g532 = ( tex2Dlod( _SnowSMH, float4( temp_output_55_0_g532, 0, 0.0) ).b * temp_output_82_0_g532 );
			float clampResult100_g532 = clamp( ( temp_output_82_0_g532 + -3.0 ) , 0.0 , 1.0 );
			float clampResult105_g532 = clamp( ( ( temp_output_106_0_g532 * temp_output_106_0_g532 * 4.0 ) + clampResult100_g532 ) , 0.0 , 1.0 );
			float temp_output_114_0_g532 = ( 1.0 - clampResult105_g532 );
			float Coverage80_g532 = temp_output_114_0_g532;
			float4 temp_cast_0 = (Coverage80_g532).xxxx;
			float div116_g532=256.0/float(61);
			float4 posterize116_g532 = ( floor( temp_cast_0 * div116_g532 ) / div116_g532 );
			float lerpResult71_g532 = lerp( ( tex2DNode57_g532.b * _SnowHeight ) , 0.0 , posterize116_g532.r);
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( lerpResult71_g532 * ase_vertexNormal );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float temp_output_9_0_g534 = _SnowDetailTiling;
			float2 appendResult7_g534 = (float2((0.5 + (( ase_worldPos.x * temp_output_9_0_g534 ) - 0.0) * (1.0 - 0.5) / (1.0 - 0.0)) , (0.5 + (( ase_worldPos.z * temp_output_9_0_g534 ) - 0.0) * (1.0 - 0.5) / (1.0 - 0.0))));
			float temp_output_9_0_g530 = _Puddles_Tilling;
			float2 appendResult7_g530 = (float2((0.5 + (( ase_worldPos.x * temp_output_9_0_g530 ) - 0.0) * (1.0 - 0.5) / (1.0 - 0.0)) , (0.5 + (( ase_worldPos.z * temp_output_9_0_g530 ) - 0.0) * (1.0 - 0.5) / (1.0 - 0.0))));
			float temp_output_4_0_g531 = 4.0;
			float temp_output_5_0_g531 = 4.0;
			float2 appendResult7_g531 = (float2(temp_output_4_0_g531 , temp_output_5_0_g531));
			float totalFrames39_g531 = ( temp_output_4_0_g531 * temp_output_5_0_g531 );
			float2 appendResult8_g531 = (float2(totalFrames39_g531 , temp_output_5_0_g531));
			float mulTime68_g528 = _Time.y * 12.0;
			float clampResult42_g531 = clamp( 2.0 , 0.0001 , ( totalFrames39_g531 - 1.0 ) );
			float temp_output_35_0_g531 = frac( ( ( mulTime68_g528 + clampResult42_g531 ) / totalFrames39_g531 ) );
			float2 appendResult29_g531 = (float2(temp_output_35_0_g531 , ( 1.0 - temp_output_35_0_g531 )));
			float2 temp_output_15_0_g531 = ( ( appendResult7_g530 / appendResult7_g531 ) + ( floor( ( appendResult8_g531 * appendResult29_g531 ) ) / appendResult7_g531 ) );
			float3 tex2DNode69_g528 = UnpackNormal( tex2D( _Puddles_Flipbook, temp_output_15_0_g531 ) );
			float2 appendResult71_g528 = (float2(tex2DNode69_g528.g , tex2DNode69_g528.r));
			float3 appendResult72_g528 = (float3(( appendResult71_g528 * _Puddles_Forces ) , tex2DNode69_g528.b));
			float temp_output_9_0_g397 = _BaseLayerTiling;
			float2 appendResult7_g397 = (float2((0.5 + (( ase_worldPos.x * temp_output_9_0_g397 ) - 0.0) * (1.0 - 0.5) / (1.0 - 0.0)) , (0.5 + (( ase_worldPos.z * temp_output_9_0_g397 ) - 0.0) * (1.0 - 0.5) / (1.0 - 0.0))));
			float2 temp_output_474_0 = appendResult7_g397;
			float3 BaseNormal229 = UnpackNormal( tex2D( _Normal, temp_output_474_0 ) );
			float temp_output_9_0_g529 = _Wet_Coverage_Tiling;
			float2 appendResult7_g529 = (float2((0.5 + (( ase_worldPos.x * temp_output_9_0_g529 ) - 0.0) * (1.0 - 0.5) / (1.0 - 0.0)) , (0.5 + (( ase_worldPos.z * temp_output_9_0_g529 ) - 0.0) * (1.0 - 0.5) / (1.0 - 0.0))));
			float temp_output_30_0_g528 = ( _GlobalWetness * 15.0 );
			float clampResult75_g528 = clamp( ( temp_output_30_0_g528 + -10.0 ) , 0.0 , 20.0 );
			float clampResult31_g528 = clamp( ( ( tex2D( _RainMask, appendResult7_g529 ).r * temp_output_30_0_g528 ) + clampResult75_g528 ) , 0.0 , 1.0 );
			float temp_output_38_0_g528 = ( 1.0 - clampResult31_g528 );
			float clampResult67_g528 = clamp( temp_output_38_0_g528 , 0.0 , 1.0 );
			float3 lerpResult62_g528 = lerp( appendResult72_g528 , BaseNormal229 , clampResult67_g528);
			float temp_output_9_0_g533 = _SnowCoverageTiling;
			float2 appendResult7_g533 = (float2((0.5 + (( ase_worldPos.x * temp_output_9_0_g533 ) - 0.0) * (1.0 - 0.5) / (1.0 - 0.0)) , (0.5 + (( ase_worldPos.z * temp_output_9_0_g533 ) - 0.0) * (1.0 - 0.5) / (1.0 - 0.0))));
			float2 temp_output_55_0_g532 = appendResult7_g533;
			float temp_output_82_0_g532 = ( _GlobalSnowness * 5.0 );
			float temp_output_106_0_g532 = ( tex2D( _SnowSMH, temp_output_55_0_g532 ).b * temp_output_82_0_g532 );
			float clampResult100_g532 = clamp( ( temp_output_82_0_g532 + -3.0 ) , 0.0 , 1.0 );
			float clampResult105_g532 = clamp( ( ( temp_output_106_0_g532 * temp_output_106_0_g532 * 4.0 ) + clampResult100_g532 ) , 0.0 , 1.0 );
			float temp_output_114_0_g532 = ( 1.0 - clampResult105_g532 );
			float3 lerpResult119_g532 = lerp( UnpackNormal( tex2D( _SnowNormal, appendResult7_g534 ) ) , lerpResult62_g528 , temp_output_114_0_g532);
			o.Normal = lerpResult119_g532;
			float4 tex2DNode184 = tex2D( _AlbedoMetal, temp_output_474_0 );
			float4 BaseColor227 = ( _BaseColor * tex2DNode184 );
			float3 temp_output_1_0_g528 = BaseColor227.rgb;
			float3 lerpResult14_g528 = lerp( ( temp_output_1_0_g528 * 0.5 ) , temp_output_1_0_g528 , temp_output_38_0_g528);
			float4 lerpResult52_g532 = lerp( _Snow_Color , float4( lerpResult14_g528 , 0.0 ) , ( 1.0 - clampResult105_g532 ));
			o.Albedo = lerpResult52_g532.rgb;
			float BaseMetalness261 = ( tex2DNode184.b * _BaseMetalness );
			float lerpResult15_g528 = lerp( BaseMetalness261 , 0.0 , temp_output_38_0_g528);
			float temp_output_824_6 = lerpResult15_g528;
			o.Metallic = temp_output_824_6;
			float4 tex2DNode118 = tex2D( _AOSAE, temp_output_474_0 );
			float temp_output_190_0 = ( tex2DNode118.g * _BaseSmoothness );
			half BaseSmooth232 = temp_output_190_0;
			float lerpResult16_g528 = lerp( 1.0 , BaseSmooth232 , clampResult67_g528);
			float lerpResult61_g532 = lerp( lerpResult16_g528 , ( _Snow_Smothness * clampResult105_g532 ) , clampResult105_g532);
			float clampResult800 = clamp( lerpResult61_g532 , 0.0 , 1.0 );
			o.Smoothness = clampResult800;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15600
821;197;952;836;-4222.379;1238.967;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;257;3439.204,261.304;Float;False;2116.456;1342.795;BaseLayer;16;232;231;190;229;118;188;192;106;191;184;261;294;227;474;817;816;SamplerBaseLayer;0.1665316,1,0,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;294;3467.027,1092.093;Float;False;Property;_BaseLayerTiling;BaseLayerTiling;4;0;Create;True;0;0;False;0;0.5;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;474;3594.878,887.619;Float;False;WorldPos;-1;;397;739ed574e5a46e2438e5d1b0fa07ab88;0;1;9;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;118;3950.35,944.7677;Float;True;Property;_AOSAE;AOSA(E);1;0;Create;True;0;0;False;0;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;191;4294.353,411.5146;Half;False;Property;_BaseColor;BaseColor;3;1;[HDR];Create;True;0;0;False;0;1,1,1,0;0.7490196,0.7490196,0.7490196,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;184;3937.325,640.0163;Float;True;Property;_AlbedoMetal;Albedo Metal;0;0;Create;True;0;0;False;0;e2de209c5d00df84597ec329a59f31e4;00d034bb5072d8043a98b8a4aae5a40d;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;188;4050.645,1157.828;Half;False;Property;_BaseSmoothness;Base Smoothness;6;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;817;4212.213,848.3734;Float;False;Property;_BaseMetalness;Base Metalness;5;0;Create;True;0;0;False;0;0;0.94;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;575;4246.134,-553.5447;Float;False;Global;_GlobalWetness;_GlobalWetness;16;0;Create;True;0;0;False;0;0;0.67;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;106;3950.155,1280.736;Float;True;Property;_Normal;Normal;2;0;Create;True;0;0;False;0;None;7ddcba51d9fc0894d98b4ba77fbdfbd7;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;192;4776.959,457.1152;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;190;4389.193,1033.036;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;816;4520.767,746.8149;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;229;4463.038,1335.252;Float;False;BaseNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;233;3549.77,-1172.969;Float;True;227;BaseColor;0;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;574;3825.107,-395.7838;Float;True;Property;_Puddles_Flipbook;Puddles_Flipbook;19;0;Create;True;0;0;False;0;None;7f69c9af8f048cf41a3c9a70d5c21292;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;580;4269.987,-363.1422;Float;False;Property;_Wet_Coverage_Tiling;Wet_Coverage_Tiling;20;0;Create;True;0;0;False;0;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;261;5020.071,726.5337;Float;True;BaseMetalness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;232;4889.156,1122.428;Half;True;BaseSmooth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;578;4269.443,-277.1328;Float;False;Property;_Puddles_Forces;Puddles_Forces;17;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;373;4606.567,-125.0938;Float;False;232;BaseSmooth;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;579;3791.174,-213.4304;Float;True;Property;_RainMask;RainMask;18;0;Create;True;0;0;False;0;None;7f1cd443fabe3b34ab368f436b25ebf4;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;577;4274.73,-458.1974;Float;False;Property;_Puddles_Tilling;Puddles_Tilling;16;0;Create;True;0;0;False;0;0;0.269;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;655;4709.506,-424.4209;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;15;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;227;5023.987,489.1198;Float;True;BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;378;4603.1,-52.98816;Float;False;261;BaseMetalness;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;380;4716.21,-1427.578;Float;False;Global;_GlobalSnowness;_GlobalSnowness;12;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;318;4711.246,-984.228;Float;False;Property;_SnowDetailTiling;SnowDetailTiling;12;0;Create;True;0;0;False;0;0.5;0.216;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;382;4763.342,-1165.871;Float;False;Property;_SnowHeight;SnowHeight;13;0;Create;True;0;0;False;0;0;1.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;807;5113.316,-1363.164;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;824;4932.586,-387.8928;Float;False;Wetness;-1;;528;fa760172b9af07b41ba40c7d24e15934;0;12;76;FLOAT;0;False;30;FLOAT;0.5;False;10;SAMPLER2D;0,0,0;False;13;FLOAT;1;False;26;FLOAT;1;False;33;FLOAT;1;False;20;SAMPLER2D;0,0,0;False;1;FLOAT3;0,0,0;False;3;FLOAT;0;False;2;FLOAT;1;False;4;FLOAT3;128,128,255;False;5;FLOAT;0;False;5;FLOAT3;0;FLOAT;6;FLOAT;7;FLOAT3;8;FLOAT4;9
Node;AmplifyShaderEditor.RangedFloatNode;383;4751.821,-1242.406;Float;False;Property;_Snow_Smothness;Snow_Smothness;14;0;Create;True;0;0;False;0;0;0.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;384;4755.563,-664.7612;Float;False;Property;_Snow_Color;Snow_Color;7;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0.7432754,0.8558929,0.8603976,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;386;4436.749,-1174.022;Float;True;Property;_SnowSMH;SnowSMH;9;0;Create;True;0;0;False;0;663fd7e916c14644facb141679e7b564;663fd7e916c14644facb141679e7b564;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;328;4717.927,-1338.602;Float;False;Property;_SnowCoverageTiling;SnowCoverageTiling;11;0;Create;True;0;0;False;0;0.5;0.11;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;810;4620.75,-895.1274;Float;True;Property;_SnowNormal;SnowNormal;8;0;Create;True;0;0;False;0;663fd7e916c14644facb141679e7b564;c6e484574ffae05409d80dcc43b98b4e;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;804;4721.735,-1080.07;Float;False;Property;_Snow_Metalness;Snow_Metalness;15;0;Create;True;0;0;False;0;0.25;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;522;5607.269,-585.0305;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;821;5312.082,-1015.584;Float;True;Snowness;-1;;532;5b78aa2131329994baf3b1644699987d;0;13;126;FLOAT3;0,0,0;False;47;FLOAT;1;False;120;SAMPLER2D;;False;82;FLOAT;0.52;False;75;FLOAT;0.120817;False;73;FLOAT;1;False;70;FLOAT;0.2;False;83;SAMPLER2D;;False;76;COLOR;0.7224546,0.8018868,0.7919725,0;False;53;FLOAT3;0.9339623,0.9339623,0.9339623;False;63;FLOAT;0.1415094;False;68;FLOAT;0;False;44;FLOAT;1;False;5;COLOR;48;FLOAT;36;FLOAT;56;FLOAT3;74;FLOAT;37
Node;AmplifyShaderEditor.DynamicAppendNode;231;4623.3,980.7385;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClampOpNode;800;5759.905,-834.5172;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;799;5773.396,-973.2783;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;563;4216.343,-917.5657;Float;False;229;BaseNormal;0;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;564;4421.314,-1387.722;Float;True;Property;_Snow_Normal;Snow_Normal;10;1;[Normal];Create;True;0;0;False;0;None;c6e484574ffae05409d80dcc43b98b4e;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;523;5751.167,-679.3469;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;6023.714,-949.1265;Float;False;True;7;Float;ASEMaterialInspector;0;0;Standard;Immersive Factory/Opaque/MeteoSystem/Ground(AOSA);False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;False;False;False;False;False;False;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;0;12;14.6;28.14;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;21;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;474;9;294;0
WireConnection;118;1;474;0
WireConnection;184;1;474;0
WireConnection;106;1;474;0
WireConnection;192;0;191;0
WireConnection;192;1;184;0
WireConnection;190;0;118;2
WireConnection;190;1;188;0
WireConnection;816;0;184;3
WireConnection;816;1;817;0
WireConnection;229;0;106;0
WireConnection;261;0;816;0
WireConnection;232;0;190;0
WireConnection;655;0;575;0
WireConnection;227;0;192;0
WireConnection;807;0;380;0
WireConnection;824;30;655;0
WireConnection;824;10;574;0
WireConnection;824;13;577;0
WireConnection;824;26;578;0
WireConnection;824;33;580;0
WireConnection;824;20;579;0
WireConnection;824;1;233;0
WireConnection;824;3;373;0
WireConnection;824;2;378;0
WireConnection;824;4;229;0
WireConnection;821;126;824;8
WireConnection;821;47;328;0
WireConnection;821;120;810;0
WireConnection;821;82;807;0
WireConnection;821;75;804;0
WireConnection;821;73;382;0
WireConnection;821;70;383;0
WireConnection;821;83;386;0
WireConnection;821;76;384;0
WireConnection;821;53;824;0
WireConnection;821;63;824;6
WireConnection;821;68;824;7
WireConnection;821;44;318;0
WireConnection;231;0;118;1
WireConnection;231;1;190;0
WireConnection;231;3;118;4
WireConnection;800;0;821;36
WireConnection;799;0;821;56
WireConnection;523;0;821;37
WireConnection;523;1;522;0
WireConnection;0;0;821;48
WireConnection;0;1;821;74
WireConnection;0;3;824;6
WireConnection;0;4;800;0
WireConnection;0;11;523;0
ASEEND*/
//CHKSM=255E4CE1C739668B38E4B7812CDACCBCE68267F7