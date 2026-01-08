/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/16 11:19

* 描述： Unity引擎光照方法实现集（URP版本）
* 
*/
#if DefPart(IonLight, Bind)
#define Def_IonLight_Bind


//===[主光源获取]===

// 获取主光源信息（无阴影支持版本）
// 返回值：IonStruct_Light 结构体，包含光源方向、颜色、衰减等信息
IonStruct_Light IonLight_MainLight()
{
    IonStruct_Light light;
    Light urpLight = GetMainLight();
    light.Direction = urpLight.direction;
    light.Color = urpLight.color;
    light.DistanceAttenuation = urpLight.distanceAttenuation;
    light.ShadowAttenuation = urpLight.shadowAttenuation;
    light.LayerMask = urpLight.layerMask; 
    return light;
}


// 获取主光源信息（带阴影支持版本）
// 参数：shadowCoord - 阴影坐标，用于计算阴影衰减
// 返回值：IonStruct_Light 结构体，包含光源信息和阴影衰减
// 说明：优化版本，避免重复计算shadowCoord
IonStruct_Light IonLight_MainLight(float4 shadowCoord)
{
    return IonLight_MainLight();
}


//===[阴影接收相关方法] ===
// 这些方法用于在Forward Pass中接收阴影

// 计算并返回阴影坐标（在vertex shader中调用）
// 参数：positionOS - 物体空间位置（float4，URP中不使用但为接口统一保留）
// 参数：positionCS - 裁剪空间位置（float4，URP中不使用但为接口统一保留）
// 参数：positionWS - 世界空间位置（float3）
// 返回值：阴影坐标（float4）
// 使用方式：fragData.ShadowCoord = IonLight_ShadowCoord(vertData.PositionOS, fragData.pos, fragData.PositionWS)
float4 IonLight_ShadowCoord(float4 positionOS, float4 positionCS, float3 positionWS)
{
    return TransformWorldToShadowCoord(positionWS);
}




//===[阴影投射相关方法] ===
// 这些方法用于 ShadowCaster Pass 中投射阴影

// URP阴影投射
float4 IonShadowCaster_PositionCS(float4 positionOS, float3 normalOS)
{
    float3 positionWS = TransformObjectToWorld(positionOS.xyz);
    // URP自动处理阴影偏移，不需要手动调用UnityApplyLinearShadowBias
    return TransformWorldToHClip(positionWS);
}

// URP不需要vec字段，但为了接口统一可以设为0
float3 IonShadowCaster_Vector(float4 positionOS)
{
    return 0; // URP不需要
}

// URP fragment shader只需要返回0
half IonShadowCaster_Fragment(float3 vec)
{
    return 0; // 深度信息已经在PositionCS中
}

#endif

