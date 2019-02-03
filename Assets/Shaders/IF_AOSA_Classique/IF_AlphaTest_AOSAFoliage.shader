// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Immersive Factory/AlphaTest/Foliage"
{
	Properties
	{
		[HDR]_Color("Color", Color) = (1,1,1,0)
		_Cutoff( "Mask Clip Value", Float ) = 0.33
		_AlbedoOpacity("Albedo Opacity", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_MetallicMultiplier("Metallic Multiplier", Range( 0 , 1)) = 0.2
		_SmoothnessMultiplier("Smoothness Multiplier", Range( 0 , 1)) = 0.5
		_MAOTSTexture("MAOTS Texture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Off
		CGPROGRAM
		#pragma target 5.0
		#pragma only_renderers d3d11 glcore gles gles3 d3d11_9x 
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:forward 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float4 _Color;
		uniform sampler2D _AlbedoOpacity;
		uniform float4 _AlbedoOpacity_ST;
		uniform half _MetallicMultiplier;
		uniform sampler2D _MAOTSTexture;
		uniform float4 _MAOTSTexture_ST;
		uniform half _SmoothnessMultiplier;
		uniform float _Cutoff = 0.33;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float2 uv_AlbedoOpacity = i.uv_texcoord * _AlbedoOpacity_ST.xy + _AlbedoOpacity_ST.zw;
			float4 tex2DNode39 = tex2D( _AlbedoOpacity, uv_AlbedoOpacity );
			o.Albedo = ( _Color * tex2DNode39 ).rgb;
			float2 uv_MAOTSTexture = i.uv_texcoord * _MAOTSTexture_ST.xy + _MAOTSTexture_ST.zw;
			float4 tex2DNode83 = tex2D( _MAOTSTexture, uv_MAOTSTexture );
			o.Metallic = ( _MetallicMultiplier * tex2DNode83.r );
			o.Smoothness = ( _SmoothnessMultiplier * tex2DNode83.a );
			o.Occlusion = tex2DNode83.g;
			o.Alpha = 1;
			clip( tex2DNode39.a - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15500
204;92;688;628;-1337.997;454.0405;1.653939;True;False
Node;AmplifyShaderEditor.ColorNode;70;1943.004,-778.6654;Float;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;False;0;1,1,1,0;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;39;1919.973,-573.8815;Float;True;Property;_AlbedoOpacity;Albedo Opacity;2;0;Create;True;0;0;False;0;None;6f11f61d6caa4fc40b6fae0cbd80bc97;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;83;1878.692,151.0549;Float;True;Property;_MAOTSTexture;MAOTS Texture;7;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;79;1901.935,-142.8071;Half;False;Property;_MetallicMultiplier;Metallic Multiplier;4;0;Create;True;0;0;False;0;0.2;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;1903.224,-62.14768;Half;False;Property;_SmoothnessMultiplier;Smoothness Multiplier;5;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;1904.298,21.45525;Half;False;Property;_TransmissionMultiplier;Transmission Multiplier;6;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;1891.829,-350.232;Float;True;Property;_Normal;Normal;3;0;Create;True;0;0;False;0;None;f94a4f12bd985ed4693dce68c25b1a52;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;2347.494,-154.545;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;2344.292,-55.34512;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;2337.893,40.65482;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;2350.674,-602.9786;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3137.976,-192.6031;Float;False;True;7;Float;ASEMaterialInspector;0;0;Standard;Immersive Factory/AlphaTest/Foliage;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.33;True;True;0;False;TransparentCutout;AlphaBlendDebug;AlphaTest;DeferredOnly;False;True;True;True;True;False;True;False;False;False;False;False;False;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;3;1;False;-1;10;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;87;0;79;0
WireConnection;87;1;83;1
WireConnection;88;0;74;0
WireConnection;88;1;83;4
WireConnection;89;0;83;3
WireConnection;89;1;82;0
WireConnection;69;0;70;0
WireConnection;69;1;39;0
WireConnection;0;0;69;0
WireConnection;0;1;3;0
WireConnection;0;3;87;0
WireConnection;0;4;88;0
WireConnection;0;5;83;2
WireConnection;0;10;39;4
ASEEND*/
//CHKSM=EBB3DC39AA5CB20E697CA493748BA003556AC899