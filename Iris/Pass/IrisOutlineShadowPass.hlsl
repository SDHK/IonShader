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

struct ShadowVertData
{
    //Var_PositionOS
    //Var_Normal

    float4 vertex : POSITION;
    float3 normal : NORMAL;
};

struct ShadowFragData
{
    //Var_PositionCS
    V2F_SHADOW_CASTER;
};

float4 _Color;
float _Scale;

ShadowFragData vert(ShadowVertData v)
{
    ShadowFragData fragData;
    
    // 注意：阴影 Pass 通常使用原始顶点位置，不使用描边扩展
    // 如果需要描边也投射阴影，可以取消下面的注释
    // float3 position3 = vertData.PositionOS.xyz + vertData.Normal * _Scale;
    // fragData.PositionCS = Iris_ObjectToClip(float4(position3, 1.0));
    
    // 使用原始顶点位置（推荐）
    //fragData.PositionCS = Iris_ObjectToClip(vertData.PositionOS);
    TRANSFER_SHADOW_CASTER_NORMALOFFSET(fragData)

    return fragData;
}

half4 frag(ShadowFragData fragData) : SV_Target
{
    // 阴影 Pass 只需要输出深度，颜色值不影响阴影
    // 返回 0 即可，深度信息已经在 PositionCS 中
    //return 0;
    SHADOW_CASTER_FRAGMENT(fragData)

}
