
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




// 模块包装宏（单参数版本 - 完整模块）
// 用于判断是否应该定义某个完整模块，防止重复定义
// 使用场景：Pass 文件、Tool 文件等完整模块
#define Def(name) \
defined(Link_##name) && !defined(Def_##name) || !defined(IrisShader)

// 模块包装宏（双参数版本 - 部分模块）
// 用于判断是否应该定义某个模块的特定部分，防止重复定义
// 使用场景：统一链接文件中控制不同部分的加载
// part 可以是：Library, Bind, Tool 等
#define DefPart(name,part) \
defined(Link_##name) && !defined(Def_##name##_##part) || !defined(IrisShader)


// 模块链接宏（单行版本）
// 用于判断是否应该链接某个模块，控制按需加载
#define Link(name) \
defined(Link_##name) || !defined(IrisShader)

#endif