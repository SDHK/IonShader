/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/16 11:19

* 描述： Unity引擎阴影投射方法实现集（BRP版本）
* 
*/


#ifndef Def_IrisShadowCaster
#define Def_IrisShadowCaster

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

