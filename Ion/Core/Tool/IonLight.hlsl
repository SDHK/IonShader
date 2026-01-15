/****************************************

* 作者： 闪电黑客
* 日期： 2026/1/6 20:21

* 描述： 各种光照计算工具函数合集

*/

#if DefPart(IonLight, Tool)
#define Def_IonLight_Tool

//===[Lambert 光照计算]===

// 计算 Lambert 光照贡献
// 参数：normalWS - 世界空间法线（float3，已归一化）
// 参数：lightDirection - 光源方向（float3，已归一化）
// 参数：lightColor - 光源颜色（half3）
// 参数：distanceAttenuation - 距离衰减（float）
// 参数：shadowAttenuation - 阴影衰减（half）
// 返回值：光照贡献（half3），包含光源颜色、Lambert 系数和衰减
// 说明：Lambert 光照模型：LightColor * max(0, dot(Normal, LightDirection)) * Attenuation
half3 IonLight_Lambert(float3 normalWS, float3 lightDirection, half3 lightColor, half shadowAttenuation, float distanceAttenuation)
{
    // 计算法线与光源方向的点积（Lambert 系数）
    float ratio = saturate(dot(normalize(normalWS), lightDirection));
    
    // 计算光照贡献：光源颜色 * Lambert 系数 * 距离衰减 * 阴影衰减
    return lightColor * ratio * distanceAttenuation * shadowAttenuation;
}

// 计算 Lambert 光照贡献（简化版本，不包含距离衰减）
// 参数：normalWS - 世界空间法线（float3，已归一化）
// 参数：lightDirection - 光源方向（float3，已归一化）
// 参数：lightColor - 光源颜色（half3）
// 参数：shadowAttenuation - 阴影衰减（half）
// 返回值：光照贡献（half3），包含光源颜色、Lambert 系数和阴影衰减
// 说明：适用于方向光（距离衰减为1）或不需要距离衰减的场景
half3 IonLight_LambertSimple(float3 normalWS, float3 lightDirection, half3 lightColor, half shadowAttenuation)
{
    // 计算法线与光源方向的点积（Lambert 系数）
    float ratio = saturate(dot(normalWS, lightDirection));
    
    // 计算光照贡献：光源颜色 * Lambert 系数 * 阴影衰减
    return lightColor * ratio * shadowAttenuation;
}

#endif // DefPart(IonLight, Tool)