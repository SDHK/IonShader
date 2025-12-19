#pragma vertex vert
#pragma fragment frag
// 启用阴影相关的 multi_compile
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
#pragma multi_compile _ _SHADOWS_SOFT

#define Use_IrisMatrix
#define Use_IrisMath
#define Use_IrisVertex
#define Use_ShaderLighting
#include "../IrisEntry.hlsl"

struct VertData
{
    Var_PositionOS
    Var_Normal
    Var_T0(float2, UV)
};

struct FragData
{
    Var_PositionCS
    Var_T0(float2, UV)
    Var_T1(float3, NormalWS)
    Var_T2(float3, PositionWS)  // 世界空间位置（用于阴影和光照计算）
};


FragData vert(VertData vertData)
{
    FragData fragData;
    
    // 计算世界空间位置
    float4 positionWS = Iris_ObjectToWorld(vertData.PositionOS);
    fragData.PositionWS = positionWS.xyz;
    
    fragData.PositionCS = Iris_ObjectToClip(vertData.PositionOS);
    fragData.UV = Iris_Transform_TEX(vertData.UV, _MainTex);

    // 将法线转换到世界空间（使用法线专用函数）
    float3 normalWS = Iris_ObjectToWorldNormal(vertData.Normal);
    fragData.NormalWS = normalWS;
    
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    // 采样主贴图颜色
    half4 albedo = tex2D(_MainTex, fragData.UV);
    
    // 获取主光源信息（传递世界空间位置以支持阴影）
    Iris_Light mainLight = Iris_GetMainLight(fragData.PositionWS);
    
    // 计算简单的 Lambert 光照
    half NdotL = saturate(dot(normalize(fragData.NormalWS), mainLight.Direction));
    
    // 应用阴影衰减到光照
    half shadowAttenuation = mainLight.ShadowAttenuation;
    half3 directLighting = mainLight.Color * NdotL * shadowAttenuation;
    half3 ambientLighting = Iris_AmbientSky.rgb;
    
    half3 lighting = directLighting + ambientLighting;

    // 应用光照
    half4 finalColor = albedo;
    finalColor.rgb *= lighting;

    return finalColor;
}
