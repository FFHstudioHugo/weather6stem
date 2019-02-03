// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Immersive Factory/Opaque/AOSA DoubleSided"
{
	Properties
	{
		[KeywordEnum(Off,On,AOSAlphaMask)] _ColorVariation("Color Variation", Float) = 0
		[HDR]_Color("Color", Color) = (1,1,1,0)
		_AlbedoMetalness("Albedo.Metalness", 2D) = "black" {}
		_MetalnessMultiplier("Metalness Multiplier", Range( 0 , 1)) = 1
		_AOSAE("AOSA(E)", 2D) = "white" {}
		_SmoothnessMultiplier("Smoothness Multiplier", Range( 0 , 1)) = 1
		_Normal("Normal", 2D) = "bump" {}
		[KeywordEnum(off,BlueChannelMask,SeparateMap)] _Emissive("Emissive", Float) = 0
		_EmissiveMultiplier("Emissive Multiplier", Range( 0 , 2)) = 0
		_EmmissiveMap("EmmissiveMap", 2D) = "black" {}
		[Toggle(_WORLDSPACEGROUND_ON)] _WorldSpaceGround("WorldSpace Ground", Float) = 0
		_WorldSpaceGroundTiling("WorldSpace Ground Tiling", Range( 0 , 8)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#pragma target 5.0
		#pragma shader_feature _WORLDSPACEGROUND_ON
		#pragma shader_feature _COLORVARIATION_OFF _COLORVARIATION_ON _COLORVARIATION_AOSALPHAMASK
		#pragma shader_feature _EMISSIVE_OFF _EMISSIVE_BLUECHANNELMASK _EMISSIVE_SEPARATEMAP
		#pragma exclude_renderers xbox360 xboxone ps4 psp2 n3ds wiiu 
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:forward 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform sampler2D _Normal;
		uniform float _WorldSpaceGroundTiling;
		uniform sampler2D _AlbedoMetalness;
		uniform half4 _Color;
		uniform sampler2D _AOSAE;
		uniform half _EmissiveMultiplier;
		uniform sampler2D _EmmissiveMap;
		uniform float4 _EmmissiveMap_ST;
		uniform half _MetalnessMultiplier;
		uniform half _SmoothnessMultiplier;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float2 appendResult209 = (float2(ase_worldPos.x , ase_worldPos.z));
			#ifdef _WORLDSPACEGROUND_ON
				float2 staticSwitch206 = ( appendResult209 * _WorldSpaceGroundTiling );
			#else
				float2 staticSwitch206 = i.uv_texcoord;
			#endif
			o.Normal = UnpackNormal( tex2D( _Normal, staticSwitch206 ) );
			float4 tex2DNode184 = tex2D( _AlbedoMetalness, staticSwitch206 );
			float4 temp_output_192_0 = ( _Color * tex2DNode184 );
			float4 tex2DNode118 = tex2D( _AOSAE, staticSwitch206 );
			float4 lerpResult193 = lerp( tex2DNode184 , temp_output_192_0 , tex2DNode118.b);
			#if defined(_COLORVARIATION_OFF)
				float4 staticSwitch194 = tex2DNode184;
			#elif defined(_COLORVARIATION_ON)
				float4 staticSwitch194 = temp_output_192_0;
			#elif defined(_COLORVARIATION_AOSALPHAMASK)
				float4 staticSwitch194 = lerpResult193;
			#else
				float4 staticSwitch194 = tex2DNode184;
			#endif
			o.Albedo = staticSwitch194.rgb;
			float4 lerpResult199 = lerp( tex2DNode184 , float4( 0,0,0,0 ) , ( 1.0 - tex2DNode118.a ));
			float2 uv_EmmissiveMap = i.uv_texcoord * _EmmissiveMap_ST.xy + _EmmissiveMap_ST.zw;
			#if defined(_EMISSIVE_OFF)
				float4 staticSwitch203 = float4( 0,0,0,0 );
			#elif defined(_EMISSIVE_BLUECHANNELMASK)
				float4 staticSwitch203 = ( lerpResult199 * ( _EmissiveMultiplier * 10.0 ) );
			#elif defined(_EMISSIVE_SEPARATEMAP)
				float4 staticSwitch203 = ( _EmissiveMultiplier * tex2D( _EmmissiveMap, uv_EmmissiveMap ) );
			#else
				float4 staticSwitch203 = float4( 0,0,0,0 );
			#endif
			o.Emission = staticSwitch203.rgb;
			o.Metallic = ( _MetalnessMultiplier * tex2DNode184.a );
			o.Smoothness = ( tex2DNode118.g * _SmoothnessMultiplier );
			o.Occlusion = tex2DNode118.r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15500
-1913;29;1906;1004;-251.2549;1381.18;2.579494;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;208;1441.765,-357.2906;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;204;1511.277,-197.4144;Float;False;Property;_WorldSpaceGroundTiling;WorldSpace Ground Tiling;11;0;Create;True;0;0;False;0;1;1;0;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;209;1656.577,-311.0392;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;210;1813.083,-293.0247;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;211;1774.843,-516.9666;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;206;2043.049,-448.2354;Float;True;Property;_WorldSpaceGround;WorldSpace Ground;10;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;195;2552.087,338.5761;Float;False;1480.185;848.9923;Emissive;8;203;202;201;200;199;198;197;196;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;118;2422.34,-123.1666;Float;True;Property;_AOSAE;AOSA(E);4;0;Create;True;0;0;False;0;None;facdd7dfc97788b4b9cc41662a767205;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;196;2688.835,655.7548;Half;False;Property;_EmissiveMultiplier;Emissive Multiplier;8;0;Create;True;0;0;False;0;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;191;2830.098,-1158.25;Half;False;Property;_Color;Color;1;1;[HDR];Create;True;0;0;False;0;1,1,1,0;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;197;2602.087,468.7435;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;184;2605.441,-818.8963;Float;True;Property;_AlbedoMetalness;Albedo.Metalness;2;0;Create;True;0;0;False;0;None;a33066e0d90550b40b9431ae646bfca0;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;200;2916.543,957.5687;Float;True;Property;_EmmissiveMap;EmmissiveMap;9;0;Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;192;3092.001,-1087.084;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;199;3011.115,388.5759;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;198;2988.337,749.2729;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;201;3280.366,607.9888;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;193;3383.632,-797.5659;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;202;3250.773,828.3939;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;186;2650.239,-549.8738;Half;False;Property;_MetalnessMultiplier;Metalness Multiplier;3;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;3088.899,153.149;Half;False;Property;_SmoothnessMultiplier;Smoothness Multiplier;5;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;185;3062.07,-599.2968;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;190;3458.758,-5.827997;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;106;3226.546,-337.9126;Float;True;Property;_Normal;Normal;6;0;Create;True;0;0;False;0;None;d0b0b4ed96233d8449010d41c225e615;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;203;3652.484,424.5218;Float;False;Property;_Emissive;Emissive;7;0;Create;True;0;0;False;0;0;0;0;True;;KeywordEnum;3;off;BlueChannelMask;SeparateMap;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;194;3746.028,-918.3322;Float;True;Property;_ColorVariation;Color Variation;0;0;Create;True;0;0;False;0;0;0;0;True;;KeywordEnum;3;Off;On;AOSAlphaMask;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;4611.495,-309.1825;Float;False;True;7;Float;ASEMaterialInspector;0;0;Standard;Immersive Factory/Opaque/AOSA DoubleSided;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;DeferredOnly;True;True;True;True;True;True;True;False;False;False;False;False;False;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;209;0;208;1
WireConnection;209;1;208;3
WireConnection;210;0;209;0
WireConnection;210;1;204;0
WireConnection;206;1;211;0
WireConnection;206;0;210;0
WireConnection;118;1;206;0
WireConnection;197;0;118;4
WireConnection;184;1;206;0
WireConnection;192;0;191;0
WireConnection;192;1;184;0
WireConnection;199;0;184;0
WireConnection;199;2;197;0
WireConnection;198;0;196;0
WireConnection;201;0;199;0
WireConnection;201;1;198;0
WireConnection;193;0;184;0
WireConnection;193;1;192;0
WireConnection;193;2;118;3
WireConnection;202;0;196;0
WireConnection;202;1;200;0
WireConnection;185;0;186;0
WireConnection;185;1;184;4
WireConnection;190;0;118;2
WireConnection;190;1;188;0
WireConnection;106;1;206;0
WireConnection;203;0;201;0
WireConnection;203;2;202;0
WireConnection;194;1;184;0
WireConnection;194;0;192;0
WireConnection;194;2;193;0
WireConnection;0;0;194;0
WireConnection;0;1;106;0
WireConnection;0;2;203;0
WireConnection;0;3;185;0
WireConnection;0;4;190;0
WireConnection;0;5;118;1
ASEEND*/
//CHKSM=757C28629E0A9B82A8CEB5842DAB7FF31BD46FC2