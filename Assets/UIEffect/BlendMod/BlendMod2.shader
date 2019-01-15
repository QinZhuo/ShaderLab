Shader "Unlit/BlendMod2"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlendTex ("Texture", 2D) = "white" {}
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
	sampler2D _BlendTex;
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
		
		fixed4 A = tex2D(_MainTex, i.uv);	//A为底图rgba 四维向量
		fixed4 B = tex2D(_BlendTex,i.uv);	//B为混合图rgba 四维向量
		
		//--------只更改这的代码------------
		fixed4 C =A*(1-B.a)+B*(B.a);	//正常透明度混合
		//---------------------------------

		// fixed4 C =A*(1-B.a)+B*(B.a);	//正常透明度混合

		// fixed4 C =min(A,B);	//变暗

		// fixed4 C =max(A,B);	//变亮

		// fixed4 C =A*B ;	//正片叠底


		// fixed4 C=1-((1-A)*(1-B));//滤色 A+B-A*B

		// fixed4 C =A-((1-A)*(1-B))/B; //颜色加深

		// fixed4 C= A+(A*B)/(1-B); //颜色减淡

		// fixed4 C=A+B-1;//线性加深

		// fixed4 C=A+B; //线性减淡
		
		// fixed4 ifFlag= step(A,fixed4(0.5,0.5,0.5,0.5));
		// fixed4 C=ifFlag*A*B*2+(1-ifFlag)*(1-(1-A)*(1-B)*2);//叠加
		
		// fixed4 ifFlag= step(B,fixed4(0.5,0.5,0.5,0.5));
		// fixed4 C=ifFlag*A*B*2+(1-ifFlag)*(1-(1-A)*(1-B)*2); //强光

		// fixed4 ifFlag= step(B,fixed4(0.5,0.5,0.5,0.5));
		// fixed4 C=ifFlag*(A*B*2+A*A*(1-B*2))+(1-ifFlag)*(A*(1-B)*2+sqrt(A)*(2*B-1)); //柔光
		
		// fixed4 ifFlag= step(B,fixed4(0.5,0.5,0.5,0.5));
		// fixed4 C=ifFlag*(A-(1-A)*(1-2*B)/(2*B))+(1-ifFlag)*(A+A*(2*B-1)/(2*(1-B))); //亮光

		// fixed4 ifFlag= step(B,fixed4(0.5,0.5,0.5,0.5));	//不知道为什么很多资料亮光效果都写两个min 实际效果还原应该是是一个min一个max
		// fixed4 C=ifFlag*(min(A,2*B))+(1-ifFlag)*(max(A,( B*2-1))); //点光  
		
		// fixed4 C=A+2*B-1; //线性光

		// fixed4 ifFlag= step(A+B,fixed4(1,1,1,1));
		// fixed4 C=ifFlag*(fixed4(0,0,0,0))+(1-ifFlag)*(fixed4(1,1,1,1)); //实色混合

		// fixed4 C=A+B-A*B*2; //排除

		// fixed4 C=abs(A-B); //差值

		// fixed4 ifFlag= step(B.r+B.g+B.b,A.r+A.g+A.b);
		// fixed4 C=ifFlag*(B)+(1-ifFlag)*(A); //深色

		// fixed4 ifFlag= step(B.r+B.g+B.b,A.r+A.g+A.b);
		// fixed4 C=ifFlag*(A)+(1-ifFlag)*(B); //浅色

		// fixed4 C=A-B; //减去

		// fixed4 C=A/B; //划分

		return C;
	}
	
	ENDCG
	SubShader
	{
		Tags { "Queue"="Transparent" }
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			ENDCG
		}
	}
}
