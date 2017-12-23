// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Grab/Noise"
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

			float rand(float2 co){
			    return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
			}
						
			fixed4 Calc (fixed4 a, fixed4 b)
			{ 
				fixed4 r = fixed4(
					rand(float2(a.x, b.y)) * 0.3 + b.x * 0.7,
					rand(float2(b.x, a.y)) * 0.3 + b.y * 0.7,
					rand(float2(a.y, b.x)) * 0.3 + b.z * 0.7,
					a.a
				);
				r.a = b.a;
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