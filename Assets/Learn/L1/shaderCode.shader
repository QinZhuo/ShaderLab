// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Learn/L1" {
    Properties {
        _MainTex ("Texture", 2D) = "white" { }
        _Cloud ("_Cloud", 2D) = "white" { }
    }
    SubShader {
        Tags{"Queue" = "Transparent" "RenderType"="Transparent"}
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            float4 _Color;
            sampler2D _MainTex;
            sampler2D _Cloud;
            struct v2f {
                float4  pos : SV_POSITION;
                float2  uv : TEXCOORD0;
            } ;
            float4 _MainTex_ST;
            v2f vert (appdata_base v)
                {
               //和之前一样
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
                return o;
            }
            half4 frag (v2f i) : COLOR
            {
                //地球的贴图uv, x即横向在动
                float u_x = i.uv.x + -0.1*_Time;
                float2 uv_earth=float2( u_x , i.uv.y);
                half4 texcolor_earth = tex2D (_MainTex, uv_earth);

                 //云层的贴图uv的x也在动，但是动的更快一些 
                float2 uv_cloud;
                u_x = i.uv.x + -0.2*_Time;
                uv_cloud=float2( u_x , i.uv.y);
                half4 tex_cloudDepth = tex2D (_Cloud, uv_cloud);

                //纯白 x 深度值= 该点的云颜色
                half4 texcolor_cloud = float4(1,1,1,0) * (tex_cloudDepth.x);

                //地球云彩颜色混合
                return lerp(texcolor_earth,texcolor_cloud,0.5f);
            }
            ENDCG
        }
    }
}