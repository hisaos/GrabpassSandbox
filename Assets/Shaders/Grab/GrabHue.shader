// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Grab/Hue"
{
	Properties
	{
		_MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags
		{ 
			"Queue" = "Transparent" 
			"RenderType" = "Transparent" 	
		}
		
		Blend SrcAlpha OneMinusSrcAlpha

		GrabPass { }

		Pass
		{
			CGPROGRAM
			
			#include "UnityCG.cginc"
			
			#pragma vertex ComputeVertex
			#pragma fragment ComputeFragment
			
			sampler2D _MainTex;
			sampler2D _GrabTexture;
			fixed4 _Color;

			float Epsilon = 1e-10;

			struct VertexInput
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct VertexOutput
			{
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				half2 texcoord : TEXCOORD0;
				float4 screenPos : TEXCOORD1;
			};
			
			VertexOutput ComputeVertex (VertexInput vertexInput)
			{
				VertexOutput vertexOutput;
				
				vertexOutput.vertex = UnityObjectToClipPos(vertexInput.vertex);
				vertexOutput.screenPos = vertexOutput.vertex;	
				vertexOutput.texcoord = vertexInput.texcoord;
				vertexOutput.color = vertexInput.color * _Color;
							
				return vertexOutput;
			}

			float3 RGBtoHCV (float3 RGB)
			{
				float4 P = (RGB.g < RGB.b) ? float4(RGB.bg, -1.0, 2.0/3.0) : float4(RGB.gb, 0.0, -1.0/3.0);
				float4 Q = (RGB.r < P.x) ? float4(P.xyw, RGB.r) : float4(RGB.r, P.yzx);
				float C = Q.x - min(Q.w, Q.y);
				float H = abs((Q.w - Q.y) / (6 * C + Epsilon) + Q.z);
				return float3(H, C, Q.x);
			}

			float3 RGBtoHSV (float3 RGB)
			{
				float3 HCV = RGBtoHCV(RGB);
				float S = HCV.y / (HCV.z + Epsilon);
				return float3(HCV.x, S, HCV.z);
			}

			float3 HUEtoRGB (float H)
			{
				float R = abs(H * 6 - 3) - 1;
				float G = 2 - abs(H * 6 - 2);
				float B = 2 - abs(H * 6 - 4);
				return saturate(float3(R, G, B));
			}

			float3 HSVtoRGB (float3 HSV)
			{
				float3 RGB = HUEtoRGB(HSV.x);
				return ((RGB - 1) * HSV.y + 1) * HSV.z;
			}

			fixed4 Calc (fixed4 a, fixed4 b)
			{ 
				float3 a_hsv = RGBtoHSV(float3(a.x, a.y, a.z));
				float3 b_hsv = RGBtoHSV(float3(b.x, b.y, b.z));

				float3 r_hsv = float3(a_hsv.x, b_hsv.y, b_hsv.z);
				fixed4 r = fixed4(r_hsv.x, r_hsv.y, r_hsv.z, b.a);
				return r;
			} 
			
			fixed4 ComputeFragment (VertexOutput vertexOutput) : SV_Target
			{
				half4 color = tex2D(_MainTex, vertexOutput.texcoord) * vertexOutput.color;
				
				float2 grabTexcoord = vertexOutput.screenPos.xy / vertexOutput.screenPos.w; 
				grabTexcoord.x = (grabTexcoord.x + 1.0) * .5;
				grabTexcoord.y = (grabTexcoord.y + 1.0) * .5; 
				#if UNITY_UV_STARTS_AT_TOP
				grabTexcoord.y = 1.0 - grabTexcoord.y;
				#endif
				
				fixed4 grabColor = tex2D(_GrabTexture, grabTexcoord); 
				
				return Calc(grabColor, color);
			}
			
			ENDCG
		}
	}

	Fallback "UI/Default"
}