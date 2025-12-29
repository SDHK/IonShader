/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/16 11:19

* 描述： Unity引擎方法实现集
* 
*/


#ifndef Def_IrisMethod
#define Def_IrisMethod

//===[定义Unity的方法宏]===

// 纹理坐标缩放偏移 float2  2d纹理 => float2 :TRANSFORM_TEX(uv,tex)
#define Iris_Transform_TEX(uv,tex) TRANSFORM_TEX(uv,tex)

//光照相关方法
#ifdef Use_ShaderLighting

//URP获取主光源信息
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

// 带阴影坐标的版本（优化版本，避免重复计算shadowCoord）
Iris_Light Iris_GetMainLight(float4 shadowCoord)
{
    Iris_Light light;
    Light urpLight = GetMainLight(shadowCoord);

    //#if defined(_MAIN_LIGHT_SHADOWS) && !defined(_RECEIVE_SHADOWS_OFF)
    //// 有阴影时，直接使用传入的阴影坐标
    //Light urpLight = GetMainLight(shadowCoord);
    //#else
    //// 无阴影时，直接调用
    //Light urpLight = GetMainLight();
    //#endif
    light.Direction = urpLight.direction;
    light.Color = urpLight.color;
    light.DistanceAttenuation = urpLight.distanceAttenuation;
    light.ShadowAttenuation = urpLight.shadowAttenuation;
    light.LayerMask = urpLight.layerMask;
    return light;
}

// 提供单独的世界空间位置到阴影坐标转换方法
float4 Iris_TransfromWorldToShadowCoord(float3 positionWS,float4 shadowCoord)
{
    return TransformWorldToShadowCoord(positionWS);
}


//=== [阴影接收相关方法] ===
// 这些方法用于在Forward Pass中接收阴影
// 注意：阴影接收需要光照支持，所以放在Use_ShaderLighting块内


// URP阴影坐标字段定义（在结构体中声明）
// 使用方式：在FragData结构体中添加 Iris_ShadowCoords(texcoordIndex)
#define Iris_ShadowCoords(index) float4 _ShadowCoord : TEXCOORD##index;

// URP传递阴影坐标（在vertex shader中调用）
// 使用方式：Iris_TransferShadow(fragData, positionWS)
// 注意：positionWS必须是世界空间坐标（float3）
#define Iris_TransferShadow(fragData, positionWS) \
    fragData._ShadowCoord = TransformWorldToShadowCoord(positionWS);



#endif  // Use_ShaderLighting


//=== [阴影投射相关方法] ===

// URP阴影投射：非常简单！
float4 Iris_ShadowCasterPositionCS(float4 positionOS, float3 normalOS)
{
    float3 positionWS = TransformObjectToWorld(positionOS.xyz);
    // URP自动处理阴影偏移，不需要手动调用UnityApplyLinearShadowBias
    return TransformWorldToHClip(positionWS);
}

// URP不需要vec字段，但为了接口统一可以设为0
float3 Iris_ShadowCasterVector(float4 positionOS)
{
    return 0; // URP不需要
}

// URP fragment shader只需要返回0
half Iris_ShadowCasterFragment(float3 vec)
{
    return 0; // 深度信息已经在PositionCS中
}


#endif


