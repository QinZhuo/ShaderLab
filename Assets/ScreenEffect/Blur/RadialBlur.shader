
Shader "ImageEffect/RadialBlur"
{
	Properties		//变量定义
	{
		_MainTex ("Texture", 2D) = "white" {}	//主贴图
		_BlurScale("BlurScale",Range(0,0.05))=0
		
	}
	CGINCLUDE
	#include "UnityCG.cginc"
	struct v2f
	{
		fixed4 pos:SV_POSITION;
		fixed2 uv:TEXCOORD0;
	};
	sampler2D _MainTex;		//基础颜色贴图输入
	fixed4 _MainTex_TexelSize;		//XX_TexelSize，XX纹理的像素相关大小width，height对应纹理的分辨率，x = 1/width, y = 1/height, z = width, w = height
	fixed _BlurScale;		//模糊强度
	fixed2 _Center;		//径向模糊中心
	//#define Count 5;
	v2f  vert (appdata_img v)
	{
		v2f  o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv=v.texcoord.xy;
		return o;
	}
	fixed4 frag (v2f i) : SV_Target		//frag片段函数 会对每一个像素点执行此函数 输入像素颜色等信息 输出最终该点颜色
	{
		fixed4 col = fixed4(0,0,0,0);	//初始化颜色为黑色 fixed4及四维向量 精度为fixed以此类推 
		fixed2 dir=i.uv-_Center;

		for (int x=0;x<5;x++){			//循环遍历周围像素点
			col+=tex2D(_MainTex,dir*_BlurScale*x+i.uv);	//全部加和			
		}
		col=col/5;
		col.a=1;
		return col;		//因遍历周围9各像素点
	} 
	ENDCG
	SubShader
	{
		Cull Off ZWrite Off ZTest Always 
		Pass	//Pass 通道 主要是实现一些顶点和片段着色器功能
		{
			CGPROGRAM	//CG程序开始
			 //声明顶点着色器函数名字为vert
			#pragma vertex vert	
			 //声明片段着色器函数名字为frag
			#pragma fragment frag
			ENDCG		 //CG程序结束
		}
	}
}
