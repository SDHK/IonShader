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

struct ShadowVertData
{
    Var_PositionOS
    Var_Normal
};

struct ShadowFragData
{
    Var_PositionCS
    Var_T0(float3,LightVector3)

};

float4 _Color;
float _Scale;

ShadowFragData vert(ShadowVertData vertData)
{
    ShadowFragData fragData;

    fragData.PositionCS = Iris_ShadowCasterPositionCS(vertData.PositionOS, vertData.Normal); 
    fragData.LightVector3 = Iris_ShadowCasterVector(vertData.PositionOS);
    return fragData;
}


half4 frag(ShadowFragData fragData) : SV_Target
{
    //SHADOW_CASTER_FRAGMENT(fragData)
  return (length(fragData.LightVector3) + unity_LightShadowBias.x) * _LightPositionRange.w;

}
