// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "ImageEffect/GaussianBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurRadius("radius",float)=1
		_BlurScale("scale",Range(0,1))=0.5 
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"

	struct v2f_blur
	{
		float4 pos:SV_POSITION;
		float2 uv:TEXCOORD0;
	
	};

	sampler2D _MainTex;
	float4 _MainTex_TexelSize;
	float _BlurRadius;


	

	v2f_blur  vert (appdata_img v)
	{
		v2f_blur  o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv=v.texcoord.xy;
		return o;
	}

	fixed4 frag (v2f_blur i) : SV_Target
	{
		fixed4 col = fixed4(0,0,0,0);
		float2 offset=_BlurRadius*_MainTex_TexelSize;

		half G[9]={
			1,2,1,
			2,4,2,
			1,2,1
		};

		for (int x=0;x<3;x++){
			for (int y=0;y<3;y++){
				col+=tex2D(_MainTex,i.uv+fixed2(x-1,y-1)*offset)*G[x*1+y*3];
			}
		}
		
	
		// just invert the colors
		
		return col/16;
	} 
	ENDCG
	SubShader
	{
	
		// No culling or depth
		Cull Off ZWrite Off ZTest Always 

		
	

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	
	}
}
