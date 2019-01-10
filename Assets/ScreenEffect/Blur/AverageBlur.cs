using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[System.Serializable]
public class AverageBlur : ScreenEffect {
	[Range(0,5),Tooltip("降采样")]
	public int  downSample=2;
	[Range(0,10),Tooltip("模糊半径")]
	public float blurRadius=1.0f;
	[Range(0,5),Tooltip("迭代次数")]
	public int iteration=2;
	private void OnRenderImage(RenderTexture src, RenderTexture dest) {
		if(material){
			RenderTexture rt1=RenderTexture.GetTemporary(src.width>>downSample,src.height>>downSample,0,src.format);	
			//将图片降低采样也就是降低分辨率 加快速度 >>为C#位运算符
			RenderTexture rt2=RenderTexture.GetTemporary(src.width>>downSample,src.height>>downSample,0,src.format);

			Graphics.Blit(src,rt1);		//将源图像复制给rt1
			material.SetFloat("_BlurRadius",blurRadius);	//将模糊半径赋值给对应的材质球 （此处材质球为父类用对应shader创建）
			for(int i=0;i<iteration;i++){				//循环调用material对应的处理函数 次数为迭代次数 也就是循环次数
				Graphics.Blit(rt1,rt2,material);
				Graphics.Blit(rt2,rt1,material);
			}
			Graphics.Blit(rt1,dest);	//将最终图像赋值给输出图像
			RenderTexture.ReleaseTemporary(rt1);	//释放RenderTexture
			RenderTexture.ReleaseTemporary(rt2);
		}
	}
}
