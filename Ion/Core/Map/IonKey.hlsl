/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/XX
*
* 说明： Ion 关键字接口规范/模板
*
* 设计理念：
* - 本文件定义了统一的关键字接口规范
* - 不同引擎需要按照此规范实现对应的关键字映射文件
* - 所有关键字使用 IonKey_ 前缀，保持命名空间统一
*
* 实现要求：
* 1. 每个 IonKey_XXX 必须映射到对应引擎的关键字
* 2. 如果引擎不支持某个关键字，可以不映射（保持未定义状态）
* 3. 关键字映射应在 Pass 文件声明后、代码使用前完成
*
* 使用方式：
* 1. Pass 文件中：#define IonKey_XXX 声明需要的功能
* 2. 包含本文件：将 IonKey_XXX 映射到引擎关键字
* 3. 代码中使用：#ifdef IonKey_XXX 检查关键字
*
*/

#ifndef Def_IonKey
#define Def_IonKey

//===[阴影关键字接口]===

// 主光源阴影
// 说明：启用主光源的阴影投射和接收功能
// 引擎实现：URP -> _MAIN_LIGHT_SHADOWS, BRP -> (通过 fwdbase 处理)
#ifdef IonKey_MainLightShadows
#define IonKey_MainLightShadows
#endif

// 级联阴影
// 说明：启用级联阴影贴图（Cascaded Shadow Maps），提高远距离阴影质量
// 引擎实现：URP -> _MAIN_LIGHT_SHADOWS_CASCADE
#ifdef IonKey_MainLightShadowsCascade
#define IonKey_MainLightShadowsCascade
#endif

// 软阴影
// 说明：启用软阴影（PCF 过滤），使阴影边缘更柔和
// 引擎实现：URP -> _SHADOWS_SOFT
#ifdef IonKey_ShadowsSoft
#define IonKey_ShadowsSoft
#endif

// 附加光源阴影
// 说明：启用附加光源的阴影投射和接收功能
// 引擎实现：URP -> _ADDITIONAL_LIGHT_SHADOWS
#ifdef IonKey_AdditionalLightShadows
#define IonKey_AdditionalLightShadows
#endif

// 阴影投射器
// 说明：用于 ShadowCaster Pass，启用阴影投射功能
// 引擎实现：URP/BRP -> multi_compile_shadowcaster
#ifdef IonKey_ShadowCaster
#define IonKey_ShadowCaster
#endif

//===[基础功能关键字接口]===

// 雾效
// 说明：启用雾效计算，支持线性、指数、指数平方三种模式
// 引擎实现：URP/BRP -> _FOG (multi_compile_fog 会自动处理)
#ifdef IonKey_Fog
#define IonKey_Fog
#endif

// GPU Instancing
// 说明：启用 GPU Instancing，提高相同物体的渲染性能
// 引擎实现：URP -> _INSTANCING (multi_compile_instancing)
#ifdef IonKey_Instancing
#define IonKey_Instancing
#endif

// DOTS Instancing
// 说明：启用 DOTS Instancing，用于 ECS 系统
// 引擎实现：URP -> DOTS_INSTANCING_ON
#ifdef IonKey_DotsInstancing
#define IonKey_DotsInstancing
#endif

//===[光照相关关键字接口]===

// 光照贴图
// 说明：启用光照贴图（Lightmap），用于静态物体光照烘焙
// 引擎实现：URP/BRP -> LIGHTMAP_ON
#ifdef IonKey_Lightmap
#define IonKey_Lightmap
#endif

// 动态光照贴图
// 说明：启用动态光照贴图（Dynamic Lightmap），用于动态物体光照
// 引擎实现：URP/BRP -> DYNAMICLIGHTMAP_ON
#ifdef IonKey_DynamicLightmap
#define IonKey_DynamicLightmap
#endif

// 方向性光照贴图
// 说明：启用方向性光照贴图（Directional Lightmap），包含方向信息
// 引擎实现：URP/BRP -> DIRLIGHTMAP_COMBINED
#ifdef IonKey_DirectionalLightmap
#define IonKey_DirectionalLightmap
#endif

// 顶点光照
// 说明：启用顶点光照（Vertex Light），用于 BRP 的顶点光照模式
// 引擎实现：BRP -> VERTEXLIGHT_ON
#ifdef IonKey_VertexLight
#define IonKey_VertexLight
#endif

//===[BRP 特有关键字接口]===

// Forward Base
// 说明：BRP Forward Base Pass 的光照模式变体
// 引擎实现：BRP -> multi_compile_fwdbase (nolightmap nodirlightmap nodynlightmap novertexlight)
// 注意：BRP 的阴影和光照通过 fwdbase 变体处理，不需要单独的关键字
#ifdef IonKey_ForwardBase
#define IonKey_ForwardBase
#endif

//===[纹理相关关键字接口]===

// 法线贴图
// 说明：启用法线贴图（Normal Map），用于表面细节
// 引擎实现：URP/BRP -> _NORMALMAP
#ifdef IonKey_NormalMap
#define IonKey_NormalMap
#endif

// 镜面高光贴图
// 说明：启用镜面高光贴图（Specular Gloss Map），用于 PBR 材质
// 引擎实现：URP -> _SPECGLOSSMAP
#ifdef IonKey_SpecGlossMap
#define IonKey_SpecGlossMap
#endif

// 金属度光泽度贴图
// 说明：启用金属度光泽度贴图（Metallic Gloss Map），用于 PBR 材质
// 引擎实现：URP -> _METALLICGLOSSMAP
#ifdef IonKey_MetallicGlossMap
#define IonKey_MetallicGlossMap
#endif

// 反照率贴图
// 说明：启用反照率贴图（Albedo Map），用于基础颜色
// 引擎实现：URP -> _ALBEDOMAP
#ifdef IonKey_AlbedoMap
#define IonKey_AlbedoMap
#endif

// 细节贴图
// 说明：启用细节贴图（Detail Map），用于表面细节叠加
// 引擎实现：URP -> _DETAIL_MAP
#ifdef IonKey_DetailMap
#define IonKey_DetailMap
#endif

//===[高级功能关键字接口]===

// 像素对齐
// 说明：启用像素对齐（Pixel Snap），用于像素艺术风格
// 引擎实现：URP/BRP -> PIXELSNAP_ON
#ifdef IonKey_PixelSnap
#define IonKey_PixelSnap
#endif

// 屏幕空间反射
// 说明：启用屏幕空间反射（Screen Space Reflections）
// 引擎实现：URP -> _SCREEN_SPACE_REFLECTIONS
#ifdef IonKey_ScreenSpaceReflections
#define IonKey_ScreenSpaceReflections
#endif

// 环境光遮蔽
// 说明：启用环境光遮蔽（Ambient Occlusion），用于阴影细节
// 引擎实现：URP -> _AMBIENT_OCCLUSION
#ifdef IonKey_AmbientOcclusion
#define IonKey_AmbientOcclusion
#endif

// 反射探针
// 说明：启用反射探针（Reflection Probe），用于环境反射
// 引擎实现：URP/BRP -> _REFLECTION_PROBE
#ifdef IonKey_ReflectionProbe
#define IonKey_ReflectionProbe
#endif

// 光照探针
// 说明：启用光照探针（Light Probe），用于动态物体光照
// 引擎实现：URP/BRP -> _LIGHT_PROBE
#ifdef IonKey_LightProbe
#define IonKey_LightProbe
#endif

//===[自定义功能关键字接口]===
// 以下关键字可以根据项目需求自定义使用

// 动画循环
// 说明：自定义关键字，用于控制动画循环播放
// 引擎实现：自定义 -> ANIM_LOOP
#ifdef IonKey_AnimLoop
#define IonKey_AnimLoop
#endif

// 动画暂停
// 说明：自定义关键字，用于控制动画暂停
// 引擎实现：自定义 -> ANIM_PAUSED
#ifdef IonKey_AnimPaused
#define IonKey_AnimPaused
#endif

// 启用动画
// 说明：自定义关键字，用于启用/禁用动画功能
// 引擎实现：自定义 -> ENABLE_ANIM
#ifdef IonKey_EnableAnim
#define IonKey_EnableAnim
#endif

#endif // Def_IonKey
