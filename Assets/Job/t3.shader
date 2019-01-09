Shader "UI/Unlit/Flowlight"
{
    Properties
    {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1, 1, 1, 1)
        [MaterialToggle] PixelSnap("Pixel snap", float) = 0

        /* Flowlight */
        _FlowlightColor("Flowlight Color", Color) = (1, 0, 0, 1)
        _Lengthlitandlar("LangthofLittle and Large", range(0,0.5)) = 0.005
        _MoveSpeed("MoveSpeed", float) = 5
        _Power("Power", float) = 1
        _LargeWidth("LargeWidth", range(0,0.005)) = 0.0035
        _LittleWidth("LittleWidth", range(0,0.001)) = 0.002
        /* --------- */
            _WidthRate("WidthRate",float) = 0
            _XOffset("XOffset",float) = 0
            _HeightRate("HeightRate",float) = 0
            _YOffset("YOffset",float) = 0

        /* UI */
        _StencilComp("Stencil Comparison", Float) = 8
        _Stencil("Stencil ID", Float) = 0
        _StencilOp("Stencil Operation", Float) = 0
        _StencilWriteMask("Stencil Write Mask", Float) = 255
        _StencilReadMask("Stencil Read Mask", Float) = 255
        _ColorMask("Color Mask", Float) = 15
        /* -- */
    }

        SubShader
    {
        Tags
    {
        "Queue" = "Transparent"
        "IgnoreProjector" = "True"
        "RenderType" = "Transparent"
        "PreviewType" = "Plane"
        "CanUseSpriteAtlas" = "True"
    }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha
        ColorMask[_ColorMask]
            /* UI */
            Stencil
        {
            Ref[_Stencil]
            Comp[_StencilComp]
            Pass[_StencilOp]
            ReadMask[_StencilReadMask]
            WriteMask[_StencilWriteMask]
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
        float4 worldPosition: TEXCOORD1;
    };

    fixed4 _Color;
    /* Flowlight */
    float _Power;
    float _LargeWidth;
    float _LittleWidth;
    float _Lengthlitandlar;
    float _MoveSpeed;
    fixed4 _FlowlightColor;
    /* --------- */
    float _UVPosX;
    v2f vert(appdata_t IN)
    {
        v2f OUT;
        OUT.worldPosition = IN.vertex;
        OUT.vertex = UnityObjectToClipPos(IN.vertex);
        OUT.texcoord = IN.texcoord;
        OUT.color = IN.color * _Color;
#ifdef PIXELSNAP_ON
        OUT.vertex = UnityPixelSnap(OUT.vertex);
#endif

        return OUT;
    }

    sampler2D _MainTex;
    float4 _MainTex_ST;
    float _WidthRate;
    float _XOffset;
    float _HeightRate;
    float _YOffset;


    bool _UseClipRect;
    float4 _ClipRect;
    float _ClipSoftX;
    float _ClipSoftY;
    fixed4 frag(v2f IN) : SV_Target
    {
        fixed4 c = tex2D(_MainTex, IN.texcoord);
        /*使用裁剪*/
        if (_UseClipRect)
        {
            float2 factor = float2(0.0, 0.0);
            float2 tempXY = (IN.worldPosition.xy - _ClipRect.xy) / float2(_ClipSoftX, _ClipSoftY)*step(_ClipRect.xy, IN.worldPosition.xy);
            factor = max(factor, tempXY);
            float2 tempZW = (_ClipRect.zw - IN.worldPosition.xy) / float2(_ClipSoftX, _ClipSoftY)*step(IN.worldPosition.xy, _ClipRect.zw);
            factor = min(factor, tempZW);
            c.a *= clamp(min(factor.x, factor.y), 0.0, 1.0);
        }
        /* --------- */

        /* Flowlight */
        //计算流动的标准uvX从-0.5到1.5范围
        _UVPosX = _XOffset +(fmod(_Time.x*_MoveSpeed, 1) * 2 -0.5)* _WidthRate;
        //标准uvX倾斜
        _UVPosX += (IN.texcoord.y- _HeightRate*0.5- _YOffset)*0.2;
        //以下是计算流光在区域内的强度，根据到标准点的距离的来确定强度，为了使变化更柔和非线性，使用距离平方或者sin函数也可以
        float lar = pow(1 - _LargeWidth*_WidthRate, 2);
        float lit = pow(1 - _LittleWidth*_WidthRate, 2);
        //第一道流光，可以累加任意条，如下
        fixed4 cadd = _FlowlightColor* saturate((1 - saturate(pow(_UVPosX - IN.texcoord.x,2))) - lar)*_Power /(1-lar);
        cadd += _FlowlightColor* saturate((1 - saturate(pow(_UVPosX - _Lengthlitandlar*_WidthRate - IN.texcoord.x, 2))) - lit)*_Power/ (1-lit);

        c.rgb += cadd.rgb;
        c.rgb *= c.a;
        /* --------- */

        return c;
    }
        ENDCG
    }
    }
}
