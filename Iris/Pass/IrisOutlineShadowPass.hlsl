/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/19 17:45
*
* 描述： Iris Outline 阴影投射 Pass
*
*/

#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_shadowcaster

#define Use_IrisMatrix
#include "../IrisEntry.hlsl"
//#include "Lighting.cginc"
//#include "AutoLight.cginc"

struct VertData
{
    Var_PositionOS
    Var_Normal
};

struct FragData
{
    Var_PositionCS
    Var_T0(float3,LightVector3)

};

float4 _Color;
float _Scale;

FragData vert(VertData vertData)
{
    FragData fragData;
    fragData.PositionCS = Iris_ShadowCasterPositionCS(vertData.PositionOS, vertData.Normal); 
    fragData.LightVector3 = Iris_ShadowCasterVector(vertData.PositionOS);
    return fragData;
}


half4 frag(FragData fragData) : SV_Target
{
    return Iris_ShadowCasterFragment(fragData.LightVector3);
}
