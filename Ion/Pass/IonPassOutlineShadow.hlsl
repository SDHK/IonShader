/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/19 17:45
*
* 描述： Ion Outline 阴影投射 Pass
*
*/

#if Def(IonPassOutlineShadow)
#define Def_IonPassOutlineShadow

#pragma vertex vert
#pragma fragment frag

#define IonKey_ShadowCaster

#define Link_IonBase
#define Link_IonLight
#define Link_IonMatrix
#include "../Core/IonCore.hlsl"

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

float4 _Color;
float _Scale;

FragData vert(VertData vertData)
{
    FragData fragData;
    fragData.PositionCS = IonShadowCaster_PositionCS(vertData.PositionOS, vertData.Normal); 
    fragData.LightVector3 = IonShadowCaster_Vector(vertData.PositionOS);
    return fragData;
}


half4 frag(FragData fragData) : SV_Target
{
    return IonShadowCaster_Fragment(fragData.LightVector3);
}

#endif // Def(IonPassOutlineShadow)

