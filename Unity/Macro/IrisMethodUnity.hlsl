/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/16 11:19

* 描述： Unity引擎方法实现集
* 
*/





#ifndef Def_IrisMethodUnity
#define Def_IrisMethodUnity

//===[定义Unity的方法宏]===

// 纹理坐标缩放偏移 float2  2d纹理 => float2 :TRANSFORM_TEX(uv,tex)
#define Iris_Transform_TEX(uv,tex) TRANSFORM_TEX(uv,tex)

//光照相关方法
#ifdef Use_ShaderLighting

//URP获取主光源信息
#ifdef IrisShader_URP
// 无参数版本（无阴影支持）
Iris_Light Iris_GetMainLight()
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

// 带世界空间位置的版本（支持阴影）
Iris_Light Iris_GetMainLight(float3 positionWS)
{
    Iris_Light light;
    #if defined(_MAIN_LIGHT_SHADOWS) && !defined(_RECEIVE_SHADOWS_OFF)
    // 有阴影时，传递阴影坐标
    float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
    Light urpLight = GetMainLight(shadowCoord);
    #else
    // 无阴影时，直接调用
    Light urpLight = GetMainLight();
    #endif
    light.Direction = urpLight.direction;
    light.Color = urpLight.color;
    light.DistanceAttenuation = urpLight.distanceAttenuation;
    light.ShadowAttenuation = urpLight.shadowAttenuation;
    light.LayerMask = urpLight.layerMask;
    return light;
}

#elif defined (IrisShader_BRP)
//BRP获取主光源信息
Iris_Light Iris_GetMainLight()
{
    Iris_Light light;
    
    // BRP中 _WorldSpaceLightPos0.w = 0 表示方向光，w = 1 表示点光源
    float4 lightPos = Iris_WorldSpaceLightPos0;
    
    // 判断光源类型并计算方向
    if (lightPos.w == 0.0)
    {
        // 方向光：直接使用xyz作为方向向量
        light.Direction = lightPos.xyz;
        light.DistanceAttenuation = 1.0; // 方向光无距离衰减
    }
    else
    {
        // 点光源：需要世界空间位置来计算方向
        // 注意：点光源需要传入世界空间位置，这里提供一个默认实现
        // 实际使用时可能需要重载函数或传入位置参数
        light.Direction = lightPos.xyz;// half3(0, 1, 0); // 默认向上，实际应计算方向
        light.DistanceAttenuation = 1.0; // 需要根据距离计算
    }
    
    // BRP中 _LightColor0 的 RGB 是颜色，A 是强度
    //light.Color = Iris_LightColor0.rgb * Iris_LightColor0.a;
    light.Color = Iris_LightColor0;

    // BRP中阴影衰减需要采样阴影贴图，这里默认设为1.0
    // 如果需要阴影，需要额外实现阴影采样函数
    light.ShadowAttenuation = 1.0;
    
    // BRP中没有LayerMask概念，设为0
    light.LayerMask = 0;
    
    return light;
}

// BRP带参数的版本（为了接口统一，参数会被忽略）
Iris_Light Iris_GetMainLight(float3 positionWS)
{
    // BRP中暂时忽略位置参数，使用无参数版本
    return Iris_GetMainLight();
}



#endif

#endif





#endif


