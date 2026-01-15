


#if Def(IonPassMainSimple)
#define Def_IonPassMainSimple

#if PassVar(MainTex)
#error "IonPassMainSimple 缺少必要的参数定义：MainTex"
#endif

#if PassVar(MainTex_ST)
#error "IonPassMainSimple 缺少必要的参数定义：MainTex_ST"
#endif

sampler2D PassVar_MainTex;
float4 PassVar_MainTex_ST;

#define IonKey_Instancing

#define IonKey_Fog
#define IonKey_MainLightShadows
#define IonKey_MainLightShadowsCascade
#define IonKey_ShadowsSoft

// 阴影设置
#define IonSet_ShadowScreen

#define Link_IonBase
#define Link_IonLight
#define Link_IonMatrix
#define Link_IonMath
#define Link_IonVertex
#include "../../Core/IonCore.hlsl"


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

#pragma vertex vert
FragData vert(VertData vertData)
{
    FragData fragData;
    
    // 计算世界空间位置
    fragData.PositionCS = IonMatrix_ObjectToClip(vertData.PositionOS);
    fragData.UV = Ion_Transform_TEX(vertData.UV,PassVar_MainTex_ST);

    // 将法线转换到世界空间（使用法线专用函数）
    fragData.NormalWS = IonMatrix_ObjectToWorldNormal(vertData.Normal);
    // 计算世界空间位置
    fragData.PositionWS = IonMatrix_ObjectToWorld(vertData.PositionOS);

    // 统一的阴影坐标传递（兼容URP和BRP）
    fragData.ShadowCoord = IonLight_ShadowCoord(vertData.PositionOS, fragData.PositionCS, fragData.PositionWS);
    return fragData;
}

#pragma fragment frag
half4 frag(FragData fragData) : SV_Target
{
    // 采样主贴图颜色
    half4 mainTex = tex2D(_MainTex, fragData.UV);

    // 获取主光源信息并计算阴影（统一接口，自动适配URP/BRP）
    IonStruct_Light mainLight = IonLight_MainLight(fragData.ShadowCoord);

    // 计算 Lambert 光照（使用工具函数）
    float3 normalWS = normalize(fragData.NormalWS);
    half3 directLighting = IonLight_LambertSimple(normalWS, mainLight.Direction, mainLight.Color, mainLight.ShadowAttenuation);
    
    // 最终光照 = 直接光照 + 环境光
    float3 lighting = directLighting + IonParam_AmbientSky.rgb;

    // 应用光照
    mainTex.rgb *= lighting;

    return mainTex;
}

#endif // Def(IonPassMainSimple)

