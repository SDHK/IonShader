#if Def(IonPassOutlineForward)
#define Def_IonPassOutlineForward

#pragma vertex vert
#pragma fragment frag

// 变体关键字声明（通过 IonKey 系统自动生成对应的 #pragma multi_compile）
// IonKey 系统会根据 URP/BRP 自动生成对应的变体指令
#define IonKey_Fog
#define IonKey_Instancing
#define IonKey_MainLightShadows
#define IonKey_MainLightShadowsCascade
#define IonKey_ShadowsSoft
#define IonKey_ForwardBase

// 阴影设置
#define IonSet_ShadowScreen

#define Link_IonBase
#define Link_IonLight
#define Link_IonMatrix
#define Link_IonMath
#define Link_IonVertex

#include "../Core/IonCore.hlsl"

struct VertData
{
    IonVar_PositionOS
    IonVar_Normal
    IonVar_T0(float2, UV)
};

struct FragData
{

    IonVar_PositionCS
    IonVar_T0(float2, UV)
    IonVar_T1(float3, NormalWS)
    IonVar_T2(float3, PositionWS)
    //阴影坐标字段
    IonVar_T3(float4, ShadowCoord)
};


FragData vert(VertData vertData)
{
    FragData fragData;
    
    // 计算世界空间位置
    fragData.PositionCS = IonMatrix_ObjectToClip(vertData.PositionOS);
    fragData.UV = Ion_Transform_TEX(vertData.UV, _MainTex);

    // 将法线转换到世界空间（使用法线专用函数）
    fragData.NormalWS = IonMatrix_ObjectToWorldNormal(vertData.Normal);
    // 计算世界空间位置
    fragData.PositionWS = IonMatrix_ObjectToWorld(vertData.PositionOS);

    // 统一的阴影坐标传递（兼容URP和BRP）
    fragData.ShadowCoord = IonLight_ShadowCoord(vertData.PositionOS, fragData.PositionCS, fragData.PositionWS);
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    // 采样主贴图颜色
    half4 mainTex = tex2D(_MainTex, fragData.UV);

    // 获取主光源信息并计算阴影（统一接口，自动适配URP/BRP）
    float4 shadowCoord = IonLight_WorldToShadow(fragData.PositionWS, fragData.ShadowCoord);
    IonStruct_Light mainLight = IonLight_MainLight(shadowCoord);

    // 计算简单的 Lambert 光照
    float NdotL = saturate(dot(normalize(fragData.NormalWS), mainLight.Direction));

    // 应用阴影衰减到光照
    half3 directLighting = mainLight.Color.rgb * NdotL * mainLight.ShadowAttenuation;
    float3 lighting = directLighting + IonParam_AmbientSky.rgb;

    // 应用光照
    mainTex.rgb *= lighting;

    return mainTex;
}

#endif // Def(IonPassOutlineForward)

