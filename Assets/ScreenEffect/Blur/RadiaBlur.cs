using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RadiaBlur : ScreenEffect  {
	[Range(-0.05f,0.05f),Tooltip("模糊强度")]
	public float blurScale=0.01f;
	public Vector2 center=new Vector2(0.5f,0.5f);
	private void OnRenderImage(RenderTexture src, RenderTexture dest) {
		if(material){
	
			material.SetVector("_Center",center);
			material.SetFloat("_BlurScale",blurScale);
			Graphics.Blit(src,dest,material);	//将最终图像赋值给输出图像
		}
	}
}
