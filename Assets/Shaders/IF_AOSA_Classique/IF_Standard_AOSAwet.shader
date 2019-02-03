// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Immersive Factory/Opaque/AOSA Wet"
{
	Properties
	{
		[HDR]_Color("Color", Color) = (1,1,1,0)
		[KeywordEnum(Off,On,WithMask)] _ColorVariation("Color Variation", Float) = 0
		_AlbedoMetal("Albedo Metal", 2D) = "white" {}
		[KeywordEnum(off,AlphaChannelMask,SeparateMap)] _Emissive("Emissive", Float) = 1
		_EmmissiveMap("EmmissiveMap", 2D) = "black" {}
		_AOSAH("AOSAH", 2D) = "white" {}
		_EmissiveMultiplier("Emissive Multiplier", Range( 0 , 2)) = 0
		_MetalnessMultiplier("Metalness Multiplier", Range( 0 , 2)) = 1
		_SmothnessMultiplier("Smothness Multiplier", Range( 0 , 2)) = 1
		_Normal("Normal", 2D) = "bump" {}
		[Toggle(_WORLDSPACEGROUND_ON)] _WorldSpaceGround("WorldSpace Ground", Float) = 0
		_WSGroundTiling("WS Ground Tiling", Range( 0 , 8)) = 1
		[Toggle(_AFFECTEDBYWEATHER_ON)] _AffectedbyWeather("Affected by Weather", Float) = 1
		_WetnessCoverageMask("WetnessCoverage Mask", 2D) = "black" {}
		_WaterCoverageMultiplier("Water Coverage Multiplier", Range( 0 , 2)) = 1
		_RainDropIntensity("RainDrop Intensity", Range( 0 , 2)) = 0.1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 5.0
		#pragma shader_feature _AFFECTEDBYWEATHER_ON
		#pragma shader_feature _WORLDSPACEGROUND_ON
		#pragma shader_feature _COLORVARIATION_OFF _COLORVARIATION_ON _COLORVARIATION_WITHMASK
		#pragma shader_feature _EMISSIVE_OFF _EMISSIVE_ALPHACHANNELMASK _EMISSIVE_SEPARATEMAP
		#pragma exclude_renderers xbox360 xboxone ps4 psp2 n3ds wiiu 
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			half2 uv_texcoord;
			float3 worldPos;
		};

		uniform half _MetalnessMultiplier;
		uniform sampler2D _AlbedoMetal;
		uniform half _WSGroundTiling;
		uniform half _SmothnessMultiplier;
		uniform sampler2D _AOSAH;
		uniform sampler2D _Normal;
		uniform sampler2D _WetnessCoverageMask;
		uniform half _WaterCoverageMultiplier;
		uniform half _waterCoverage;
		uniform half _isRaining;
		uniform sampler2D _DropFlipbookNormal;
		uniform half _RainDropIntensity;
		uniform half4 _Color;
		uniform half _EmissiveMultiplier;
		uniform sampler2D _EmmissiveMap;
		uniform float4 _EmmissiveMap_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float2 appendResult293 = (half2(ase_worldPos.x , ase_worldPos.z));
			#ifdef _WORLDSPACEGROUND_ON
				float2 staticSwitch304 = ( _WSGroundTiling * appendResult293 );
			#else
				float2 staticSwitch304 = i.uv_texcoord;
			#endif
			half4 tex2DNode105 = tex2D( _AlbedoMetal, staticSwitch304 );
			float clampResult141 = clamp( ( _MetalnessMultiplier * tex2DNode105.a ) , 0.0 , 1.0 );
			half4 tex2DNode118 = tex2D( _AOSAH, staticSwitch304 );
			float clampResult289 = clamp( ( _SmothnessMultiplier * tex2DNode118.g ) , 0.0 , 1.0 );
			half3 tex2DNode106 = UnpackNormal( tex2D( _Normal, staticSwitch304 ) );
			float4 appendResult312 = (half4(clampResult141 , clampResult289 , tex2DNode106.xy));
			float lerpResult187 = lerp( ( 1.0 - tex2DNode118.a ) , tex2D( _WetnessCoverageMask, ( ( appendResult293 + 1.0 ) * 0.03 ) ).r , 0.5);
			float temp_output_159_0 = ( ( lerpResult187 + -1.0 + ( _WaterCoverageMultiplier * _waterCoverage ) ) * 8.0 );
			float clampResult156 = clamp( temp_output_159_0 , 0.0 , 1.0 );
			float lerpResult202 = lerp( clampResult141 , 0.25 , clampResult156);
			float lerpResult286 = lerp( lerpResult202 , 0.25 , _isRaining);
			float lerpResult212 = lerp( ( clampResult289 * 2.0 ) , 1.0 , clampResult156);
			float lerpResult203 = lerp( clampResult289 , lerpResult212 , clampResult156);
			float lerpResult285 = lerp( lerpResult203 , lerpResult212 , _isRaining);
			float clampResult209 = clamp( lerpResult285 , 0.0 , 1.0 );
			float3 lerpResult167 = lerp( tex2DNode106 , float3( 0,0,1 ) , clampResult156);
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles223 = 4.0 * 4.0;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset223 = 1.0f / 4.0;
			float fbrowsoffset223 = 1.0f / 4.0;
			// Speed of animation
			float fbspeed223 = _Time[ 1 ] * 16.0;
			// UV Tiling (col and row offset)
			float2 fbtiling223 = float2(fbcolsoffset223, fbrowsoffset223);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex223 = round( fmod( fbspeed223 + 0.0, fbtotaltiles223) );
			fbcurrenttileindex223 += ( fbcurrenttileindex223 < 0) ? fbtotaltiles223 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox223 = round ( fmod ( fbcurrenttileindex223, 4.0 ) );
			// Reverse X animation if speed is negative
			fblinearindextox223 = (16.0 > 0 ? fblinearindextox223 : (int)4.0 - fblinearindextox223);
			// Multiply Offset X by coloffset
			float fboffsetx223 = fblinearindextox223 * fbcolsoffset223;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy223 = round( fmod( ( fbcurrenttileindex223 - fblinearindextox223 ) / 4.0, 4.0 ) );
			// Reverse Y to get tiles from Top to Bottom and Reverse Y animation if speed is negative
			fblinearindextoy223 = (16.0 <  0 ? fblinearindextoy223 : (int)4.0 - fblinearindextoy223);
			// Multiply Offset Y by rowoffset
			float fboffsety223 = fblinearindextoy223 * fbrowsoffset223;
			// UV Offset
			float2 fboffset223 = float2(fboffsetx223, fboffsety223);
			// Flipbook UV
			half2 fbuv223 = ( appendResult293 * 0.4 ) * fbtiling223 + fboffset223;
			// *** END Flipbook UV Animation vars ***
			float2 appendResult235 = (half2(UnpackNormal( tex2D( _DropFlipbookNormal, fbuv223 ) ).xy));
			half2 temp_cast_2 = (0.0).xx;
			float2 lerpResult250 = lerp( ( appendResult235 * _RainDropIntensity ) , temp_cast_2 , ( clampResult156 * clampResult156 * 50.0 ));
			float3 appendResult252 = (half3(lerpResult250 , 1.0));
			float3 lerpResult290 = lerp( lerpResult167 , BlendNormals( lerpResult167 , appendResult252 ) , _isRaining);
			float4 appendResult311 = (half4(lerpResult286 , clampResult209 , lerpResult290.xy));
			#ifdef _AFFECTEDBYWEATHER_ON
				float4 staticSwitch309 = appendResult311;
			#else
				float4 staticSwitch309 = appendResult312;
			#endif
			float4 break313 = staticSwitch309;
			float3 appendResult315 = (half3(break313.z , break313.w , 1.0));
			o.Normal = appendResult315;
			float4 temp_output_108_0 = ( _Color * tex2DNode105 );
			float4 lerpResult145 = lerp( tex2DNode105 , temp_output_108_0 , tex2DNode118.b);
			#if defined(_COLORVARIATION_OFF)
				float4 staticSwitch142 = tex2DNode105;
			#elif defined(_COLORVARIATION_ON)
				float4 staticSwitch142 = temp_output_108_0;
			#elif defined(_COLORVARIATION_WITHMASK)
				float4 staticSwitch142 = lerpResult145;
			#else
				float4 staticSwitch142 = tex2DNode105;
			#endif
			float clampResult283 = clamp( ( 1.0 - temp_output_159_0 ) , 0.5 , 1.0 );
			o.Albedo = ( staticSwitch142 * clampResult283 ).rgb;
			float4 lerpResult131 = lerp( tex2DNode105 , float4( 0,0,0,0 ) , tex2DNode118.a);
			float2 uv_EmmissiveMap = i.uv_texcoord * _EmmissiveMap_ST.xy + _EmmissiveMap_ST.zw;
			#if defined(_EMISSIVE_OFF)
				float4 staticSwitch125 = float4( 0,0,0,0 );
			#elif defined(_EMISSIVE_ALPHACHANNELMASK)
				float4 staticSwitch125 = ( lerpResult131 * ( _EmissiveMultiplier * 10.0 ) );
			#elif defined(_EMISSIVE_SEPARATEMAP)
				float4 staticSwitch125 = ( _EmissiveMultiplier * tex2D( _EmmissiveMap, uv_EmmissiveMap ) );
			#else
				float4 staticSwitch125 = ( lerpResult131 * ( _EmissiveMultiplier * 10.0 ) );
			#endif
			o.Emission = staticSwitch125.rgb;
			o.Metallic = break313;
			o.Smoothness = break313.y;
			o.Occlusion = tex2DNode118.r;
			o.Alpha = 1;
		}

		ENDCG
	}

	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15600
-1913;29;1906;1004;646.3777;-812.1849;1;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;291;-2273.663,150.3281;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;293;-2045.27,202.941;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;305;-2226.751,56.66614;Float;False;Property;_WSGroundTiling;WS Ground Tiling;11;0;Create;True;0;0;False;0;1;1;0;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;177;-1270.744,140.3633;Float;False;3833.374;812.576;Wetness;27;287;290;286;209;202;285;241;205;167;203;252;212;210;156;198;159;160;157;187;185;194;193;195;196;186;307;308;;0.4764151,0.9329223,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;306;-1876.117,87.28908;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;196;-1081.763,481.6347;Half;False;Constant;_WaterMaskOffset;Water Mask Offset;14;0;Create;True;0;0;False;0;1;0;0;25;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;303;-2044.519,-409.5051;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;195;-785.7624,307.6345;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;193;-1065.397,602.7468;Half;False;Constant;_WaterMaskTiling;Water Mask Tiling;13;0;Create;True;0;0;False;0;0.03;0.03094118;0.005;0.25;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;304;-1561.97,-472.6069;Float;True;Property;_WorldSpaceGround;WorldSpace Ground;10;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;118;-773.95,-389.8786;Float;True;Property;_AOSAH;AOSAH;5;0;Create;True;0;0;False;0;None;3b7436cf5dab98d40b1a8daffaf1a1e8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;-670.5702,406.6347;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;251;-1321.7,1158.953;Float;False;2266.345;597.9443;RainDrop;12;294;223;279;250;243;254;257;235;259;244;222;224;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;186;-396.0347,209.1954;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;279;-1224.458,1625.355;Float;False;Constant;_RainDrop_TIling;RainDrop_TIling;13;0;Create;True;0;0;False;0;0.4;0.5;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;185;-508.5517,347.9522;Float;True;Property;_WetnessCoverageMask;WetnessCoverage Mask;13;0;Create;True;0;0;False;0;None;ff49cf194a9efd04a9b13d6bb736048d;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;307;-388.5872,594.6949;Float;False;Property;_WaterCoverageMultiplier;Water Coverage Multiplier;14;0;Create;True;0;0;False;0;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;157;-405.1276,717.2198;Half;False;Global;_waterCoverage;_waterCoverage;10;0;Create;True;0;0;False;0;0.65;0.63;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;187;-210.4235,275.2843;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;183;133.1805,-291.1234;Float;False;878.6077;336.6855;Smooth;3;110;112;289;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;308;-99.12314,627.1717;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;294;-853.3693,1550.096;Float;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;223;-501.8597,1485.618;Float;True;0;1;6;0;FLOAT2;1,1;False;1;FLOAT;4;False;2;FLOAT;4;False;3;FLOAT;16;False;4;FLOAT;0;False;5;FLOAT;1;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;110;136.2045,-225.8565;Half;False;Property;_SmothnessMultiplier;Smothness Multiplier;8;0;Create;True;0;0;False;0;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;160;43.44855,444.2074;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;224;-633.4566,1224.056;Float;True;Global;_DropFlipbookNormal;_DropFlipbookNormal;15;0;Create;True;0;0;False;0;None;7f69c9af8f048cf41a3c9a70d5c21292;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;222;-233.0312,1267.255;Float;True;Property;_RainDrop;RainDrop;12;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;419.2354,-190.3278;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;159;161.5998,552.0344;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;182;875.0294,-530.2042;Float;False;706.7796;231.9116;Metal;3;141;140;139;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;198;240.7604,275.0688;Half;False;Constant;_WetSmoothness;Wet Smoothness;11;0;Create;True;0;0;False;0;2;1.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;178;719.8466,-1153.874;Float;False;1612.134;609.3635;Color;5;105;107;142;145;108;;1,0.3254717,0.3254717,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;244;-8.831862,1645.501;Half;False;Property;_RainDropIntensity;RainDrop Intensity;16;0;Create;True;0;0;False;0;0.1;0.1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;156;421.1705,571.495;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;259;402.1979,1307.197;Half;False;Constant;_Float1;Float 1;15;0;Create;True;0;0;False;0;50;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;235;101.2626,1415.654;Float;True;FLOAT2;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;289;637.9553,-201.2222;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;243;369.0809,1479.999;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;105;725.3862,-824.5767;Float;True;Property;_AlbedoMetal;Albedo Metal;2;0;Create;True;0;0;False;0;None;35053d54d4b1c8145a6618d77a86b96d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;257;590.5524,1226.952;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;254;404.8755,1385.7;Half;False;Constant;_Float0;Float 0;15;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;210;510.7235,183.0838;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;139;925.0294,-473.2698;Half;False;Property;_MetalnessMultiplier;Metalness Multiplier;7;0;Create;True;0;0;False;0;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;106;-1137.889,-90.31905;Float;True;Property;_Normal;Normal;9;0;Create;True;0;0;False;0;None;c4d4ce56ed96b7d439b3e67aa45733f4;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;1242.264,-453.0747;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;250;715.4424,1346.71;Float;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;212;704.8167,348.0223;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;203;994.8005,257.9866;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;287;1168.14,537.6603;Half;True;Global;_isRaining;_isRaining;14;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;252;1498.058,804.72;Float;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;167;1021.009,684.8237;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;205;1269.549,381.7735;Half;False;Constant;_WetMetalness;Wet Metalness;14;0;Create;True;0;0;False;0;0.25;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;141;1421.949,-442.9388;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;202;1522.407,181.5715;Float;True;3;0;FLOAT;0;False;1;FLOAT;0.25;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;241;1808.802,730.0083;Float;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;285;1571.175,441.9711;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;173;1201.742,1009.233;Float;False;1477.399;692.9735;Emissive;7;125;133;138;135;137;131;134;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;209;1847.619,390.3876;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;107;1099.695,-1094.816;Float;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;False;0;1,1,1,0;0.4705882,0.4705882,0.4705882,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;286;1828.262,170.4516;Float;True;3;0;FLOAT;0;False;1;FLOAT;0.25;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;290;2326.823,578.1209;Float;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;134;1338.488,1326.412;Half;False;Property;_EmissiveMultiplier;Emissive Multiplier;6;0;Create;True;0;0;False;0;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;311;2645.443,381.9142;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;1456.421,-1032.708;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;312;2637.054,-40.82285;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;309;2791.921,122.2997;Float;False;Property;_AffectedbyWeather;Affected by Weather;12;0;Create;True;0;0;False;0;0;1;1;True;;Toggle;2;Key0;Key1;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;282;2444.743,-413.7558;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;1745.949,1335.697;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;145;1680.09,-783.269;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;137;1286.702,1499.472;Float;True;Property;_EmmissiveMap;EmmissiveMap;4;0;Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;131;1647.768,1071.233;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;1738.098,1439.95;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;2005.676,1136.95;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;283;2707.764,-440.2987;Float;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;142;2053.295,-941.426;Float;True;Property;_ColorVariation;Color Variation;1;0;Create;True;0;0;False;0;0;0;0;True;;KeywordEnum;3;Off;On;WithMask;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;313;3109.292,212.7835;Float;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;315;3404.089,-28.50385;Float;True;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;280;3020.775,-608.6611;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;125;2371.515,1125.316;Float;False;Property;_Emissive;Emissive;3;0;Create;True;0;0;False;0;0;1;0;True;;KeywordEnum;3;off;AlphaChannelMask;SeparateMap;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3786.763,44.70825;Half;False;True;7;Half;ASEMaterialInspector;0;0;Standard;Immersive Factory/Opaque/AOSA Wet;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;False;False;False;False;False;False;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;1;=;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;293;0;291;1
WireConnection;293;1;291;3
WireConnection;306;0;305;0
WireConnection;306;1;293;0
WireConnection;195;0;293;0
WireConnection;195;1;196;0
WireConnection;304;1;303;0
WireConnection;304;0;306;0
WireConnection;118;1;304;0
WireConnection;194;0;195;0
WireConnection;194;1;193;0
WireConnection;186;0;118;4
WireConnection;185;1;194;0
WireConnection;187;0;186;0
WireConnection;187;1;185;1
WireConnection;308;0;307;0
WireConnection;308;1;157;0
WireConnection;294;0;293;0
WireConnection;294;1;279;0
WireConnection;223;0;294;0
WireConnection;160;0;187;0
WireConnection;160;2;308;0
WireConnection;222;0;224;0
WireConnection;222;1;223;0
WireConnection;112;0;110;0
WireConnection;112;1;118;2
WireConnection;159;0;160;0
WireConnection;156;0;159;0
WireConnection;235;0;222;0
WireConnection;289;0;112;0
WireConnection;243;0;235;0
WireConnection;243;1;244;0
WireConnection;105;1;304;0
WireConnection;257;0;156;0
WireConnection;257;1;156;0
WireConnection;257;2;259;0
WireConnection;210;0;289;0
WireConnection;210;1;198;0
WireConnection;106;1;304;0
WireConnection;140;0;139;0
WireConnection;140;1;105;4
WireConnection;250;0;243;0
WireConnection;250;1;254;0
WireConnection;250;2;257;0
WireConnection;212;0;210;0
WireConnection;212;2;156;0
WireConnection;203;0;289;0
WireConnection;203;1;212;0
WireConnection;203;2;156;0
WireConnection;252;0;250;0
WireConnection;167;0;106;0
WireConnection;167;2;156;0
WireConnection;141;0;140;0
WireConnection;202;0;141;0
WireConnection;202;1;205;0
WireConnection;202;2;156;0
WireConnection;241;0;167;0
WireConnection;241;1;252;0
WireConnection;285;0;203;0
WireConnection;285;1;212;0
WireConnection;285;2;287;0
WireConnection;209;0;285;0
WireConnection;286;0;202;0
WireConnection;286;1;205;0
WireConnection;286;2;287;0
WireConnection;290;0;167;0
WireConnection;290;1;241;0
WireConnection;290;2;287;0
WireConnection;311;0;286;0
WireConnection;311;1;209;0
WireConnection;311;2;290;0
WireConnection;108;0;107;0
WireConnection;108;1;105;0
WireConnection;312;0;141;0
WireConnection;312;1;289;0
WireConnection;312;2;106;0
WireConnection;309;1;312;0
WireConnection;309;0;311;0
WireConnection;282;0;159;0
WireConnection;135;0;134;0
WireConnection;145;0;105;0
WireConnection;145;1;108;0
WireConnection;145;2;118;3
WireConnection;131;0;105;0
WireConnection;131;2;118;4
WireConnection;138;0;134;0
WireConnection;138;1;137;0
WireConnection;133;0;131;0
WireConnection;133;1;135;0
WireConnection;283;0;282;0
WireConnection;142;1;105;0
WireConnection;142;0;108;0
WireConnection;142;2;145;0
WireConnection;313;0;309;0
WireConnection;315;0;313;2
WireConnection;315;1;313;3
WireConnection;280;0;142;0
WireConnection;280;1;283;0
WireConnection;125;0;133;0
WireConnection;125;2;138;0
WireConnection;0;0;280;0
WireConnection;0;1;315;0
WireConnection;0;2;125;0
WireConnection;0;3;313;0
WireConnection;0;4;313;1
WireConnection;0;5;118;1
ASEEND*/
//CHKSM=FAD6495C84551C04BD5CC3E813DD50876F927DEE