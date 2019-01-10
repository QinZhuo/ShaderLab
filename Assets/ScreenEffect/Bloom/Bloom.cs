using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : ScreenEffect {
	public Color ThresholdColor;
	public Color BloomColor;
	[Range(0,3),Tooltip("发光强度")]
	public float BloomScale;

	[Range(0,5),Tooltip("降采样")]
	public int  downSample=2;
	[Range(0,10),Tooltip("模糊半径")]
	public float blurRadius=1.0f;
	[Range(0,5),Tooltip("迭代次数")]
	public int iteration=2;
	
	private void OnRenderImage(RenderTexture src, RenderTexture dest) {
		if(material){
			//降分辨率
			RenderTexture rt1=RenderTexture.GetTemporary(src.width>>downSample,src.height>>downSample,0,src.format);	//将图片降低采样也就是降低分辨率 加快速度 >>为C#位运算符
			RenderTexture rt2=RenderTexture.GetTemporary(src.width>>downSample,src.height>>downSample,0,src.format);
			Graphics.Blit(src,rt1);		//将源图像复制给rt1


			//进行颜色阈值过滤
			material.SetColor("_ColorThreshold",ThresholdColor);
			Graphics.Blit(rt1,rt2,material,0);	//执行最简单没有迭代的材质球效果
			

			//均值模糊
			material.SetFloat("_BlurRadius",blurRadius);
			for(int i=0;i<iteration;i++){				//循环调用material对应的处理函数 次数为迭代次数 也就是循环次数
				Graphics.Blit(rt2,rt1,material,1);
				Graphics.Blit(rt1,rt2,material,1);
			}

			//将原图像与模糊后的图像混合
			material.SetTexture("_BloomTex",rt2);
			material.SetColor("_BloomColor",BloomColor);
			material.SetFloat("_BloomScale",BloomScale);
			

			//输出图像
			Graphics.Blit(src,dest,material,2);	//将最终图像赋值给输出图像
			RenderTexture.ReleaseTemporary(rt1);	//释放RenderTexture
			RenderTexture.ReleaseTemporary(rt2);
		}
	}

	
	

}
