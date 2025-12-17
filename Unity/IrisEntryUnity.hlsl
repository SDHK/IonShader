/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/4 14:16
*
* 说明： Unity 引擎的 Iris Shader 库统一入口
*
* 功能：初始化 Iris Shader 库在 Unity 引擎下的运行环境
*
* 注入 Unity 引擎相关的 Iris 参数映射
* 注入 Unity 引擎相关的 Shader 核心模块
*
* 加载 Iris Shader Pass 入口（IrisEntryPass.hlsl）
* 加载 Iris 库入口（IrisEntry.hlsl）
*
*/

#ifndef Def_IrisEntryUnity
#define Def_IrisEntryUnity

//定义当前使用的渲染管线类型
#define IrisShader_URP

//===[注入 Shader 核心模块]===
//===[URP]===
#ifdef IrisShader_URP
#define Inc_ShaderCore "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//#define Inc_ShaderLighting "../Unity/Library/IrisLightLibrary.hlsl"
#define Inc_ShaderLighting "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

//===[BRP]===
#elif IrisShader_BRP
#define Inc_ShaderCore "UnityCG.cginc"
#define Inc_ShaderLighting "UnityStandardBRP.cginc"
#endif

//===[注入 Unity 参数映射]===
#define Inc_IrisParams "../Unity/Macro/IrisParamsUnity.hlsl"
//===[注入 Untiy 方法映射]===
#define Inc_IrisMethod "../Unity/Macro/IrisMethodUnity.hlsl"

//===[加载 Iris Shader 库入口]===
#include "../Iris/IrisEntryPass.hlsl"
//#include "../Iris/IrisEntry.hlsl"

#endif