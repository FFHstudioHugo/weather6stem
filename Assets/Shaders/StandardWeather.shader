// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Immersive Factory/Opaque/MAOS"
{
	Properties
	{
		[HDR]_Color("Color", Color) = (1,1,1,0)
		_Albedo("Albedo", 2D) = "white" {}
		_MAOS("MAOS", 2D) = "gray" {}
		_SmothnessForce("SmothnessForce", Range( 0 , 1.5)) = 0.5
		_Normal("Normal", 2D) = "bump" {}
		_EmissiveForce("EmissiveForce", Range( 0 , 1)) = 0
		[KeywordEnum(Mask,Map)] _Emissive("Emissive", Float) = 1
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
		#pragma shader_feature _EMISSIVE_MASK _EMISSIVE_MAP
		#pragma exclude_renderers xbox360 xboxone ps4 psp2 n3ds wiiu 
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:forward 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Normal;
		uniform float4 _Color;
		uniform sampler2D _Albedo;
		uniform half _EmissiveForce;
		uniform sampler2D _EmmissiveMap;
		uniform float4 _EmmissiveMap_ST;
		uniform sampler2D _MAOS;
		uniform float _SmothnessForce;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = UnpackNormal( tex2D( _Normal, i.uv_texcoord ) );
			float4 tex2DNode105 = tex2D( _Albedo, i.uv_texcoord );
			o.Albedo = ( _Color * tex2DNode105 ).rgb;
			float2 uv_EmmissiveMap = i.uv_texcoord * _EmmissiveMap_ST.xy + _EmmissiveMap_ST.zw;
			float4 tex2DNode118 = tex2D( _MAOS, i.uv_texcoord );
			float4 lerpResult131 = lerp( tex2DNode105 , float4( 0,0,0,0 ) , ( 1.0 - tex2DNode118.b ));
			#if defined(_EMISSIVE_MASK)
				float4 staticSwitch125 = ( lerpResult131 * ( _EmissiveForce * 10.0 ) );
			#elif defined(_EMISSIVE_MAP)
				float4 staticSwitch125 = ( _EmissiveForce * tex2D( _EmmissiveMap, uv_EmmissiveMap ) );
			#else
				float4 staticSwitch125 = ( _EmissiveForce * tex2D( _EmmissiveMap, uv_EmmissiveMap ) );
			#endif
			o.Emission = staticSwitch125.rgb;
			o.Metallic = tex2DNode118.r;
			float clampResult117 = clamp( ( _SmothnessForce * tex2DNode118.a ) , 0.0 , 1.0 );
			o.Smoothness = clampResult117;
			o.Occlusion = tex2DNode118.g;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15401
-1913;29;1906;952;2507.7;1535.682;2.706159;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;136;-918.5188,-386.2355;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;118;-410.2748,-466.9087;Float;True;Property;_MAOS;MAOS;2;0;Create;True;0;0;False;0;None;5bac5ee316a17a74e89108edd57d5f03;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;105;-415.157,-691.8937;Float;True;Property;_Albedo;Albedo;1;0;Create;True;0;0;False;0;None;c92e1eb54a46e2743b4a89d087e867d9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;134;879.4879,113.5028;Half;False;Property;_EmissiveForce;EmissiveForce;5;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;132;880,-176;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;131;1146.34,-236.6026;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-343.9372,-253.9939;Float;False;Property;_SmothnessForce;SmothnessForce;3;0;Create;True;0;0;False;0;0.5;0.908;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;1238.107,45.9448;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;137;1173.347,227.8714;Float;True;Property;_EmmissiveMap;EmmissiveMap;7;0;Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;107;-200.9971,-928.2219;Float;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;False;0;1,1,1,0;2.297397,2.297397,2.297397,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;1420.276,-88.0282;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;1569.783,145.8495;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;780.275,-488.6311;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;95.0028,-774.222;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;125;1825.945,-87.45297;Float;False;Property;_Emissive;Emissive;6;0;Create;True;0;0;False;0;0;1;0;True;;KeywordEnum;2;Mask;Map;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;117;1015.369,-477.0049;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;106;-417.2251,-142.0447;Float;True;Property;_Normal;Normal;4;0;Create;True;0;0;False;0;None;c2a1e5ec35670d040874b7094894e1cb;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2178.138,-584.2837;Float;False;True;7;Float;ASEMaterialInspector;0;0;Standard;Immersive Factory/Opaque/MAOS;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;DeferredOnly;True;True;True;True;True;True;True;False;False;False;False;False;False;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;-1;False;-1;-1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;118;1;136;0
WireConnection;105;1;136;0
WireConnection;132;0;118;3
WireConnection;131;0;105;0
WireConnection;131;2;132;0
WireConnection;135;0;134;0
WireConnection;133;0;131;0
WireConnection;133;1;135;0
WireConnection;138;0;134;0
WireConnection;138;1;137;0
WireConnection;112;0;110;0
WireConnection;112;1;118;4
WireConnection;108;0;107;0
WireConnection;108;1;105;0
WireConnection;125;1;133;0
WireConnection;125;0;138;0
WireConnection;117;0;112;0
WireConnection;106;1;136;0
WireConnection;0;0;108;0
WireConnection;0;1;106;0
WireConnection;0;2;125;0
WireConnection;0;3;118;1
WireConnection;0;4;117;0
WireConnection;0;5;118;2
ASEEND*/
//CHKSM=F5487DBF46D5FCF043CA532905682C42553FC4B3