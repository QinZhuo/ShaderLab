// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/LogoShader" {
    Properties {
        _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader
    {
   Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
   Blend SrcAlpha OneMinusSrcAlpha 
        AlphaTest Greater 0.1
        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
       
            sampler2D _MainTex;
            float4 _MainTex_ST;
           
            struct v2f {
                float4  pos : SV_POSITION;
                float2  uv : TEXCOORD0;
            };
           
            //顶点函数没什么特别的，和常规一样
            v2f vert (appdata_base v)
            {
                v2f o;
                   o.pos = UnityObjectToClipPos(v.vertex);
                o.uv =    TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }
           
            //必须放在使用其的 frag函数之前，否则无法识别。
            //核心：计算函数，角度，uv,光带的x长度，间隔，开始时间，偏移，单次循环时间
            float inFlash(float angle,float2 uv,float xLength,int interval,int beginTime, float offX, float loopTime )
            {
                //亮度值
                float brightness =0;
               
                //倾斜角
                float angleInRad = 0.0174444 * angle;
               
                //当前时间
                float currentTime = _Time.y;
           
                //获取本次光照的起始时间
                int currentTimeInt = _Time.y/interval;
                currentTimeInt *=interval;
               
                //获取本次光照的流逝时间 = 当前时间 - 起始时间
                float currentTimePassed = currentTime -currentTimeInt;
                if(currentTimePassed >beginTime)
                {
                    //底部左边界和右边界
                    float xBottomLeftBound;
                    float xBottomRightBound;

                    //此点边界
                    float xPointLeftBound;
                    float xPointRightBound;
                   
                    float x0 = currentTimePassed-beginTime;
                    x0 /= loopTime;
           
                    //设置右边界
                    xBottomRightBound = x0;
                   
                    //设置左边界
                    xBottomLeftBound = x0 - xLength;
                   
                    //投影至x的长度 = y/ tan(angle)
                    float xProjL;
                    xProjL= (uv.y)/tan(angleInRad);

                    //此点的左边界 = 底部左边界 - 投影至x的长度
                    xPointLeftBound = xBottomLeftBound - xProjL;
                    //此点的右边界 = 底部右边界 - 投影至x的长度
                    xPointRightBound = xBottomRightBound - xProjL;
                   
                    //边界加上一个偏移
                    xPointLeftBound += offX;
                    xPointRightBound += offX;
                   
                    //如果该点在区域内
                    if(uv.x > xPointLeftBound && uv.x < xPointRightBound)
                    {
                        //得到发光区域的中心点
                        float midness = (xPointLeftBound + xPointRightBound)/2;
                       
                        //趋近中心点的程度，0表示位于边缘，1表示位于中心点
                        float rate= (xLength -2*abs(uv.x - midness))/ (xLength);
                        brightness = rate;
                    }
                }
                brightness= max(brightness,0);
               
                //返回颜色 = 纯白色 * 亮度
                float4 col = float4(1,1,1,1) *brightness;
                return brightness;
            }
           
            float4 frag (v2f i) : COLOR
            {
                 float4 outp;
                
                 //根据uv取得纹理颜色，和常规一样
                float4 texCol = tex2D(_MainTex,i.uv);
       
                //传进i.uv等参数，得到亮度值
                float tmpBrightness;
                tmpBrightness =inFlash(75,i.uv,0.25,5,2,0.15,0.7);
           
                //图像区域，判定设置为 颜色的A > 0.5,输出为材质颜色+光亮值
                if(texCol.w >0.5)
                        outp  =texCol+float4(1,1,1,1)*tmpBrightness;
                //空白区域，判定设置为 颜色的A <=0.5,输出空白
                else
                    outp =float4(0,0,0,0);

                return outp;
            }
            ENDCG
        }
    }
}