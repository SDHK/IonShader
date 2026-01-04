/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/16 11:19

* 描述： Unity引擎光照方法实现集（BRP版本）
* 
*/

#ifdef Use_IrisLight


#ifndef Def_IrisLight
#define Def_IrisLight


//===[主光源获取]===

// 获取主光源信息（无阴影支持版本）
// 返回值：IrisStruct_Light 结构体，包含光源方向、颜色、衰减等信息
// 说明：BRP中 _WorldSpaceLightPos0.w = 0 表示方向光，w = 1 表示点光源
IrisStruct_Light IrisLight_MainLight()
{
    IrisStruct_Light light;
    
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
        light.Direction = lightPos.xyz;
        light.DistanceAttenuation = 1.0; // 需要根据距离计算
    }
    
    // BRP中 _LightColor0 的 RGB 是颜色，A 是强度
    light.Color = IrisParam_LightColor0;

    // BRP中阴影衰减需要采样阴影贴图，这里默认设为1.0
    // 如果需要阴影，需要使用带参数的版本
    light.ShadowAttenuation = 1.0;
    
    // BRP中没有LayerMask概念，设为0
    light.LayerMask = 0;
    
    return light;
}

// 获取主光源信息（带阴影支持版本）
// 参数：shadowCoord - 阴影坐标，用于采样阴影贴图
// 返回值：IrisStruct_Light 结构体，包含光源信息和阴影衰减
IrisStruct_Light IrisLight_MainLight(float4 shadowCoord)
{
    IrisStruct_Light light = IrisLight_MainLight();
#ifdef SHADOWS_SCREEN
    light.ShadowAttenuation = unitySampleShadow(shadowCoord);
#endif
    return light;
}

//===[阴影坐标转换]===

// 将世界空间位置转换为阴影坐标
// 参数：positionWS - 世界空间位置（float3）
// 参数：shadowCoord - 阴影坐标（BRP中直接返回传入的shadowCoord）
// 返回值：阴影坐标（float4）
// 说明：BRP中阴影坐标已经在vertex shader中计算好，直接返回即可
float4 IrisLight_WorldToShadow(float3 positionWS, float4 shadowCoord)
{
    return shadowCoord;
}

//===[阴影接收相关方法] ===
// 这些方法用于在Forward Pass中接收阴影

// 计算并返回阴影坐标（在vertex shader中调用）
// 参数：positionOS - 物体空间位置（float4，从vertex shader输入获取，如 vertData.PositionOS）
// 参数：positionCS - 裁剪空间位置（float4，fragData.pos）
// 参数：positionWS - 世界空间位置（float3，BRP中不使用但为接口统一保留）
// 返回值：阴影坐标（float4，对于SHADOWS_CUBE类型，只使用xyz部分）
// 使用方式：fragData.ShadowCoord = IrisLight_ShadowCoord(vertData.PositionOS, fragData.pos, fragData.PositionWS)
// 说明：根据不同的阴影类型自动选择正确的计算方式
//       字段类型根据阴影类型而定：
//       - SHADOWS_SCREEN: float4 ShadowCoord : TEXCOORDx;
//       - SHADOWS_DEPTH (SPOT): float4 ShadowCoord : TEXCOORDx;
//       - SHADOWS_CUBE (POINT): float3 ShadowCoord : TEXCOORDx; (使用返回值的xyz)
float4 IrisLight_ShadowCoord(float4 positionOS, float4 positionCS, float3 positionWS)
{
    #if defined(SHADOWS_SCREEN)
        #if defined(UNITY_NO_SCREENSPACE_SHADOWS)
            return mul(unity_WorldToShadow[0], mul(unity_ObjectToWorld, positionOS));
        #else
            return ComputeScreenPos(positionCS);
        #endif
    #elif defined(SHADOWS_DEPTH) && defined(SPOT)
        return mul(unity_WorldToShadow[0], mul(unity_ObjectToWorld, positionOS));
    #elif defined(SHADOWS_CUBE)
        float3 shadowCoord3 = mul(unity_ObjectToWorld, positionOS).xyz - _LightPositionRange.xyz;
        return float4(shadowCoord3, 0.0); // 返回float4，但只使用xyz部分
    #else
        return float4(0, 0, 0, 0); // 无阴影情况
    #endif
}


//===[阴影投射相关方法] ===
// 这些方法用于 ShadowCaster Pass 中投射阴影

// BRP阴影投射
float4 IrisShadowCaster_PositionCS(float4 positionOS, float3 normalOS)
{
    float4 positionCS = UnityClipSpaceShadowCasterPos(positionOS, normalOS);
    return UnityApplyLinearShadowBias(positionCS);
}

// 计算从光源位置到顶点的向量（用于距离衰减）
float3 IrisShadowCaster_Vector(float4 positionOS)
{
    float3 worldPos = mul(unity_ObjectToWorld, positionOS).xyz;
    return worldPos - _LightPositionRange.xyz;
}

// 计算阴影衰减（基于距离）
half IrisShadowCaster_Fragment(float3 vec)
{
    return (length(vec) + unity_LightShadowBias.x) * _LightPositionRange.w;
}



#endif


#endif // Use_IrisLight

