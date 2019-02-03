// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Immersive Factory/VFX/Weather Panning"
{
	Properties
	{
		_NormalMaskNoise("NormalMaskNoise", 2D) = "white" {}
		_RainTiling("Rain Tiling", Range( 0.01 , 10)) = 7.011265
		_RainSpeed("Rain Speed", Range( 0.01 , 10)) = 7.011265
		_WaveSpeed("Wave Speed", Range( 0.01 , 2)) = 7.011265
		_WaveTiling("Wave Tiling", Range( 0.01 , 10)) = 7.011265
		_Color0("Color 0", Color) = (0.8254717,1,0.9848046,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Front
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			half2 uv_texcoord;
		};

		uniform half4 _Color0;
		uniform sampler2D _NormalMaskNoise;
		uniform half _RainSpeed;
		uniform half _RainTiling;
		uniform half _WaveSpeed;
		uniform half _WaveTiling;
		uniform float4 _NormalMaskNoise_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			half4 temp_output_9_0 = _Color0;
			o.Albedo = temp_output_9_0.rgb;
			o.Emission = temp_output_9_0.rgb;
			o.Metallic = 0.25;
			o.Smoothness = 1.0;
			float2 appendResult34 = (half2(( _RainSpeed * 0.1 ) , _RainSpeed));
			half2 temp_cast_2 = (_RainTiling).xx;
			float2 uv_TexCoord7 = i.uv_texcoord * temp_cast_2;
			float2 panner2 = ( 1.0 * _Time.y * appendResult34 + uv_TexCoord7);
			float2 appendResult37 = (half2(( _WaveSpeed * 0.5 ) , _WaveSpeed));
			half2 temp_cast_3 = (_WaveTiling).xx;
			float2 uv_TexCoord28 = i.uv_texcoord * temp_cast_3;
			float2 panner29 = ( 1.0 * _Time.y * appendResult37 + uv_TexCoord28);
			half2 temp_cast_4 = (( _RainTiling * 0.8 )).xx;
			float2 uv_TexCoord17 = i.uv_texcoord * temp_cast_4;
			float2 panner16 = ( 1.0 * _Time.y * ( 1.2 * appendResult34 ) + uv_TexCoord17);
			float2 uv_NormalMaskNoise = i.uv_texcoord * _NormalMaskNoise_ST.xy + _NormalMaskNoise_ST.zw;
			float clampResult45 = clamp( ( ( ( tex2D( _NormalMaskNoise, panner2 ).r * tex2D( _NormalMaskNoise, panner29 ).g ) + tex2D( _NormalMaskNoise, panner16 ).r ) * tex2D( _NormalMaskNoise, uv_NormalMaskNoise ).b ) , 0.0 , 1.0 );
			o.Alpha = clampResult45;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows noshadow 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
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
-1913;29;1906;1004;2257.439;-30.75726;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;32;-2328.617,73.45116;Half;False;Property;_RainSpeed;Rain Speed;2;0;Create;True;0;0;False;0;7.011265;0.6801351;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-1966.935,675.8368;Half;False;Property;_WaveSpeed;Wave Speed;3;0;Create;True;0;0;False;0;7.011265;0.1916056;0.01;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1936.471,-106.0367;Half;False;Property;_RainTiling;Rain Tiling;1;0;Create;True;0;0;False;0;7.011265;10;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-2029.321,13.00178;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-1628.59,594.8004;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1962.825,453.9479;Half;False;Property;_WaveTiling;Wave Tiling;4;0;Create;True;0;0;False;0;7.011265;2.637579;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1947.556,250.6746;Half;False;Constant;_Float2;Float 2;4;0;Create;True;0;0;False;0;0.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;-1484.904,460.7631;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,2;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;34;-1881.3,62.03397;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-1435.973,-131.1202;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,2;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;37;-1442.054,636.7889;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1942.706,329.8474;Half;False;Constant;_Float3;Float 3;4;0;Create;True;0;0;False;0;1.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-1604.712,182.1833;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-1605.697,321.564;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0.8,0.8;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;17;-1446.52,199.2715;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,2;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;1;-1404.966,-409.8114;Float;True;Property;_NormalMaskNoise;NormalMaskNoise;0;0;Create;True;0;0;False;0;None;4e405cff7b74ba1448bf04870f3bc801;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;29;-1187.748,539.3557;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;2;-1152.923,-50.99501;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;27;-707.6387,424.5753;Float;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;16;-1185.382,278.5266;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;3;-692.4244,-26.01679;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;-715.7244,204.1336;Float;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-245.9129,337.0284;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;47;-721.5545,641.1945;Float;True;Property;_TextureSample3;Texture Sample 3;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-22.15895,207.6171;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;294.2356,414.0819;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;387.8723,62.20895;Float;False;Constant;_Smoothness;Smoothness;3;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;45;565.2951,359.4707;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;9;335.7279,-188.9082;Half;False;Property;_Color0;Color 0;5;0;Create;True;0;0;False;0;0.8254717,1,0.9848046,0;0.5402722,0.6253979,0.6698113,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;10;387.5217,-9.759142;Float;False;Constant;_Metalness;Metalness;3;0;Create;True;0;0;False;0;0.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;947.6411,-92.24684;Half;False;True;2;Half;ASEMaterialInspector;0;0;Standard;Immersive Factory/VFX/Weather Panning;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Front;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;4;1;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;33;0;32;0
WireConnection;36;0;35;0
WireConnection;28;0;30;0
WireConnection;34;0;33;0
WireConnection;34;1;32;0
WireConnection;7;0;8;0
WireConnection;37;0;36;0
WireConnection;37;1;35;0
WireConnection;19;0;8;0
WireConnection;19;1;18;0
WireConnection;15;0;26;0
WireConnection;15;1;34;0
WireConnection;17;0;19;0
WireConnection;29;0;28;0
WireConnection;29;2;37;0
WireConnection;2;0;7;0
WireConnection;2;2;34;0
WireConnection;27;0;1;0
WireConnection;27;1;29;0
WireConnection;16;0;17;0
WireConnection;16;2;15;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;14;0;1;0
WireConnection;14;1;16;0
WireConnection;38;0;3;1
WireConnection;38;1;27;2
WireConnection;47;0;1;0
WireConnection;24;0;38;0
WireConnection;24;1;14;1
WireConnection;42;0;24;0
WireConnection;42;1;47;3
WireConnection;45;0;42;0
WireConnection;0;0;9;0
WireConnection;0;2;9;0
WireConnection;0;3;10;0
WireConnection;0;4;11;0
WireConnection;0;9;45;0
ASEEND*/
//CHKSM=79C3289DDCB36C0A2D56B717DF543085FE2C64E6