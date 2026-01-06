/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/4 14:16
*
* 说明： Unity 引擎的 Ion Shader 库统一入口
*
* 功能：初始化 Ion Shader 库在 Unity 引擎下的运行环境
*
* 注入 Unity 引擎相关的 Ion 参数映射
* 注入 Unity 引擎相关的 Shader 核心模块
*
* 加载 IonPass 入口（IonPass.hlsl）
* 加载 Ion 库入口（IonCore.hlsl）
*
*/

#ifndef Def_IonCoreUnity
#define Def_IonCoreUnity

//===[引入配置]===

#include "../IonConfig.hlsl"

//===[引入引擎绑定]===
#ifdef IonShader_BRP
#include "Pipeline/BRP/Core/IonCoreBRP.hlsl"
#elif defined(IonShader_URP)
#include "Pipeline/URP/Core/IonCoreURP.hlsl"
#endif

//===[加载 Ion Shader 库入口]===
#include "../Ion/Pass/IonPass.hlsl"
#include "../Ion/Core/IonCore.hlsl"
#endif

