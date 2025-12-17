/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/16 11:19

* 描述： Unity引擎方法实现集
* 
*/





#ifndef Def_IrisMethodUnity
#define Def_IrisMethodUnity

//==={定义Unity的方法宏]===

// 纹理坐标缩放偏移 float2  2d纹理 => float2 :TRANSFORM_TEX(uv,tex)
#define Iris_Transform_TEX(uv,tex) TRANSFORM_TEX(uv,tex)


//光照相关方法
#ifdef Use_ShaderLighting

//URP获取主光源信息
#ifdef IrisShader_URP
Iris_Light IrisGetMainLight()
{
    Iris_Light light;
    Light urpLight = GetMainLight();
    light.Direction = urpLight.direction;
    light.Color = urpLight.color;
    light.DistanceAttenuation = urpLight.distanceAttenuation;
    light.ShadowAttenuation = urpLight.shadowAttenuation;
    light.LayerMask = urpLight.layerMask; 
    return light;
}
#endif

#endif





#endif


