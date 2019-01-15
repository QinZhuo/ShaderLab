Shader "Unlit/BlendMod"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		UNITY_FOG_COORDS(1)
		float4 vertex : SV_POSITION;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	
	v2f vert (appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		UNITY_TRANSFER_FOG(o,o.vertex);
		return o;
	}
	
	fixed4 frag (v2f i) : SV_Target
	{
		// sample the texture
		fixed4 col = tex2D(_MainTex, i.uv);
		// apply fog
		
		return col;
	}

	ENDCG

	SubShader
	{
		Tags { "Queue"="Transparent"}

		//Blend SrcAlpha OneMinusSrcAlpha  //正常透明混合

		//BlendOp Min Blend One One //变暗

		//BlendOp Max Blend One One //变亮

		//Blend DstColor Zero //正片叠底 (Multiply)相乘 

		Blend OneMinusDstColor One   //滤色 //柔和相加(soft Additive) 
		
		//Blend DstColor SrcColor //两倍相乘 (2X Multiply) 

		//Blend One One //线性减淡

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
		
			ENDCG
		}
	}
}
