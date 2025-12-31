#ifdef Use_IrisOutlineForwardPass

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
#define Use_IrisCore
#define Use_IrisLight
#define Use_IrisMatrix
#define Use_IrisMath
#define Use_IrisVertex

#include "../IrisEntry.hlsl"

struct VertData
{
    IrisVar_PositionOS
    IrisVar_Normal
    IrisVar_T0(float2, UV)
};

struct FragData
{

    IrisVar_PositionCS
    IrisVar_T0(float2, UV)
    IrisVar_T1(float3, NormalWS)
    IrisVar_T2(float3, PositionWS)
    //阴影坐标字段
    IrisVar_T3(float4, ShadowCoord)
};


FragData vert(VertData vertData)
{
    FragData fragData;
    
    // 计算世界空间位置
    fragData.PositionCS = IrisMatrix_ObjectToClip(vertData.PositionOS);
    fragData.UV = Iris_Transform_TEX(vertData.UV, _MainTex);

    // 将法线转换到世界空间（使用法线专用函数）
    fragData.NormalWS = IrisMatrix_ObjectToWorldNormal(vertData.Normal);
    // 计算世界空间位置
    fragData.PositionWS = IrisMatrix_ObjectToWorld(vertData.PositionOS);

    // 统一的阴影坐标传递（兼容URP和BRP）
    fragData.ShadowCoord = IrisLight_ShadowCoord(vertData.PositionOS, fragData.PositionCS, fragData.PositionWS);
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    // 采样主贴图颜色
    half4 mainTex = tex2D(_MainTex, fragData.UV);

    // 获取主光源信息并计算阴影（统一接口，自动适配URP/BRP）
    float4 shadowCoord = IrisLight_WorldToShadow(fragData.PositionWS, fragData.ShadowCoord);
    IrisStruct_Light mainLight = IrisLight_MainLight(shadowCoord);

    // 计算简单的 Lambert 光照
    float NdotL = saturate(dot(normalize(fragData.NormalWS), mainLight.Direction));

    // 应用阴影衰减到光照
    half3 directLighting = mainLight.Color.rgb * NdotL * mainLight.ShadowAttenuation;
    float3 lighting = directLighting + IrisParam_AmbientSky.rgb;

    // 应用光照
    mainTex.rgb *= lighting;

    return mainTex;
}

#endif // Use_IrisOutlineForwardPass
