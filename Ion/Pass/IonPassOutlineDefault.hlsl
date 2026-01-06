/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/10 20:38
*
* 描述： Ion Outline 默认 Pass
*
*/

#if Def(IonPassOutlineDefault)
#define Def_IonPassOutlineDefault

#pragma vertex vert
#pragma fragment frag

#define Link_IonBase
#define Link_IonMatrix
#define Link_IonMath
#define Link_IonVertex
#include "../Core/IonCore.hlsl"

struct VertData
{
    IonVar_PositionOS
    IonVar_Normal
};

struct FragData
{
    IonVar_PositionCS
};
            
float4 _Color;
float _Scale;


FragData vert(VertData vertData)
{
    FragData fragData;

    float3 position3 = vertData.PositionOS.xyz + vertData.Normal * _Scale;
    fragData.PositionCS = mul(IonParam_Matrix_MVP,float4( position3,1));
    return fragData;
}
            
half4 frag(FragData fragData) : SV_Target
{
    return _Color;
}

#endif // Def(IonPassOutlineDefault)

