// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Immersive Factory/AlphaBlend/Debug Albedo Opacity  "
{
	Properties
	{
		[HDR]_Color("Color", Color) = (1,1,1,0)
		_AlbedoOpacity("Albedo Opacity", 2D) = "white" {}
		[HDR]_Transparent_Color("Transparent_Color", Color) = (0.4382788,0.4622642,0.4581614,0)
		_OpacityMultiplier("Opacity Multiplier", Range( 0 , 5)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" }
		Cull Back
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		BlendOp Add , Add
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 5.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _Transparent_Color;
		uniform float4 _Color;
		uniform sampler2D _AlbedoOpacity;
		uniform float _OpacityMultiplier;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 tex2DNode39 = tex2D( _AlbedoOpacity, i.uv_texcoord );
			float lerpResult45 = lerp( ( tex2DNode39.a * _OpacityMultiplier ) , 1.0 , tex2DNode39.a);
			float clampResult57 = clamp( lerpResult45 , 0.0 , 1.0 );
			float4 lerpResult73 = lerp( _Transparent_Color , ( _Color * tex2DNode39 ) , pow( clampResult57 , 16.28 ));
			o.Albedo = lerpResult73.rgb;
			o.Alpha = lerpResult45;
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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
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
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
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
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15500
-1913;29;1906;1004;100.4444;1267.543;1.976058;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;71;357.5164,-788.7947;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;24;984.9843,-349.308;Float;False;Property;_OpacityMultiplier;Opacity Multiplier;3;0;Create;True;0;0;False;0;0;2.33;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;39;686.5439,-868.9772;Float;True;Property;_AlbedoOpacity;Albedo Opacity;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;1432.813,-595.4481;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;45;1718.024,-356.8482;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;57;2232.724,-132.4396;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;70;1833.112,-920.1773;Float;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;False;0;1,1,1,0;0.4575472,1,0.9890634,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;2164.448,-584.8965;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;72;2410.252,-744.2349;Float;False;Property;_Transparent_Color;Transparent_Color;2;1;[HDR];Create;True;0;0;False;0;0.4382788,0.4622642,0.4581614,0;0.4559452,0.825967,0.8867924,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;58;2457.96,-385.2727;Float;True;2;0;FLOAT;0;False;1;FLOAT;16.28;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;73;2806.911,-465.5845;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3213.34,-183.3907;Float;False;True;7;Float;ASEMaterialInspector;0;0;Standard;Immersive Factory/AlphaBlend/Debug Albedo Opacity  ;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;5;Custom;1;True;True;0;True;Transparent;AlphaBlendDebug;Geometry;ForwardOnly;False;True;True;True;True;False;True;False;False;False;False;False;False;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;4;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;39;1;71;0
WireConnection;46;0;39;4
WireConnection;46;1;24;0
WireConnection;45;0;46;0
WireConnection;45;2;39;4
WireConnection;57;0;45;0
WireConnection;69;0;70;0
WireConnection;69;1;39;0
WireConnection;58;0;57;0
WireConnection;73;0;72;0
WireConnection;73;1;69;0
WireConnection;73;2;58;0
WireConnection;0;0;73;0
WireConnection;0;9;45;0
ASEEND*/
//CHKSM=A7FBDE0A3B10A0E3EEAFA5B781621ADFFD4990FB