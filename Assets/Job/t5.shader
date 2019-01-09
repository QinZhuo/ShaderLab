// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "UI/Unlit/Flowlight"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1, 1, 1, 1)
        [MaterialToggle] PixelSnap ("Pixel snap", float) = 0
        
        /* Flowlight */
        _FlowlightTex ("Add Move Texture", 2D) = "white" {}
        _FlowlightColor ("Flowlight Color", Color) = (0, 0, 0, 1)
        _Power ("Power", float) = 1
        _SpeedX ("SpeedX", float) = 1
        _SpeedY ("SpeedY", float) = 0
        /* --------- */

        /* UI */
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        /* -- */
    }

    SubShader
    {
        Tags
        { 
            "Queue"="Transparent" 
            "IgnoreProjector"="True" 
            "RenderType"="Transparent" 
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha
        
        /* UI */
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp] 
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }
        /* -- */

        Pass
        {
        CGPROGRAM        
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ PIXELSNAP_ON
            #include "UnityCG.cginc"
            
            struct appdata_t
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                half2 texcoord : TEXCOORD0;

                /* Flowlight */
                half2 texflowlight : TEXCOORD1;
                /* --------- */
            };
            
            fixed4 _Color;

            /* Flowlight */
            fixed4 _FlowlightColor;
            float _Power;
            sampler2D _FlowlightTex;
            fixed4 _FlowlightTex_ST;
            fixed _SpeedX;
            fixed _SpeedY;
            /* --------- */

            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;

                /* Flowlight */
                OUT.texflowlight = TRANSFORM_TEX(IN.texcoord, _FlowlightTex);
                OUT.texflowlight.x += _Time * _SpeedX;
                OUT.texflowlight.y += _Time * _SpeedY;
                /* --------- */

                OUT.color = IN.color * _Color;
                #ifdef PIXELSNAP_ON
                OUT.vertex = UnityPixelSnap (OUT.vertex);
                #endif

                return OUT;
            }

            sampler2D _MainTex;

            fixed4 frag(v2f IN) : SV_Target
            {
                fixed4 c = tex2D(_MainTex, IN.texcoord);

                /* Flowlight */
                fixed4 cadd = tex2D(_FlowlightTex, IN.texflowlight) * _Power;
                cadd.rgb *= c.rgb;
                c.rgb += cadd.rgb;
                c.rgb *= c.a;
                /* --------- */

                return c;
            }
        ENDCG
        }
    }
}