/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/19 17:45
*
* 描述： Iris Outline 阴影投射 Pass
*
*/

#ifdef Use_IrisOutlineShadowPass

#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_shadowcaster

#define Use_IrisCore
#define Use_IrisLight
#define Use_IrisMatrix
#include "../IrisEntry.hlsl"

struct VertData
{
    IrisVar_PositionOS
    IrisVar_Normal
};

struct FragData
{
    IrisVar_PositionCS
    IrisVar_T0(float3,LightVector3)

};

float4 _Color;
float _Scale;

FragData vert(VertData vertData)
{
    FragData fragData;
    fragData.PositionCS = IrisShadowCaster_PositionCS(vertData.PositionOS, vertData.Normal); 
    fragData.LightVector3 = IrisShadowCaster_Vector(vertData.PositionOS);
    return fragData;
}


half4 frag(FragData fragData) : SV_Target
{
    return IrisShadowCaster_Fragment(fragData.LightVector3);
}

#endif // Use_IrisOutlineShadowPass
