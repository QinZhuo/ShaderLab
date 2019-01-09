using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]	//在编辑器模式下也运行
public class ScreenEffect : MonoBehaviour {
	public Shader shader;	//效果对应shader

	private Material m_material;	//材质球
	protected Material material{	//材质球访问器
		get{
			if(m_material==null&&shader!=null){
				m_material=new Material(shader);	//如果材质球为空用shader创建对应材质球
			}
			return m_material;
		}
	}
	private void OnRenderImage(RenderTexture src, RenderTexture dest) {
		if(material){
			Graphics.Blit(src,dest,material);	//执行最简单没有迭代的材质球效果
		}
	}
}
