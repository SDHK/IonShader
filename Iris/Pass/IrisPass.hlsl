/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/16
*
* 描述： Iris Shader Pass 统一入口
*
* 设计理念：
* - 本文件是 Pass 文件的统一入口，避免路径写错
* - 通过宏控制按需加载 Pass，减少不必要的代码包含
* - 提供统一的 Pass 管理机制，便于维护和扩展
*
* 功能：
* - 统一包含所有 Pass 文件
* - 根据 Use_IrisXXXPass 宏控制是否链接
* - 提供 Def 和 Link 宏定义，供 Pass 文件使用
*
* 使用方法：
* 1. 在 Shader 文件中定义需要的 Pass 宏：
*    #define Use_IrisPassOutlineDefault
*    #define Use_IrisPassOutlineForward
*    #define Use_IrisPassOutlineShadow
*
* 注意：
* - 确保 Pass 在 Core 之前加载
*
*/


// 模块包装宏（单行版本）
#define Def(name) \
defined(Use_##name) && !defined(Def_##name) || !defined(IrisShader)

// 模块链接宏（单行版本）
#define Link(name) \
defined(Use_##name)||!defined(IrisShader)


//===[Outline Pass]===
#if Link(IrisPassOutlineDefault)
#include "IrisPassOutlineDefault.hlsl"   // 默认轮廓 Pass
#endif
#if Link(IrisPassOutlineForward)
#include "IrisPassOutlineForward.hlsl"   // 前向渲染 Pass
#endif
#if Link(IrisPassOutlineShadow)
#include "IrisPassOutlineShadow.hlsl"    // 阴影投射 Pass
#endif

