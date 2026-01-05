/*
* 作者： 闪电黑客
* 日期： 2025/12/5 10:29
*
* 说明： Iris Shader 库外部统一入口文件
*
* 设计理念：
* - 本文件是外部 Shader 文件使用的统一入口，避免路径写错
* - 内部工具文件之间使用直接路径引用
*
* IrisShader 宏说明：
* - 编辑器时（未定义 IrisShader）：
*   用于代码跳转和依赖提示，让开发者能够：
*   * 通过 #include "../IrisEdit.hlsl" 跳转到依赖模块
*   * 看到需要定义的 Link_XXX 宏（如 Link_IrisHash）
*   * 理解模块间的依赖关系
* - 运行时（定义 IrisShader）：
*   让编辑器辅助入口（IrisEdit.hlsl）无效化，实际包含由 IrisLinkTool.hlsl 统一控制
*   避免循环引用，确保只包含需要的模块
*
* 注意：
* - 本文件是给外部 Shader 文件使用的运行时入口
* - 内部工具文件（Tool/）和 Pass 文件（Pass/）应使用 IrisEdit.hlsl 作为编辑器辅助入口
* - IrisEdit.hlsl 在运行时会被 IrisShader 宏禁用，避免不必要的代码包含
*
*/


#ifndef Def_IrisCore
#define Def_IrisCore

//===[引入核心宏定义]===
#include "../IrisMacro.hlsl"

//===[引入映射系统]===
// 注意：Map 必须在 Library 之前引入，以便 Unity 库代码能正确识别关键字
#ifdef Inc_IrisMap
#include Inc_IrisMap
#else
#include "Map/IrisLinkMap.hlsl"
#endif

//===[环境库引用]===
// 引用基础库（根据 URP/BRP 自动选择）
// 使用 Link_IrisBase 和 Link_IrisLight 宏控制是否链接
#ifdef Inc_IrisLibrary
#include Inc_IrisLibrary
#endif

//===[Iris库引用]===

//===[引入定义]===
#include "Define/IrisLinkDefine.hlsl"

//===[引入外部绑定]===
#ifdef Inc_IrisBind
#include Inc_IrisBind 
#else
#include "Bind/IrisLinkBind.hlsl"
#endif

//===[可选引用]===
// 工具函数统一入口（根据 Link_IrisXXX 宏控制是否链接）
#include "Tool/IrisLinkTool.hlsl"

#endif // Def_IrisCore