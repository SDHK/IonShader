#pragma vertex vert
#pragma fragment frag

// 阴影编译指令（根据URP/BRP自动选择，需要在include之前定义IrisShader_URP或IrisShader_BRP）
#ifdef IrisShader_URP
#pragma multi_compile_fog
#pragma multi_compile_instancing
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
#pragma multi_compile _ _SHADOWS_SOFT
#elif defined(IrisShader_BRP)
#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
#endif

#define SHADOWS_SCREEN
#define Use_IrisMatrix
#define Use_IrisMath
#define Use_IrisVertex
#define Use_ShaderLighting
#define Use_ShaderAutoLight
#include "../IrisEntry.hlsl"

struct VertData
{
    Var_PositionOS
    Var_Normal
    Var_T0(float2, UV)
};

struct FragData
{
    float4 pos : SV_POSITION;
    Var_T0(float2, UV)
    Var_T1(float3, NormalWS)
    Var_T2(float3, PositionWS)
    Iris_ShadowCoords(3)
};


FragData vert(VertData vertData)
{
    FragData fragData;
    
    // 计算世界空间位置
    fragData.pos = Iris_ObjectToClip(vertData.PositionOS);
    fragData.UV = Iris_Transform_TEX(vertData.UV, _MainTex);

    // 将法线转换到世界空间（使用法线专用函数）
    float3 normalWS = Iris_ObjectToWorldNormal(vertData.Normal);
    fragData.NormalWS = normalWS;
    // 计算世界空间位置
    fragData.PositionWS = Iris_ObjectToWorld(vertData.PositionOS);

    // 统一的阴影坐标传递（兼容URP和BRP）
    Iris_TransferShadow(fragData, fragData.PositionWS);
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    // 采样主贴图颜色
    half4 mainTex = tex2D(_MainTex, fragData.UV);

    // 获取主光源信息并计算阴影（统一接口，自动适配URP/BRP）
    float4 shadowCoord = Iris_TransfromWorldToShadowCoord(fragData.PositionWS,fragData._ShadowCoord);
    Iris_Light mainLight = Iris_GetMainLight(shadowCoord);

    // 计算简单的 Lambert 光照
    float NdotL = saturate(dot(normalize(fragData.NormalWS), mainLight.Direction));

    // 应用阴影衰减到光照
    half3 directLighting = mainLight.Color.rgb * NdotL * mainLight.ShadowAttenuation;
    float3 lighting = directLighting + Iris_AmbientSky.rgb;

    // 应用光照
    mainTex.rgb *= lighting;

    return mainTex;
}
