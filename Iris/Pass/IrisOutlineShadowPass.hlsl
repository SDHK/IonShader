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
#define Use_IrisMath
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
    Var_T0(float3,vec)

};

float4 _Color;
float _Scale;

ShadowFragData vert(ShadowVertData vertData)
{
    ShadowFragData fragData;
    
    // 注意：阴影 Pass 通常使用原始顶点位置，不使用描边扩展
    // 如果需要描边也投射阴影，可以取消下面的注释
    // float3 position3 = vertData.PositionOS.xyz + vertData.Normal * _Scale;
    // fragData.PositionCS = Iris_ObjectToClip(float4(position3, 1.0));
    
    // 使用原始顶点位置（推荐）
    //fragData.PositionCS = Iris_ObjectToClip(vertData.PositionOS);

    fragData.PositionCS = UnityClipSpaceShadowCasterPos(vertData.PositionOS, vertData.Normal); 
    fragData.PositionCS = UnityApplyLinearShadowBias(fragData.PositionCS);
    return fragData;
}


half4 frag(ShadowFragData fragData) : SV_Target
{
    // 阴影 Pass 只需要输出深度，颜色值不影响阴影
    // 返回 0 即可，深度信息已经在 PositionCS 中
    //return 0;

    //SHADOW_CASTER_FRAGMENT(fragData)
  return (Iris_Length(fragData.vec) + unity_LightShadowBias.x) * _LightPositionRange.w;

}
