/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/19 17:45
*
* 描述： Ion Outline 阴影投射 Pass
*
*/

#if Def(IonPassShadowCaster)
#define Def_IonPassShadowCaster

// 默认参数定义
#if PassVar(Scale)
#warning "IonPassShadowCaster没有定义 PassVar_Scale"
#endif
float PassVar_Scale;

#pragma vertex vert
#pragma fragment frag

#define IonKey_ShadowCaster

#define Link_IonBase
#define Link_IonLight
#define Link_IonMatrix
#include "../../Core/IonCore.hlsl"

struct VertData
{
    IonVar_PositionOS
    IonVar_Normal
};

struct FragData
{
    IonVar_PositionCS
    IonVar_T0(float3,LightVector3)
};

FragData vert(VertData vertData)
{
    FragData fragData;
    
    float3 position3 = vertData.PositionOS.xyz + vertData.Normal * PassVar_Scale;
    float4 positionOS = float4(position3, vertData.PositionOS.w);
    fragData.PositionCS = IonShadowCaster_PositionCS(positionOS, vertData.Normal); 
    fragData.LightVector3 = IonShadowCaster_Vector(positionOS);
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    return IonShadowCaster_Fragment(fragData.LightVector3);
}

#endif // Def(IonPassShadowCaster)

