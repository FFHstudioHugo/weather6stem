// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Immersive Factory/AlphaTest/AOSA"
{
	Properties
	{
		[HDR]_Color("Color", Color) = (1,1,1,0)
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_AlbedoMetal("Albedo Metal", 2D) = "white" {}
		[HDR]_Transparent_Color("Transparent_Color", Color) = (0.4649787,0.764151,0.7151955,0)
		_MetallicMultiplier("Metallic Multiplier", Range( 0 , 2)) = 1
		_AOSAH("AOSAH", 2D) = "white" {}
		_SmoothnessMultiplier("Smoothness Multiplier", Range( 0 , 2)) = 1
		_Normal("Normal", 2D) = "bump" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Back
		CGPROGRAM
		#pragma target 5.0
		#pragma only_renderers d3d11 glcore gles gles3 d3d11_9x 
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float4 _Transparent_Color;
		uniform float4 _Color;
		uniform sampler2D _AlbedoMetal;
		uniform float4 _AlbedoMetal_ST;
		uniform sampler2D _AOSAH;
		uniform float4 _AOSAH_ST;
		uniform half _MetallicMultiplier;
		uniform half _SmoothnessMultiplier;
		uniform float _Cutoff = 0.5;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float2 uv_AlbedoMetal = i.uv_texcoord * _AlbedoMetal_ST.xy + _AlbedoMetal_ST.zw;
			float4 tex2DNode39 = tex2D( _AlbedoMetal, uv_AlbedoMetal );
			float2 uv_AOSAH = i.uv_texcoord * _AOSAH_ST.xy + _AOSAH_ST.zw;
			float4 tex2DNode4 = tex2D( _AOSAH, uv_AOSAH );
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
	}
	Fallback "/ImmersiveShader/MSAO"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15600
-1913;23;1906;1010;861.9286;1323.255;2.226676;True;False
Node;AmplifyShaderEditor.SamplerNode;4;1415.584,-18.31514;Float;True;Property;_AOSAH;AOSAH;5;0;Create;True;0;0;False;0;None;81e1bdf295d3cb4498c272ed84a5593f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;79;1833.564,-80.17213;Half;False;Property;_MetallicMultiplier;Metallic Multiplier;4;0;Create;True;0;0;False;0;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;1842.697,367.4477;Half;False;Property;_SmoothnessMultiplier;Smoothness Multiplier;6;0;Create;True;0;0;False;0;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;57;2052.197,-459.1223;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;70;1760.604,-818.6651;Float;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;False;0;1,1,1,0;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;39;1408.146,-498.628;Float;True;Property;_AlbedoMetal;Albedo Metal;2;0;Create;True;0;0;False;0;None;4652e881edd715a4394b223802bc2615;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;2168.204,-127.7768;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;1.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;2308.039,303.4296;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;1.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;2064.272,-706.9787;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;58;2288.297,-460.0323;Float;True;2;0;FLOAT;0;False;1;FLOAT;16.28;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;72;2448.85,-720.3467;Float;False;Property;_Transparent_Color;Transparent_Color;3;1;[HDR];Create;True;0;0;False;0;0.4649787,0.764151,0.7151955,0;0.3773585,0.3773585,0.3773585,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;81;2404.553,-128.8107;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;73;2641.728,-504.9134;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;78;2571.336,275.4767;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;1413.705,-248.3704;Float;True;Property;_Normal;Normal;7;0;Create;True;0;0;False;0;None;3ac75f515cd403846a12fa477492f900;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3137.976,-192.6031;Float;False;True;7;Float;ASEMaterialInspector;0;0;Standard;Immersive Factory/AlphaTest/AOSA;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;AlphaBlendDebug;AlphaTest;ForwardOnly;False;True;True;True;True;False;True;False;False;False;False;False;False;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;/ImmersiveShader/MSAO;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;57;0;4;3
WireConnection;80;0;39;4
WireConnection;80;1;79;0
WireConnection;67;0;74;0
WireConnection;67;1;4;2
WireConnection;69;0;70;0
WireConnection;69;1;39;0
WireConnection;58;0;57;0
WireConnection;81;0;80;0
WireConnection;73;0;72;0
WireConnection;73;1;69;0
WireConnection;73;2;58;0
WireConnection;78;0;67;0
WireConnection;0;0;73;0
WireConnection;0;1;3;0
WireConnection;0;3;81;0
WireConnection;0;4;78;0
WireConnection;0;5;4;1
WireConnection;0;10;4;3
ASEEND*/
//CHKSM=47F1605AB1A02AD675471FD4BB5ED50A48BD8C00