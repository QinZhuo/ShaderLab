Shader "Unlit/MoveLightImage"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}	//底图贴图
		_LightTex("Texture",2D) = "white" {}	//混合光照贴图
		_LightScale("Light Scale",float) = 0.5	//光照强度
		_Speed("Speed",float) = 0.5				//缓动速度
		_Color("Color",Color) = (1,1,1,1)		//发光颜色偏向 白色(1,1,1,1)为不偏向
		_UpScale("Up Scale",float) = 0.2	//突起程度
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
	sampler2D _LightTex;
	fixed _LightScale;
	fixed _Speed;
	fixed _UpScale;
	fixed4 _Color;
	
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
		fixed4 A = tex2D(_MainTex, i.uv);	//主贴图颜色获取

		half2 uv=i.uv;
		uv.x/=2;				//取光线图的一半内容
		uv.x+=_Time.y*_Speed;	//根据时间进行偏移

		fixed4 B = tex2D(_LightTex,uv);		//uv偏移后颜色获取

		half2 uvUp=i.uv;
		uvUp.y-=_UpScale*B.a;		//根据透明度对y轴偏移来达到凸起的效果

		A= tex2D(_MainTex, uvUp);		//根据偏移后的uv重新取一下颜色

		fixed4 C=A+A.a*B*_Color*_LightScale; //加上主贴图颜色
		return C; 	
	}

	ENDCG

	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha	//正常透明混合
		Pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
