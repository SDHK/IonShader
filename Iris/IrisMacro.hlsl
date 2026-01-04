
/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/19
*
* 描述： Iris Shader 框架核心宏定义
*
* 功能：定义框架使用的核心宏系统
*       - Def 宏：模块包装宏，用于防止重复定义
*       - Link 宏：模块链接宏，用于控制模块加载
*
* 设计理念：
* - 统一管理框架的核心宏定义，避免重复定义
* - 所有需要 Def/Link 宏的文件都应包含本文件
* - 通过宏系统实现按需加载和防止重复包含
*
*/

#ifndef Def_IrisMacro
#define Def_IrisMacro

// 模块包装宏（单行版本）
// 用于判断是否应该定义某个模块，防止重复定义
#define Def(name) \
defined(Use_##name) && !defined(Def_##name) || !defined(IrisShader)

// 模块链接宏（单行版本）
// 用于判断是否应该链接某个模块，控制按需加载
#define Link(name) \
defined(Use_##name) || !defined(IrisShader)

#endif