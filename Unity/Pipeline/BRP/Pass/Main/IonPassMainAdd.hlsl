/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/1/19
*
* 描述： IonPassMainAdd - BRP 附加光源 Pass
*        用于 ForwardAdd，处理点光源和聚光灯
*        每个附加光源执行一次此 Pass
*
* 使用说明：
* - 必须配合 IonPassMainSimple（ForwardBase）使用
* - Pass 设置：Blend One One, ZWrite Off
* - 不包含环境光，只有直接光照
*
****************************************/

#if Def(IonPassMainAdd)
#define Def_IonPassMainAdd

#if PassVar(MainTex)
#error "IonPassMainAdd 缺少必要的参数定义：MainTex"
#endif

#if PassVar(MainTex_ST)
#error "IonPassMainAdd 缺少必要的参数定义：MainTex_ST"
#endif

sampler2D PassVar_MainTex;
float4 PassVar_MainTex_ST;

// ForwardAdd 关键字（生成 multi_compile_fwdadd_fullshadows）
#define IonKey_ForwardAdd

// 实例化支持
#define IonKey_Instancing

// 雾效支持
#define IonKey_Fog

#define Link_IonBase
#define Link_IonLight
#define Link_IonMatrix
#define Link_IonMath
#define Link_IonVertex
#include "../../Core/IonCore.hlsl"


#pragma vertex vert
#pragma fragment frag

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
    // 光照坐标（用于距离衰减计算）
    // 点光源和聚光灯需要此坐标来计算距离衰减
    // 根据光源类型可能是 float3 或 float4，这里统一声明 float4
    IonVar_T3(float4, LightCoord)
    // 阴影坐标（用于阴影采样）
    // 根据阴影类型可能使用 float3 或 float4，这里统一声明 float4
    IonVar_T4(float4, ShadowCoord)
};

FragData vert(VertData vertData)
{
    FragData fragData;
    
    // 计算 UV 坐标
    fragData.UV = IonMath_Transform2D(vertData.UV.xy, PassVar_MainTex_ST.xy, PassVar_MainTex_ST.zw);
    
    // 计算裁剪空间位置
    fragData.PositionCS = IonMatrix_ObjectToClip(vertData.PositionOS);
    
    // 将法线转换到世界空间
    fragData.NormalWS = IonMatrix_ObjectToWorldNormal(vertData.Normal);
    
    // 计算世界空间位置
    fragData.PositionWS = IonMatrix_ObjectToWorld(vertData.PositionOS);
    
    // 计算光照坐标（用于距离衰减）
    // 对应 Unity 的 COMPUTE_LIGHT_COORDS 宏
    fragData.LightCoord = IonLight_LightCoord(vertData.PositionOS);
    
    // 计算阴影坐标（用于阴影采样）
    // 对应 Unity 的 TRANSFER_SHADOW 宏
    fragData.ShadowCoord = IonLight_ShadowCoord(vertData.PositionOS, fragData.PositionCS, fragData.PositionWS);
    
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    // 采样主贴图颜色
    half4 mainTex = tex2D(_MainTex, fragData.UV);
    
    // 归一化法线
    float3 normalWS = normalize(fragData.NormalWS);
    
    // === 附加光源（点光源和聚光灯）===
    // 注意：BRP 的 ForwardAdd Pass 每次只处理一个光源
    
    // 计算光照衰减（包含距离衰减和阴影衰减）
    // 使用显式函数替代 UNITY_LIGHT_ATTENUATION 宏
    float atten = IonLight_Attenuation(fragData.LightCoord, fragData.ShadowCoord);
    
    // 获取光源方向
    float3 lightDir = IonLight_Direction(fragData.PositionWS);
    
    // 计算 Lambert 光照（使用 Simple 版本，因为 atten 已经包含了所有衰减）
    // atten 已经是 distanceAttenuation * shadowAttenuation 的组合值
    half3 lighting = IonLight_LambertSimple(
        normalWS,
        lightDir,
        IonParam_LightColor,
        atten
    );
    
    // ForwardAdd Pass 只输出直接光照，不加环境光
    // Alpha 通道设为 0（叠加混合模式）
    return half4(mainTex.rgb * lighting, 0);
}

#endif // Def(IonPassMainAdd)
