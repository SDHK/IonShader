/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/16 11:19

* 描述： Unity引擎阴影投射方法实现集（URP版本）
* 
*/


#ifndef Def_IrisShadowCaster
#define Def_IrisShadowCaster

// URP阴影投射
float4 IrisShadowCaster_PositionCS(float4 positionOS, float3 normalOS)
{
    float3 positionWS = TransformObjectToWorld(positionOS.xyz);
    // URP自动处理阴影偏移，不需要手动调用UnityApplyLinearShadowBias
    return TransformWorldToHClip(positionWS);
}

// URP不需要vec字段，但为了接口统一可以设为0
float3 IrisShadowCaster_Vector(float4 positionOS)
{
    return 0; // URP不需要
}

// URP fragment shader只需要返回0
half IrisShadowCaster_Fragment(float3 vec)
{
    return 0; // 深度信息已经在PositionCS中
}

#endif

