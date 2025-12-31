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
* 注意：
* - 本文件是给外部 Shader 文件使用的
* - 内部工具文件（Tools/）之间直接使用路径引用，不通过本文件
*
*/

#ifndef Def_IrisEntry
#define Def_IrisEntry

//===[环境库引用]===
// 引用基础库（根据 URP/BRP 自动选择）
// 使用 Use_IrisCore 和 Use_IrisLight 宏控制是否包含
#ifdef Inc_IrisBase
#include Inc_IrisBase
#endif

//===[Iris库引用]===

//===[引入常量定义集]===
#include "Base/IrisConst.hlsl"
//===[引入结构体字段定义]===
#include "Base/IrisStruct.hlsl"

//===[引入外部绑定]===
#ifdef Inc_IrisBind
#include Inc_IrisBind 
#else
#include "Bind/IrisBind.hlsl"
#endif

//===[可选引用]===
// 工具函数统一入口（根据 Use_IrisXXX 宏控制是否生效）
#include "Tools/IrisTools.hlsl"


#endif