/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/XX
*
* 说明： Unity URP 的 Iris 关键字映射实现
*
* 设计理念：
* - 将 IrisKey_XXX 映射到 Unity URP 的 _XXX 关键字
* - 只有当 Pass 文件定义了 IrisKey_XXX 时才进行映射
*
*/

#ifndef Def_IrisKey
#define Def_IrisKey

//===[阴影关键字映射]===

// 主光源阴影：生成 #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
// 代码中使用 #if IrisKey_MainLightShadows 判断是否有主光源阴影
#ifdef IrisKey_MainLightShadows
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
#define IrisKey_MainLightShadows defined(_MAIN_LIGHT_SHADOWS)
#endif

// 级联阴影：生成 #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
// 代码中使用 #if IrisKey_MainLightShadowsCascade 判断是否有级联阴影
#ifdef IrisKey_MainLightShadowsCascade
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
#define IrisKey_MainLightShadowsCascade defined(_MAIN_LIGHT_SHADOWS_CASCADE)
#endif

// 软阴影：生成 #pragma multi_compile _ _SHADOWS_SOFT
// 代码中使用 #if IrisKey_ShadowsSoft 判断是否有软阴影
#ifdef IrisKey_ShadowsSoft
#pragma multi_compile _ _SHADOWS_SOFT
#define IrisKey_ShadowsSoft defined(_SHADOWS_SOFT)
#endif

// 附加光源阴影：生成 #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
// 代码中使用 #if IrisKey_AdditionalLightShadows 判断是否有附加光源阴影
#ifdef IrisKey_AdditionalLightShadows
#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
#define IrisKey_AdditionalLightShadows defined(_ADDITIONAL_LIGHT_SHADOWS)
#endif

// 阴影投射器：生成 #pragma multi_compile_shadowcaster
#ifdef IrisKey_ShadowCaster
#pragma multi_compile_shadowcaster
#define IrisKey_ShadowCaster
#endif

//===[基础功能关键字映射]===

// 雾效：生成 #pragma multi_compile_fog
// 注意：IrisKey_Fog 映射到组合判断（FOG_LINEAR || FOG_EXP || FOG_EXP2），用于在代码中判断是否有雾效
// Unity 会根据场景设置自动选择 FOG_LINEAR/FOG_EXP/FOG_EXP2 变体
// URP 中使用 MixFog/MixFogColor 函数（需包含 URP 库），BRP 中使用 UNITY_APPLY_FOG 宏
// 代码中使用 #if IrisKey_Fog 判断是否有雾效（注意是 #if 不是 #ifdef）
#ifdef IrisKey_Fog
#pragma multi_compile_fog
#define IrisKey_Fog (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
#endif

// GPU Instancing：生成 #pragma multi_compile_instancing
// 代码中使用 #if IrisKey_Instancing 判断是否启用 GPU Instancing
#ifdef IrisKey_Instancing
#pragma multi_compile_instancing
#define IrisKey_Instancing defined(_INSTANCING)
#endif

// DOTS Instancing：生成 #pragma multi_compile _ DOTS_INSTANCING_ON
// 代码中使用 #if IrisKey_DotsInstancing 判断是否启用 DOTS Instancing
#ifdef IrisKey_DotsInstancing
#pragma multi_compile _ DOTS_INSTANCING_ON
#define IrisKey_DotsInstancing defined(DOTS_INSTANCING_ON)
#endif

//===[光照相关关键字映射]===

// 光照贴图：IrisKey_Lightmap -> LIGHTMAP_ON
// 注意：Unity 根据场景设置自动控制此关键字，不需要 #pragma
// 代码中使用 #if IrisKey_Lightmap 判断是否有光照贴图
#ifdef IrisKey_Lightmap
#define IrisKey_Lightmap defined(LIGHTMAP_ON)
#endif

// 动态光照贴图：IrisKey_DynamicLightmap -> DYNAMICLIGHTMAP_ON
// 注意：Unity 根据场景设置自动控制此关键字，不需要 #pragma
// 代码中使用 #if IrisKey_DynamicLightmap 判断是否有动态光照贴图
#ifdef IrisKey_DynamicLightmap
#define IrisKey_DynamicLightmap defined(DYNAMICLIGHTMAP_ON)
#endif

// 方向性光照贴图：IrisKey_DirectionalLightmap -> DIRLIGHTMAP_COMBINED
// 注意：Unity 根据场景设置自动控制此关键字，不需要 #pragma
// 代码中使用 #if IrisKey_DirectionalLightmap 判断是否有方向性光照贴图
#ifdef IrisKey_DirectionalLightmap
#define IrisKey_DirectionalLightmap defined(DIRLIGHTMAP_COMBINED)
#endif

// 顶点光照：URP 不支持顶点光照
#ifdef IrisKey_VertexLight
#define IrisKey_VertexLight
#endif

//===[BRP 特有关键字映射]===

// Forward Base：URP 不支持 Forward Base
#ifdef IrisKey_ForwardBase
#define IrisKey_ForwardBase
#endif

//===[纹理相关关键字映射]===

// 法线贴图：IrisKey_NormalMap -> _NORMALMAP
// 代码中使用 #if IrisKey_NormalMap 判断是否有法线贴图
#ifdef IrisKey_NormalMap
#define IrisKey_NormalMap defined(_NORMALMAP)
#endif

// 镜面高光贴图：IrisKey_SpecGlossMap -> _SPECGLOSSMAP
// 代码中使用 #if IrisKey_SpecGlossMap 判断是否有镜面高光贴图
#ifdef IrisKey_SpecGlossMap
#define IrisKey_SpecGlossMap defined(_SPECGLOSSMAP)
#endif

// 金属度光泽度贴图：IrisKey_MetallicGlossMap -> _METALLICGLOSSMAP
// 代码中使用 #if IrisKey_MetallicGlossMap 判断是否有金属度光泽度贴图
#ifdef IrisKey_MetallicGlossMap
#define IrisKey_MetallicGlossMap defined(_METALLICGLOSSMAP)
#endif

// 反照率贴图：IrisKey_AlbedoMap -> _ALBEDOMAP
// 代码中使用 #if IrisKey_AlbedoMap 判断是否有反照率贴图
#ifdef IrisKey_AlbedoMap
#define IrisKey_AlbedoMap defined(_ALBEDOMAP)
#endif

// 细节贴图：IrisKey_DetailMap -> _DETAIL_MAP
// 代码中使用 #if IrisKey_DetailMap 判断是否有细节贴图
#ifdef IrisKey_DetailMap
#define IrisKey_DetailMap defined(_DETAIL_MAP)
#endif

//===[高级功能关键字映射]===

// 像素对齐：IrisKey_PixelSnap -> PIXELSNAP_ON
// 代码中使用 #if IrisKey_PixelSnap 判断是否启用像素对齐
#ifdef IrisKey_PixelSnap
#define IrisKey_PixelSnap defined(PIXELSNAP_ON)
#endif

// 屏幕空间反射：IrisKey_ScreenSpaceReflections -> _SCREEN_SPACE_REFLECTIONS
// 代码中使用 #if IrisKey_ScreenSpaceReflections 判断是否启用屏幕空间反射
#ifdef IrisKey_ScreenSpaceReflections
#define IrisKey_ScreenSpaceReflections defined(_SCREEN_SPACE_REFLECTIONS)
#endif

// 环境光遮蔽：IrisKey_AmbientOcclusion -> _AMBIENT_OCCLUSION
// 代码中使用 #if IrisKey_AmbientOcclusion 判断是否启用环境光遮蔽
#ifdef IrisKey_AmbientOcclusion
#define IrisKey_AmbientOcclusion defined(_AMBIENT_OCCLUSION)
#endif

// 反射探针：IrisKey_ReflectionProbe -> _REFLECTION_PROBE
// 注意：Unity 根据场景设置自动控制此关键字，不需要 #pragma
// 代码中使用 #if IrisKey_ReflectionProbe 判断是否有反射探针
#ifdef IrisKey_ReflectionProbe
#define IrisKey_ReflectionProbe defined(_REFLECTION_PROBE)
#endif

// 光照探针：IrisKey_LightProbe -> _LIGHT_PROBE
// 注意：Unity 根据场景设置自动控制此关键字，不需要 #pragma
// 代码中使用 #if IrisKey_LightProbe 判断是否有光照探针
#ifdef IrisKey_LightProbe
#define IrisKey_LightProbe defined(_LIGHT_PROBE)
#endif

//===[自定义功能关键字映射]===

// 动画循环：生成 #pragma multi_compile ___ ANIM_LOOP
// 代码中使用 #if IrisKey_AnimLoop 判断是否启用动画循环
#ifdef IrisKey_AnimLoop
#pragma multi_compile ___ ANIM_LOOP
#define IrisKey_AnimLoop defined(ANIM_LOOP)
#endif

// 动画暂停：生成 #pragma multi_compile ___ ANIM_PAUSED
// 代码中使用 #if IrisKey_AnimPaused 判断是否启用动画暂停
#ifdef IrisKey_AnimPaused
#pragma multi_compile ___ ANIM_PAUSED
#define IrisKey_AnimPaused defined(ANIM_PAUSED)
#endif

// 启用动画：生成 #pragma shader_feature _ ENABLE_ANIM
// 代码中使用 #if IrisKey_EnableAnim 判断是否启用动画
#ifdef IrisKey_EnableAnim
#pragma shader_feature _ ENABLE_ANIM
#define IrisKey_EnableAnim defined(ENABLE_ANIM)
#endif

#endif // Def_IrisKey

