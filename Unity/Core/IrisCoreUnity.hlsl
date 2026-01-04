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
* 加载 IrisPass 入口（IrisPass.hlsl）
* 加载 Iris 库入口（IrisCore.hlsl）
*
*/

#ifndef Def_IrisCoreUnity
#define Def_IrisCoreUnity

//===[引入配置]===

#include "../../../IrisConfig.hlsl"

//===[注入基础库]===
#define Inc_IrisBase "../../Unity/Core/Base/IrisLinkBase.hlsl"

//====[注入 Unity 绑定]===
#define Inc_IrisBind "../../Unity/Core/Bind/IrisLinkBind.hlsl"

//===[加载 Iris Shader 库入口]===
#include "../../Iris/Pass/IrisPass.hlsl"
#include "../../Iris/Core/IrisCore.hlsl"

#endif

