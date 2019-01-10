Shader "ImageEffect/Bloom"
{
	Properties		//变量定义
	{
		_MainTex ("Texture", 2D) = "white" {}	//主贴图
	}
	CGINCLUDE
	#include "UnityCG.cginc"
	struct v2f
	{
		fixed4 pos:SV_POSITION;
		fixed2 uv:TEXCOORD0;
	};

	sampler2D _MainTex;		
	fixed4 _MainTex_TexelSize;		
	fixed4 _ColorThreshold;
	
	v2f  vert (appdata_img v)
	{
		v2f  o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv=v.texcoord.xy;
		return o;
	}
	fixed4 threshold_frag (v2f i) : SV_Target		
	{
		fixed4 col = tex2D(_MainTex,i.uv);	
		return saturate(col-_ColorThreshold);		
	} 


	fixed _BlurRadius;		//模糊采样半径

	fixed4 blur_frag (v2f i) : SV_Target		//均值模糊代码 3*3采样（可优化）
	{
		fixed4 col = fixed4(0,0,0,0);	
		fixed2 offset=_BlurRadius*_MainTex_TexelSize;	
		for (int x=0;x<3;x++){		
			for (int y=0;y<3;y++){
				col+=tex2D(_MainTex,i.uv+fixed2(x-1,y-1)*offset);	
			}
		} 
		col=col/9;
		col.a=1;
		return col;		
	} 

	sampler2D _BloomTex;	//用于从外部获取模糊处理后的贴图
	fixed4 _BloomColor;		//bloom发光的倾向色
	fixed _BloomScale;		//bloom发光强度

	fixed4 bloom_frag(v2f i) : SV_Target
	{
		
		fixed4 oColor = tex2D(_MainTex, i.uv);
		fixed4 bColor = tex2D(_BloomTex, i.uv);
		fixed4 o = oColor +bColor* _BloomScale * _BloomColor;	//输出= 原始图像，叠加bloom权值*bloom颜色*泛光颜色
		return o;
	}

	ENDCG
	SubShader
	{
		Cull Off ZWrite Off ZTest Always 
		Pass	//Pass0 通道 进行颜色阈值过滤
		{
			CGPROGRAM
			#pragma vertex vert	
			#pragma fragment threshold_frag
			ENDCG
		}
		Pass	//Pass1 通道 进行模糊处理
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment blur_frag
			ENDCG
		}
		Pass	//Pass2 通道 将两张图进行合成并偏向一个颜色发光
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment bloom_frag
			ENDCG
		}
	}
}
