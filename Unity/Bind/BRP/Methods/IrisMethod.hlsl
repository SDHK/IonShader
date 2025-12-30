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

//BRP获取主光源信息
IrisStruct_Light Iris_GetMainLight()
{
    IrisStruct_Light light;
    
    // BRP中 _WorldSpaceLightPos0.w = 0 表示方向光，w = 1 表示点光源
    float4 lightPos = IrisParam_WorldSpaceLightPos0;
    
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
    //light.Color = IrisParam_LightColor0.rgb * IrisParam_LightColor0.a;
    light.Color = IrisParam_LightColor0;

    // BRP中阴影衰减需要采样阴影贴图，这里默认设为1.0
    // 如果需要阴影，需要额外实现阴影采样函数
    light.ShadowAttenuation = 1.0;
    
    // BRP中没有LayerMask概念，设为0
    light.LayerMask = 0;
    
    return light;
}



// BRP带参数的版本（支持阴影）
IrisStruct_Light Iris_GetMainLight(float4 shadowCoord)
{
    IrisStruct_Light light = Iris_GetMainLight();
    light.ShadowAttenuation =unitySampleShadow(shadowCoord);
    return light;
}

float4 Iris_TransfromWorldToShadowCoord(float3 positionWS,float4 shadowCoord)
{
    //return UnityWorldToShadowCoord(positionWS);
    return shadowCoord;
}


//=== [阴影接收相关方法] ===
// 这些方法用于在Forward Pass中接收阴影
// 注意：阴影接收需要光照支持，所以放在Use_ShaderLighting块内

// BRP阴影坐标字段定义（使用AutoLight.cginc的宏）
// 使用方式：在FragData结构体中添加 Iris_ShadowCoords(texcoordIndex)
#define Iris_ShadowCoords(index) SHADOW_COORDS(index)

// BRP传递阴影坐标（在vertex shader中调用）
// 使用方式：Iris_TransferShadow(fragData, positionWS)
// 注意：BRP的TRANSFER_SHADOW不需要positionWS参数，但为了接口统一保留
// positionWS必须是世界空间坐标（float3）
#define Iris_TransferShadow(fragData, positionWS) TRANSFER_SHADOW(fragData)

#endif  // Use_ShaderLighting

#endif


