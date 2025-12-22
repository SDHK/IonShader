#pragma vertex vert
#pragma fragment frag
// 启用阴影相关的 multi_compile
//#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
//#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
//#pragma multi_compile _ _SHADOWS_SOFT
#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

#define Use_IrisMatrix
#define Use_IrisMath
#define Use_IrisVertex
#define Use_ShaderLighting
#define Use_ShaderAutoLight
#include "../IrisEntry.hlsl"
#include "Lighting.cginc"
#include "AutoLight.cginc"
struct VertData
{
    Var_PositionOS
    Var_Normal
    Var_T0(float2, UV)
};

struct FragData
{
    float4 pos : SV_POSITION;
    //Var_PositionCS
    Var_T0(float2, UV)
    Var_T1(float3, NormalWS)
    Var_T2(float3, PositionWS)  // 世界空间位置（用于阴影和光照计算）
    SHADOW_COORDS(3)

};


FragData vert(VertData vertData)
{
    FragData fragData;
    
    // 计算世界空间位置
    fragData.pos = Iris_ObjectToClip(vertData.PositionOS);
    fragData.UV = Iris_Transform_TEX(vertData.UV, _MainTex);

    float4 positionWS = Iris_ObjectToWorld(vertData.PositionOS);
    fragData.PositionWS = positionWS.xyz;

    // 将法线转换到世界空间（使用法线专用函数）
    float3 normalWS = Iris_ObjectToWorldNormal(vertData.Normal);
    fragData.NormalWS = normalWS;
    TRANSFER_SHADOW(fragData);
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    // 采样主贴图颜色
    half4 mainTex = tex2D(_MainTex, fragData.UV);
    
    // 获取主光源信息（传递世界空间位置以支持阴影）
    Iris_Light mainLight = Iris_GetMainLight(fragData.PositionWS);
    
    // 计算简单的 Lambert 光照
    float NdotL = saturate(dot(normalize(fragData.NormalWS), mainLight.Direction));

    float shadow = SHADOW_ATTENUATION(fragData);
    //mainLight.ShadowAttenuation = shadow;

    // 应用阴影衰减到光照
    //float shadowAttenuation = mainLight.ShadowAttenuation;
    half3 directLighting = mainLight.Color.rgb * NdotL * shadow;
    float3 lighting = directLighting + Iris_AmbientSky.rgb;

    // 应用光照
    mainTex.rgb *= lighting;

    return mainTex;
}
