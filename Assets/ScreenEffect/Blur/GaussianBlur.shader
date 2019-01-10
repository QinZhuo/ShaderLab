Shader "ImageEffect/GaussianBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurRadius("radius",float)=1
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
		fixed4 col = fixed4(0,0,0,0);	//初始化色彩为黑色
		float2 offset=_BlurRadius*_MainTex_TexelSize;
		half G[9]={		//设置卷积模板   此处是3*3的高斯模板
			1,2,1,
			2,4,2,
			1,2,1
		};
		for (int x=0;x<3;x++){	//进行3*3高斯模板的卷积（加权求平均值）
			for (int y=0;y<3;y++){
				col+=tex2D(_MainTex,i.uv+fixed2(x-1,y-1)*offset)*G[x*1+y*3];
			}
		}
		col=col/16;
		col.a=1;
		return col;
	} 
	ENDCG
	SubShader
	{
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
