Shader "Custom/PBR" 
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
        _Albedo("Albedo", Color) = (1, 1, 1, 1)
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_RampTex("Ramp Texture", 2D) = "white" {}
		_OutlineAlbedo("Outline Albedo", Color) = (0, 0, 0, 1)
		_OutlineSize("Outline Size", Range(0.001, 0.1)) = 0.05
		_BumpTex("Normal", 2D) = "bump" {}
		_NormalAmount("Normal Amount", Range(-3, 3)) = 1
		_RimAlbedo("Rim Albedo", Color) = (1, 1, 1, 1)
		_RimPower("Rim Amount", Range(0.5, 8.0)) = 1
	}
	SubShader
		{
			Tags { "RenderType" = "Opaque" }

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf Standard fullforwardshadows

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			float4 _Albedo;
			sampler2D _MainTex;
			sampler2D _RampTex;
			sampler2D _BumpTex;
			float _NormalAmount;
			float4 _RimAlbedo;
			float _RimPower;

			struct Input {
				float2 uv_MainTex;
				float2 uv_BumpTex;
				float3 viewDir;
				float4 _Albedo;
			};

			half _Glossiness;
			half _Metallic;

			void surf(Input IN, inout SurfaceOutputStandard o) {
				o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Albedo.rgb;
				float3 normal = UnpackNormal(tex2D(_BumpTex, IN.uv_BumpTex));
				normal.z = normal.z / _NormalAmount;
				o.Normal = normal;

				// Rim lighting
				//half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
				//o.Emission = _RimAlbedo.rgb * pow(rim, _RimPower);
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Albedo;
				o.Albedo = c.rgb;
				// Metallic and smoothness come from slider variables
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Alpha = c.a;
			}
			ENDCG

				Pass
			{
				Cull Front

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

			#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					float4 Albedo : Albedo;
				};

				float4 _OutlineAlbedo;
				float _OutlineSize;

				v2f vert(appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);

					float3 norm = normalize(mul((float3x3)UNITY_MATRIX_IT_MV,
					v.normal));
					float2 offset = TransformViewToProjection(norm.xy);

					//Tamaño de la linea alrededor del cuerpo y profundidad;
					o.pos.xy += offset * o.pos.z * _OutlineSize;
					o.Albedo = _OutlineAlbedo;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					return i.Albedo;
				}

				ENDCG

		}

		}
}