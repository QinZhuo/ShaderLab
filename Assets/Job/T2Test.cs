using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class T2Test : MonoBehaviour {

	float timer=0;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		timer+=Time.deltaTime;
		GetComponent<Image>().material.SetFloat("_Of",timer*0.3f);
	}
}
