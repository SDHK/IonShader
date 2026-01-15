/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/16 11:19

* 描述： Unity引擎光照方法实现集（URP版本）
* 
*/
#if DefPart(IonLight, Bind)
#define Def_IonLight_Bind


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


#endif

