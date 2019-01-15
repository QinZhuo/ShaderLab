
Shader "Unlit/SingleMoveLightImage"
{
	 
	Properties
	{
		//偏移量
		_Of("offset",float)=0
		//光照强度
		_LightScale("Light Scale",float)=0.5
		//主纹理
		_MainTex("Texture",2D)="white"{}
		//灯光纹理
		_LightTex("Light Texture",2D)="white"{}
	
		_UVUpScale("UpScale",float)=0.1

		_Speed("Speed",float)=0.5

		_Color("Color",Color)=(1,1,1,1)
	}
	SubShader
	{
		Tags{"Queue"="Transparent"
		 "RenderType"="Transparent"}
		LOD 100
		//透明混合
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
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

			fixed4 _Color;
			float _Of;
			float _LightScale;
			fixed _UVUpScale;
			fixed _Speed;
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
				

				//计算uv偏移
				float2 uv1=i.uv;
				uv1.x/=2;
			
				//uv1.x+=_Of;
				uv1.x+=_Time.y*_Speed;

				//根据uv获取对应透明度
				fixed lightTexA=tex2D(_LightTex,uv1).a;
				//获取遮罩贴图的alpha值，黑色为0，白色为1 这里的uv和上面的uv是调用的不一样的函数
				
				
				
				fixed4 mainColor=tex2D(_MainTex, i.uv);

				half2 uv=i.uv;
				uv.y-=_UVUpScale*lightTexA;

				mainColor=tex2D(_MainTex,uv);

				//主纹理+灯光贴图*遮罩贴图 简单原理任何数*0为0   这样就避免了遮罩外出现不协调灯光贴图  （现为正片叠底效果）
				fixed4 col = mainColor+lightTexA*mainColor.a*_LightScale*_Color;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);				
				return col;
			}
			ENDCG
		}
	}
}