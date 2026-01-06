/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/XX
*
* 说明： Unity BRP 的 Ion 关键字映射实现
*
* 设计理念：
* - 将 IonKey_XXX 映射到 Unity BRP 的关键字
* - 只有当 Pass 文件定义了 IonKey_XXX 时才进行映射
* - BRP 的阴影和光照通过 fwdbase 变体处理，部分关键字不需要映射
*
*/

#ifndef Def_IonKey
#define Def_IonKey

//===[阴影关键字映射]===
// BRP 的阴影通过 fwdbase 变体处理，不需要单独的关键字映射

// 主光源阴影：BRP 通过 fwdbase 处理，不需要关键字映射
#ifdef IonKey_MainLightShadows
#define IonKey_MainLightShadows
#endif

// 级联阴影：BRP 不支持级联阴影
#ifdef IonKey_MainLightShadowsCascade
#define IonKey_MainLightShadowsCascade
#endif

// 软阴影：BRP 不支持软阴影关键字
#ifdef IonKey_ShadowsSoft
#define IonKey_ShadowsSoft
#endif

// 附加光源阴影：BRP 通过 fwdbase 处理
#ifdef IonKey_AdditionalLightShadows
#define IonKey_AdditionalLightShadows
#endif

// 阴影投射器：生成 #pragma multi_compile_shadowcaster
// 注意：IonKey_ShadowCaster 是空定义（不映射到 Unity 关键字），仅用于触发变体生成
// BRP 的 shadowcaster 变体由 multi_compile_shadowcaster 自动处理，代码中无需判断关键字
#ifdef IonKey_ShadowCaster
#pragma multi_compile_shadowcaster
#define IonKey_ShadowCaster
#endif

//===[基础功能关键字映射]===

// 雾效：生成 #pragma multi_compile_fog
// 注意：IonKey_Fog 映射到组合判断（FOG_LINEAR || FOG_EXP || FOG_EXP2），用于在代码中判断是否有雾效
// Unity 会根据场景设置自动选择 FOG_LINEAR/FOG_EXP/FOG_EXP2 变体
// BRP 中使用 UNITY_APPLY_FOG 宏（需包含 UnityCG.cginc）：UNITY_FOG_COORDS + UNITY_TRANSFER_FOG + UNITY_APPLY_FOG
// 代码中使用 #if IonKey_Fog 判断是否有雾效（注意是 #if 不是 #ifdef）
#ifdef IonKey_Fog
#pragma multi_compile_fog
#define IonKey_Fog (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
#endif

// GPU Instancing：BRP 不支持 _INSTANCING 关键字
#ifdef IonKey_Instancing
#define IonKey_Instancing
#endif

// DOTS Instancing：BRP 不支持 DOTS Instancing
#ifdef IonKey_DotsInstancing
#define IonKey_DotsInstancing
#endif

//===[光照相关关键字映射]===

// 光照贴图：IonKey_Lightmap -> LIGHTMAP_ON
// 注意：Unity 根据场景设置自动控制此关键字，不需要 #pragma
// 代码中使用 #if IonKey_Lightmap 判断是否有光照贴图
#ifdef IonKey_Lightmap
#define IonKey_Lightmap defined(LIGHTMAP_ON)
#endif

// 动态光照贴图：IonKey_DynamicLightmap -> DYNAMICLIGHTMAP_ON
// 注意：Unity 根据场景设置自动控制此关键字，不需要 #pragma
// 代码中使用 #if IonKey_DynamicLightmap 判断是否有动态光照贴图
#ifdef IonKey_DynamicLightmap
#define IonKey_DynamicLightmap defined(DYNAMICLIGHTMAP_ON)
#endif

// 方向性光照贴图：IonKey_DirectionalLightmap -> DIRLIGHTMAP_COMBINED
// 注意：Unity 根据场景设置自动控制此关键字，不需要 #pragma
// 代码中使用 #if IonKey_DirectionalLightmap 判断是否有方向性光照贴图
#ifdef IonKey_DirectionalLightmap
#define IonKey_DirectionalLightmap defined(DIRLIGHTMAP_COMBINED)
#endif

// 顶点光照：IonKey_VertexLight -> VERTEXLIGHT_ON
// 代码中使用 #if IonKey_VertexLight 判断是否启用顶点光照
#ifdef IonKey_VertexLight
#define IonKey_VertexLight defined(VERTEXLIGHT_ON)
#endif

//===[BRP 特有关键字映射]===

// Forward Base：生成 #pragma multi_compile_fwdbase
// 注意：IonKey_ForwardBase 是空定义（不映射到 Unity 关键字），仅用于触发变体生成
// BRP 的 fwdbase 变体包含光照和阴影信息，代码中无需判断此关键字，Unity 会自动选择正确的变体
#ifdef IonKey_ForwardBase
#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
#define IonKey_ForwardBase
#endif

//===[纹理相关关键字映射]===

// 法线贴图：IonKey_NormalMap -> _NORMALMAP
// 代码中使用 #if IonKey_NormalMap 判断是否有法线贴图
#ifdef IonKey_NormalMap
#define IonKey_NormalMap defined(_NORMALMAP)
#endif

// 镜面高光贴图：BRP 可能使用不同的关键字
#ifdef IonKey_SpecGlossMap
#define IonKey_SpecGlossMap
#endif

// 金属度光泽度贴图：BRP 可能使用不同的关键字
#ifdef IonKey_MetallicGlossMap
#define IonKey_MetallicGlossMap
#endif

// 反照率贴图：BRP 可能使用不同的关键字
#ifdef IonKey_AlbedoMap
#define IonKey_AlbedoMap
#endif

// 细节贴图：BRP 可能使用不同的关键字
#ifdef IonKey_DetailMap
#define IonKey_DetailMap
#endif

//===[高级功能关键字映射]===

// 像素对齐：IonKey_PixelSnap -> PIXELSNAP_ON
// 代码中使用 #if IonKey_PixelSnap 判断是否启用像素对齐
#ifdef IonKey_PixelSnap
#define IonKey_PixelSnap defined(PIXELSNAP_ON)
#endif

// 屏幕空间反射：BRP 不支持屏幕空间反射关键字
#ifdef IonKey_ScreenSpaceReflections
#define IonKey_ScreenSpaceReflections
#endif

// 环境光遮蔽：BRP 可能使用不同的关键字
#ifdef IonKey_AmbientOcclusion
#define IonKey_AmbientOcclusion
#endif

// 反射探针：IonKey_ReflectionProbe -> _REFLECTION_PROBE
// 注意：Unity 根据场景设置自动控制此关键字，不需要 #pragma
// 代码中使用 #if IonKey_ReflectionProbe 判断是否有反射探针
#ifdef IonKey_ReflectionProbe
#define IonKey_ReflectionProbe defined(_REFLECTION_PROBE)
#endif

// 光照探针：IonKey_LightProbe -> _LIGHT_PROBE
// 注意：Unity 根据场景设置自动控制此关键字，不需要 #pragma
// 代码中使用 #if IonKey_LightProbe 判断是否有光照探针
#ifdef IonKey_LightProbe
#define IonKey_LightProbe defined(_LIGHT_PROBE)
#endif

//===[自定义功能关键字映射]===

// 动画循环：生成 #pragma multi_compile ___ ANIM_LOOP
// 代码中使用 #if IonKey_AnimLoop 判断是否启用动画循环
#ifdef IonKey_AnimLoop
#pragma multi_compile ___ ANIM_LOOP
#define IonKey_AnimLoop defined(ANIM_LOOP)
#endif

// 动画暂停：生成 #pragma multi_compile ___ ANIM_PAUSED
// 代码中使用 #if IonKey_AnimPaused 判断是否启用动画暂停
#ifdef IonKey_AnimPaused
#pragma multi_compile ___ ANIM_PAUSED
#define IonKey_AnimPaused defined(ANIM_PAUSED)
#endif

// 启用动画：生成 #pragma shader_feature _ ENABLE_ANIM
// 代码中使用 #if IonKey_EnableAnim 判断是否启用动画
#ifdef IonKey_EnableAnim
#pragma shader_feature _ ENABLE_ANIM
#define IonKey_EnableAnim defined(ENABLE_ANIM)
#endif

#endif // Def_IonKey

