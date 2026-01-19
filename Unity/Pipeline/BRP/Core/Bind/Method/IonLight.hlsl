/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/16 11:19

* 描述： Unity引擎光照方法实现集（BRP版本）
* 
*/

#if DefPart(IonLight, Bind)
#define Def_IonLight_Bind


//===[光源获取]===

// 获取光源方向（统一接口，用于 ForwardBase 和 ForwardAdd）
// 参数：positionWS - 世界空间位置（float3）
// 返回值：归一化的光源方向（float3）
// 说明：BRP中 _WorldSpaceLightPos0.w = 0 表示平行光，w = 1 表示点光源/聚光灯
//       平行光：直接使用 _WorldSpaceLightPos0.xyz
//       点光源/聚光灯：从光源位置到顶点位置的方向
float3 IonLight_Direction(float3 positionWS)
{
    float4 lightPos = IonParam_WorldSpaceLightPos;
    
    // w = 0：平行光，直接返回方向
    // w = 1：点光源/聚光灯，计算从顶点指向光源的方向
    float3 lightDir = lightPos.xyz - positionWS * lightPos.w;
    return normalize(lightDir);
}

// 获取主光源信息（无阴影支持版本）
// 返回值：IonStruct_Light 结构体，包含光源方向、颜色、衰减等信息
// 说明：BRP中 _WorldSpaceLightPos0.w = 0 表示方向光，w = 1 表示点光源
IonStruct_Light IonLight_MainLight()
{
    IonStruct_Light light;
    
    float4 lightPos = IonParam_WorldSpaceLightPos;
    
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
    light.Color = IonParam_LightColor;

    // BRP中阴影衰减需要采样阴影贴图，这里默认设为1.0
    // 如果需要阴影，需要使用带参数的版本
    light.ShadowAttenuation = 1.0;
    
    // BRP中没有LayerMask概念，设为0
    light.LayerMask = 0;
    
    return light;
}

// 获取主光源信息（带阴影支持版本）
// 参数：shadowCoord - 阴影坐标，用于采样阴影贴图
// 返回值：IonStruct_Light 结构体，包含光源信息和阴影衰减
IonStruct_Light IonLight_MainLight(float4 shadowCoord)
{
    IonStruct_Light light = IonLight_MainLight();
#ifdef SHADOWS_SCREEN
    light.ShadowAttenuation = unitySampleShadow(shadowCoord);
#endif
    return light;
}

// 计算光照衰减（ForwardAdd Pass 专用，在 fragment shader 中调用）
// 参数：lightCoord - 光照坐标（float3），由 IonLight_LightCoord 计算
// 参数：shadowCoord - 阴影坐标（float4），由 IonLight_ShadowCoord 计算
// 返回值：衰减值（float），包含距离衰减和阴影衰减的组合
// 说明：此函数用于 ForwardAdd Pass，计算点光源和聚光灯的衰减
//       包含距离衰减、Cookie、阴影衰减等所有因素
float IonLight_Attenuation(float3 lightCoord, float4 shadowCoord)
{
    // 计算阴影衰减
    float shadowAttenuation = 1.0;
    #if defined(SHADOWS_DEPTH) || defined(SHADOWS_SCREEN) || defined(SHADOWS_CUBE)
        #if defined(SHADOWS_SCREEN)
            shadowAttenuation = unitySampleShadow(shadowCoord);
        #elif defined(SHADOWS_DEPTH) && defined(SPOT)
            shadowAttenuation = unitySampleShadow(shadowCoord);
        #elif defined(SHADOWS_CUBE)
            shadowAttenuation = UnitySampleShadowmap(shadowCoord.xyz);
        #endif
    #endif
    
    // 计算距离衰减
    float distanceAttenuation = 1.0;
    #if defined(POINT)
        // 点光源：使用光照纹理采样距离衰减
        distanceAttenuation = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).r;
    #elif defined(SPOT)
        // 聚光灯：计算距离衰减、Cookie 和聚光锥衰减
        float4 lightCoord4 = float4(lightCoord, 1.0);
        distanceAttenuation = (lightCoord4.z > 0.0) * UnitySpotCookie(lightCoord4) * UnitySpotAttenuate(lightCoord4.xyz);
    #endif
    
    // 返回组合衰减：距离衰减 * 阴影衰减
    return distanceAttenuation * shadowAttenuation;
}


//===[光照坐标计算] ===
// ForwardAdd Pass 需要计算光照坐标（用于距离衰减）

// 计算光照坐标（在 vertex shader 中调用）
// 参数：positionWS - 世界空间位置（float3）
// 返回值：光照坐标（float3），用于后续计算距离衰减
// 说明：点光源和聚光灯需要光照坐标来计算距离衰减
//       平行光不需要（ForwardBase），返回 (0,0,0) 即可
float3 IonLight_LightCoord(float3 positionWS)
{
    #if defined(POINT) || defined(SPOT)
        // 点光源和聚光灯：返回世界空间到光源的向量
        return mul(unity_WorldToLight, float4(positionWS, 1.0)).xyz;
    #else
        // 平行光或无光源：不需要光照坐标
        return float3(0, 0, 0);
    #endif
}

//===[阴影接收相关方法] ===
// 这些方法用于在Forward Pass中接收阴影

// 计算并返回阴影坐标（在vertex shader中调用）
// 参数：positionOS - 物体空间位置（float4，从vertex shader输入获取，如 vertData.PositionOS）
// 参数：positionCS - 裁剪空间位置（float4，fragData.pos）
// 参数：positionWS - 世界空间位置（float3，BRP中不使用但为接口统一保留）
// 返回值：阴影坐标（float4，对于SHADOWS_CUBE类型，只使用xyz部分）
// 使用方式：fragData.ShadowCoord = IonLight_ShadowCoord(vertData.PositionOS, fragData.pos, fragData.PositionWS)
// 说明：根据不同的阴影类型自动选择正确的计算方式
//       字段类型根据阴影类型而定：
//       - SHADOWS_SCREEN: float4 ShadowCoord : TEXCOORDx;
//       - SHADOWS_DEPTH (SPOT): float4 ShadowCoord : TEXCOORDx;
//       - SHADOWS_CUBE (POINT): float3 ShadowCoord : TEXCOORDx; (使用返回值的xyz)
float4 IonLight_ShadowCoord(float4 positionOS, float4 positionCS, float3 positionWS)
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

// 计算阴影投射顶点位置（在vertex shader中调用）
float4 IonShadowCaster_PositionCS(float4 positionOS, float3 normalOS)
{
    // 将为点光源生成立方体阴影贴图的情况单独处理
    #if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
        return UnityObjectToClipPos(positionOS);
    #else  // 生成定向或点光源阴影
        float4 positionCS = UnityClipSpaceShadowCasterPos(positionOS, normalOS);
        return UnityApplyLinearShadowBias(positionCS);
    #endif
}

// 计算光源到顶点的向量（在vertex shader中调用）
float3 IonShadowCaster_Vector(float4 positionOS)
{
    // 点光源阴影
    #if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
        return mul(unity_ObjectToWorld, positionOS).xyz - _LightPositionRange.xyz;
    #else // 定向光/聚光灯阴影不需要vec，返回0就行
        return float3(0, 0, 0);
    #endif
}

// 计算阴影投射顶点的颜色（在fragment shader中调用）
half IonShadowCaster_Fragment(float3 vec)
{
    // 点光源立方体阴影
    #if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
    return UnityEncodeCubeShadowDepth((length(vec) + unity_LightShadowBias.x) * _LightPositionRange.w);
    #else // 定向光/聚光灯阴影不需要距离衰减，返回0
    return 0;
    #endif
}

#endif