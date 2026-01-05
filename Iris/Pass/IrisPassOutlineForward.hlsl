#if Def(IrisPassOutlineForward)
#define Def_IrisPassOutlineForward

#pragma vertex vert
#pragma fragment frag

// 变体关键字声明（通过 IrisKey 系统自动生成对应的 #pragma multi_compile）
// IrisKey 系统会根据 URP/BRP 自动生成对应的变体指令
#define IrisKey_Fog
#define IrisKey_Instancing
#define IrisKey_MainLightShadows
#define IrisKey_MainLightShadowsCascade
#define IrisKey_ShadowsSoft
#define IrisKey_ForwardBase

// 阴影设置
#define IrisSet_ShadowScreen

#define Link_IrisBase
#define Link_IrisLight
#define Link_IrisMatrix
#define Link_IrisMath
#define Link_IrisVertex

#include "../Core/IrisCore.hlsl"

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

#endif // Def(IrisPassOutlineForward)

