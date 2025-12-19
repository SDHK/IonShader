#pragma vertex vert
#pragma fragment frag
// #pragma multi_compile __ _MAIN_LIGHT_SHADOWS
// #pragma multi_compile __ _MAIN_LIGHT_SHADOWS_CASCADE
// #pragma multi_compile __ _SHADOWS_SOFT

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
};


FragData vert(VertData vertData)
{
    FragData fragData;
    fragData.PositionCS = mul(Iris_Matrix_MVP, vertData.PositionOS);
    fragData.UV = Iris_Transform_TEX(vertData.UV,_MainTex);

    // 将法线转换到世界空间
    float3 normalWS = Iris_ObjectToWorld(vertData.Normal);
    fragData.NormalWS = normalWS;
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
     // 采样主贴图颜色
    half4 albedo = tex2D(_MainTex, fragData.UV);
    // 获取主光源信息

    Iris_Light mainLight = Iris_GetMainLight();

    // 计算简单的 Lambert 光照
    half NdotL = saturate(dot(normalize(fragData.NormalWS), mainLight.Direction));
    half3 lighting = mainLight.Color * NdotL + Iris_AmbientSky.rgb;

    // 应用光照
    half4 finalColor = albedo;
    finalColor.rgb *= lighting;

    return finalColor;
}