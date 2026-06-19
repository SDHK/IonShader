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

//===[必要参数验证]====================================================
#if PassVar(MainTex)
#error "IonPassMainAdd 缺少必要参数：MainTex（主贴图 / 灰度细节图）"
#endif
#if PassVar(MainTex_ST)
#error "IonPassMainAdd 缺少必要参数：MainTex_ST（MainTex Tiling/Offset）"
#endif
#if PassVar(ColorMask)
#error "IonPassMainAdd 缺少必要参数：ColorMask（RGBA 四通道颜色权重图）"
#endif
#if PassVar(Color1)
#error "IonPassMainAdd 缺少必要参数：Color1（主色，对应 ColorMask.r 区域）"
#endif
#if PassVar(Color2)
#error "IonPassMainAdd 缺少必要参数：Color2（次色，对应 ColorMask.g 区域）"
#endif
#if PassVar(Color3)
#error "IonPassMainAdd 缺少必要参数：Color3（附加色，对应 ColorMask.b 区域）"
#endif
#if PassVar(Color4)
#error "IonPassMainAdd 缺少必要参数：Color4（高亮色，对应 ColorMask.a 区域）"
#endif
#if PassVar(EmissiveTex)
#error "IonPassMainAdd 缺少必要参数：EmissiveTex（自发光遮罩灰度图，黑=不发光 白=全发光）"
#endif
#if PassVar(EmissiveIntensity)
#error "IonPassMainAdd 缺少必要参数：EmissiveIntensity（自发光强度倍率）"
#endif
#if PassVar(LambertScale)
#error "IonPassMainAdd 缺少必要参数：LambertScale（NdotL 缩放，标准=1.0 半兰伯特=0.5）"
#endif
#if PassVar(LambertOffset)
#error "IonPassMainAdd 缺少必要参数：LambertOffset（NdotL 偏移，标准=0.0 半兰伯特=0.5）"
#endif
#if PassVar(LightRampThreshold)
#error "IonPassMainAdd 缺少必要参数：LightRampThreshold（动态光阴影边界位置 0~1）"
#endif
#if PassVar(LightRampSoftness)
#error "IonPassMainAdd 缺少必要参数：LightRampSoftness（动态光边界过渡宽度，0=硬切）"
#endif
#if PassVar(BaseRampColor1)
#error "IonPassMainAdd 缺少必要参数：BaseRampColor1（BaseRamp 阴影域颜色）"
#endif
#if PassVar(BaseRampThreshold1)
#error "IonPassMainAdd 缺少必要参数：BaseRampThreshold1（BaseRamp 边界1位置 0~1）"
#endif
#if PassVar(BaseRampSoftness1)
#error "IonPassMainAdd 缺少必要参数：BaseRampSoftness1（BaseRamp 边界1过渡宽度）"
#endif
#if PassVar(BaseRampColor2)
#error "IonPassMainAdd 缺少必要参数：BaseRampColor2（BaseRamp 中间域颜色）"
#endif
#if PassVar(BaseRampThreshold2)
#error "IonPassMainAdd 缺少必要参数：BaseRampThreshold2（BaseRamp 边界2位置 0~1）"
#endif
#if PassVar(BaseRampSoftness2)
#error "IonPassMainAdd 缺少必要参数：BaseRampSoftness2（BaseRamp 边界2过渡宽度）"
#endif
#if PassVar(BaseRampColor3)
#error "IonPassMainAdd 缺少必要参数：BaseRampColor3（BaseRamp 次高光域颜色）"
#endif
#if PassVar(BaseRampThreshold3)
#error "IonPassMainAdd 缺少必要参数：BaseRampThreshold3（BaseRamp 边界3位置 0~1）"
#endif
#if PassVar(BaseRampSoftness3)
#error "IonPassMainAdd 缺少必要参数：BaseRampSoftness3（BaseRamp 边界3过渡宽度）"
#endif
#if PassVar(BaseRampColor4)
#error "IonPassMainAdd 缺少必要参数：BaseRampColor4（BaseRamp 高光域颜色）"
#endif
#if PassVar(BaseRampDir)
#error "IonPassMainAdd 缺少必要参数：BaseRampDir（BaseRamp 固定参考方向）"
#endif
#if PassVar(BaseRampInfluence)
#error "IonPassMainAdd 缺少必要参数：BaseRampInfluence（BaseRamp 混合权重）"
#endif
#if PassVar(BackRimColor)
#error "IonPassMainAdd 缺少必要参数：BackRimColor（背光边缘光颜色）"
#endif
#if PassVar(BackRimPower)
#error "IonPassMainAdd 缺少必要参数：BackRimPower（背光边缘集中度）"
#endif
#if PassVar(BackRimIntensity)
#error "IonPassMainAdd 缺少必要参数：BackRimIntensity（背光边缘光强度）"
#endif

//===[必要参数声明]====================================================
sampler2D PassVar_MainTex;
float4    PassVar_MainTex_ST;

sampler2D PassVar_ColorMask;
float4    PassVar_Color1;
float4    PassVar_Color2;
float4    PassVar_Color3;
float4    PassVar_Color4;

sampler2D PassVar_EmissiveTex;
float     PassVar_EmissiveIntensity;

float     PassVar_LambertScale;
float     PassVar_LambertOffset;

// Ramp 动态光照（灰度，只控制阴影边界）
float     PassVar_LightRampThreshold;
float     PassVar_LightRampSoftness;

// BaseRamp 光照（固定方向结构性阴影）
float     PassVar_BaseRampInfluence;    // BaseRamp 混合权重（0=不启用，1=完全启用）
float3    PassVar_BaseRampDir;          // 固定参考方向（世界空间，默认 (0,1,0) 向上）

float4    PassVar_BaseRampColor1;
float4    PassVar_BaseRampColor2;
float4    PassVar_BaseRampColor3;
float4    PassVar_BaseRampColor4;
float4    PassVar_BaseRampColor5;

float     PassVar_BaseRampThreshold1;
float     PassVar_BaseRampThreshold2;
float     PassVar_BaseRampThreshold3;
float     PassVar_BaseRampThreshold4;

float     PassVar_BaseRampSoftness1;
float     PassVar_BaseRampSoftness2;
float     PassVar_BaseRampSoftness3;
float     PassVar_BaseRampSoftness4;

// 背光边缘光（逆光轮廓光，跟随附加光源方向）
float4    PassVar_BackRimColor;
float     PassVar_BackRimPower;
float     PassVar_BackRimIntensity;

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
    half4 mainTex = tex2D(PassVar_MainTex, fragData.UV);

    //===[4 色混合]（与 ForwardBase 保持一致）======================
    half4  colorMask   = tex2D(PassVar_ColorMask, fragData.UV);
    float  maskedSum   = colorMask.r + colorMask.g + colorMask.b + colorMask.a;
    float  unmasked    = saturate(1.0 - maskedSum);
    half3  tintedColor = colorMask.r * PassVar_Color1.rgb
                       + colorMask.g * PassVar_Color2.rgb
                       + colorMask.b * PassVar_Color3.rgb
                       + colorMask.a * PassVar_Color4.rgb;
    half3  baseColor   = (tintedColor + mainTex.rgb * unmasked) * mainTex.r;

    //===[附加光源 Ramp 光照]========================================
    float3 normalWS = normalize(fragData.NormalWS);
    float  atten    = IonLight_Attenuation(fragData.LightCoord, fragData.ShadowCoord);
    float3 lightDir = IonLight_Direction(fragData.PositionWS);

    // BaseRamp：固定方向结构性阴影（受附加光源衰减调制，不自发光）
    float NdotBase = saturate(dot(normalWS, normalize(PassVar_BaseRampDir)));
    float3 baseRampColor = IonLight_Ramp(
        NdotBase,
        PassVar_BaseRampColor1.rgb, PassVar_BaseRampThreshold1, PassVar_BaseRampSoftness1,
        PassVar_BaseRampColor2.rgb, PassVar_BaseRampThreshold2, PassVar_BaseRampSoftness2,
        PassVar_BaseRampColor3.rgb, PassVar_BaseRampThreshold3, PassVar_BaseRampSoftness3,
        PassVar_BaseRampColor4.rgb, PassVar_BaseRampThreshold4, PassVar_BaseRampSoftness4,
        PassVar_BaseRampColor5.rgb
    );
    float3 baseShading = baseRampColor * PassVar_BaseRampInfluence * atten;

    float NdotL     = saturate(dot(normalWS, lightDir) * PassVar_LambertScale + PassVar_LambertOffset);
    float rampGray  = IonLight_RampGray(NdotL, PassVar_LightRampThreshold, PassVar_LightRampSoftness);
    half3 lightContrib = baseShading + rampGray * IonParam_LightColor * atten;

    //===[背光边缘光]===============================================
    float3 viewDir     = normalize(IonParam_WorldSpaceCameraPos - fragData.PositionWS);
    float  backRim     = IonLight_BackRim(normalWS, viewDir, lightDir, PassVar_BackRimPower);
    half3  backRimLight = backRim * PassVar_BackRimColor.rgb * PassVar_BackRimIntensity
                        * IonParam_LightColor.rgb * atten;

    //===[自发光区域屏蔽]============================================
    // 自发光权重越高的区域越不受附加光影响，与 ForwardBase 行为一致
    float emissiveMask   = tex2D(PassVar_EmissiveTex, fragData.UV).r;
    float emissiveWeight = saturate(emissiveMask * PassVar_EmissiveIntensity);

    // ForwardAdd 只输出直接光照，Alpha 为 0（Blend One One 叠加模式）
    return half4((baseColor * lightContrib + backRimLight) * (1.0 - emissiveWeight), 0);
}

#endif // Def(IonPassMainAdd)
