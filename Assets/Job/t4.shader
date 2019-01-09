Shader "Unlit/Walk light"
{
    Properties
    {
        _MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}
        _LightTex ("Light", 2D) = "black" {}
    }
    
    SubShader
    {
        LOD 200

        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
        }
        
        Pass
        {
            Cull Off
            Lighting Off
            ZWrite Off
            Fog { Mode Off }
            Offset -1, -1
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag            
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _LightTex;
    
            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                fixed4 color : COLOR;
            };
    
            struct v2f
            {
                float4 vertex : SV_POSITION;
                half2 texcoord : TEXCOORD0;
                fixed4 color : COLOR;
            };
    
            v2f o;

            v2f vert (appdata_t v)
            {
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = v.texcoord;
                o.color = v.color;
                return o;
            }
                
            fixed4 frag (v2f IN) : COLOR
            {
                fixed4 main = tex2D(_MainTex, IN.texcoord);
                
                half lightU = IN.texcoord.x - frac(_Time.y);
                half2 lightUV = half2(lightU, IN.texcoord.y);
                fixed4 light = tex2D(_LightTex, lightUV);
                
                fixed4 col = main + main * light.a;
                return  col * IN.color;
            }
            ENDCG
        }
    }

    SubShader
    {
        LOD 100

        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
        }
        
        Pass
        {
            Cull Off
            Lighting Off
            ZWrite Off
            Fog { Mode Off }
            Offset -1, -1
            ColorMask RGB
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMaterial AmbientAndDiffuse
            
            SetTexture [_MainTex]
            {
                Combine Texture * Primary
            }
        }
    }
}