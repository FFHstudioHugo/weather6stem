// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Immersive Factory/Opaque/MAOS"
{
	Properties
	{
		[HDR]_Color("Color", Color) = (1,1,1,0)
		[KeywordEnum(Off,On,WithMask)] _ColorVariation("Color Variation", Float) = 0
		_Albedo("Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_MAOBS("MAO(B)S", 2D) = "white" {}
		_MetalnessMultiplier("Metalness Multiplier", Range( 0 , 2)) = 1
		_SmothnessMultiplier("Smothness Multiplier", Range( 0 , 2)) = 1
		[KeywordEnum(off,BlueChannelMask,SeparateMap)] _Emissive("Emissive", Float) = 0
		_EmissiveMultiplier("Emissive Multiplier", Range( 0 , 2)) = 0
		_EmmissiveMap("EmmissiveMap", 2D) = "black" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 5.0
		#pragma shader_feature _COLORVARIATION_OFF _COLORVARIATION_ON _COLORVARIATION_WITHMASK
		#pragma shader_feature _EMISSIVE_OFF _EMISSIVE_BLUECHANNELMASK _EMISSIVE_SEPARATEMAP
		#pragma exclude_renderers xbox360 xboxone ps4 psp2 n3ds wiiu 
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:forward 
		struct Input
		{
			half2 uv_texcoord;
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform half4 _Color;
		uniform sampler2D _MAOBS;
		uniform float4 _MAOBS_ST;
		uniform half _EmissiveMultiplier;
		uniform sampler2D _EmmissiveMap;
		uniform float4 _EmmissiveMap_ST;
		uniform half _MetalnessMultiplier;
		uniform half _SmothnessMultiplier;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			half4 tex2DNode105 = tex2D( _Albedo, uv_Albedo );
			float4 temp_output_108_0 = ( _Color * tex2DNode105 );
			float4 lerpResult145 = lerp( tex2DNode105 , temp_output_108_0 , tex2DNode105.a);
			#if defined(_COLORVARIATION_OFF)
				float4 staticSwitch142 = tex2DNode105;
			#elif defined(_COLORVARIATION_ON)
				float4 staticSwitch142 = temp_output_108_0;
			#elif defined(_COLORVARIATION_WITHMASK)
				float4 staticSwitch142 = lerpResult145;
			#else
				float4 staticSwitch142 = tex2DNode105;
			#endif
			o.Albedo = staticSwitch142.rgb;
			float2 uv_MAOBS = i.uv_texcoord * _MAOBS_ST.xy + _MAOBS_ST.zw;
			half4 tex2DNode118 = tex2D( _MAOBS, uv_MAOBS );
			float4 lerpResult131 = lerp( tex2DNode105 , float4( 0,0,0,0 ) , ( 1.0 - tex2DNode118.b ));
			float2 uv_EmmissiveMap = i.uv_texcoord * _EmmissiveMap_ST.xy + _EmmissiveMap_ST.zw;
			#if defined(_EMISSIVE_OFF)
				float4 staticSwitch125 = float4( 0,0,0,0 );
			#elif defined(_EMISSIVE_BLUECHANNELMASK)
				float4 staticSwitch125 = ( lerpResult131 * ( _EmissiveMultiplier * 10.0 ) );
			#elif defined(_EMISSIVE_SEPARATEMAP)
				float4 staticSwitch125 = ( _EmissiveMultiplier * tex2D( _EmmissiveMap, uv_EmmissiveMap ) );
			#else
				float4 staticSwitch125 = float4( 0,0,0,0 );
			#endif
			o.Emission = staticSwitch125.rgb;
			float clampResult141 = clamp( ( _MetalnessMultiplier * tex2DNode118.r ) , 0.0 , 1.0 );
			o.Metallic = clampResult141;
			float clampResult213 = clamp( ( _SmothnessMultiplier * tex2DNode118.a ) , 0.0 , 1.0 );
			o.Smoothness = clampResult213;
			o.Occlusion = tex2DNode118.g;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15600
-1913;29;1906;1004;341.1741;980.2396;2.40958;True;False
Node;AmplifyShaderEditor.CommentaryNode;178;896.4806,-1222.836;Float;False;1439.13;612.4528;Color;5;105;107;108;145;142;;1,0.3254717,0.3254717,1;0;0
Node;AmplifyShaderEditor.SamplerNode;118;442.5609,-59.12448;Float;True;Property;_MAOBS;MAO(B)S;4;0;Create;True;0;0;False;0;None;d17490868f017d24bb1694dff30a9349;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;173;1050.216,399.7431;Float;False;1480.185;848.9923;Emissive;8;132;134;131;137;135;133;138;125;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;183;1045.846,7.946255;Float;False;712.7561;232.3248;Smooth;3;213;110;112;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;182;1033.872,-363.8013;Float;False;706.7796;231.9116;Metal;3;141;140;139;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;132;1100.216,529.9108;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;1186.964,716.9222;Half;False;Property;_EmissiveMultiplier;Emissive Multiplier;8;0;Create;True;0;0;False;0;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;107;1198.148,-1172.836;Float;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;False;0;1,1,1,0;1,0,0,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;105;943.1525,-969.1834;Float;True;Property;_Albedo;Albedo;2;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;1486.466,810.4403;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;139;1083.872,-306.8667;Half;False;Property;_MetalnessMultiplier;Metalness Multiplier;5;0;Create;True;0;0;False;0;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;131;1509.244,449.7428;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;110;1083.064,42.81441;Half;False;Property;_SmothnessMultiplier;Smothness Multiplier;6;0;Create;True;0;0;False;0;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;1460.051,-1101.67;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;137;1414.672,1018.736;Float;True;Property;_EmmissiveMap;EmmissiveMap;9;0;Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;1365.948,63.64626;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;1401.107,-286.6717;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;145;1683.72,-852.231;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;1748.9,889.5613;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;1778.493,669.1563;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;142;2074.056,-960.1713;Float;False;Property;_ColorVariation;Color Variation;1;0;Create;True;0;0;False;0;0;0;0;True;;KeywordEnum;3;Off;On;WithMask;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;141;1594.851,-281.6328;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;213;1558.385,55.3974;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;106;2179.121,-458.3013;Float;True;Property;_Normal;Normal;3;0;Create;True;0;0;False;0;None;cf5475c647698574ab200fb5f6bb87e1;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;125;2192.372,472.2112;Float;False;Property;_Emissive;Emissive;7;0;Create;True;0;0;False;0;0;0;0;True;;KeywordEnum;3;off;BlueChannelMask;SeparateMap;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3097.938,-288.8903;Half;False;True;7;Half;ASEMaterialInspector;0;0;Standard;Immersive Factory/Opaque/MAOS;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;DeferredOnly;True;True;True;True;True;True;True;False;False;False;False;False;False;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;132;0;118;3
WireConnection;135;0;134;0
WireConnection;131;0;105;0
WireConnection;131;2;132;0
WireConnection;108;0;107;0
WireConnection;108;1;105;0
WireConnection;112;0;110;0
WireConnection;112;1;118;4
WireConnection;140;0;139;0
WireConnection;140;1;118;1
WireConnection;145;0;105;0
WireConnection;145;1;108;0
WireConnection;145;2;105;4
WireConnection;138;0;134;0
WireConnection;138;1;137;0
WireConnection;133;0;131;0
WireConnection;133;1;135;0
WireConnection;142;1;105;0
WireConnection;142;0;108;0
WireConnection;142;2;145;0
WireConnection;141;0;140;0
WireConnection;213;0;112;0
WireConnection;125;0;133;0
WireConnection;125;2;138;0
WireConnection;0;0;142;0
WireConnection;0;1;106;0
WireConnection;0;2;125;0
WireConnection;0;3;141;0
WireConnection;0;4;213;0
WireConnection;0;5;118;2
ASEEND*/
//CHKSM=D3225FBE3CC9586DDD1B9357FD9B9C18A62B2DA0