/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/10 20:38

* 描述： 

*/


#pragma vertex vert
#pragma fragment frag

#define Use_IrisMatrix
#define Use_IrisMath
#define Use_IrisVertex
#include "../IrisEntry.hlsl"

struct VertData
{
    IrisVar_PositionOS
    IrisVar_Normal
};

struct FragData
{
    IrisVar_PositionCS
};
            
float4 _Color;
float _Scale;


FragData vert(VertData vertData)
{
    FragData fragData;

    float3 position3 = vertData.PositionOS.xyz + vertData.Normal * _Scale;
    fragData.PositionCS = mul(IrisParam_Matrix_MVP,float4( position3,1));
    return fragData;
}
            
half4 frag(FragData fragData) : SV_Target
{
    return _Color;
}
