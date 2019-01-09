// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/L2_1" {
   Properties {
        _MainTex ("Base", 2D) = "white" 
    }
    SubShader {
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            sampler2D _MainTex;
            float4 _MainTex_ST;
            struct v2f {
                float4  pos : SV_POSITION;
                float2  uv : TEXCOORD0;
            } ;
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.vertex.xy;
                return o;
            }
            float4 frag (v2f i) : COLOR
            {
                float4 texCol = tex2D(_MainTex,i.uv);
                return texCol;
            }
            ENDCG
        }
    }
}