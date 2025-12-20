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
// 引用 Shader 核心模块
#include Inc_ShaderCore

//===[可选引用]===
// 引用 Shader 光照模块
#ifdef Use_ShaderLighting
#include Inc_ShaderLighting
#endif

// 引用 Shader 阴影模块（BRP需要）
#ifdef Inc_ShaderAutoLight
#include Inc_ShaderAutoLight
#endif



//===[Iris库引用]===

//===[引入常量定义集]===
#include "Macro/IrisConst.hlsl"
//===[引入结构体字段定义]===
#include "Macro/IrisStruct.hlsl"

//===[引入参数接口规范]===
#ifdef Inc_IrisParams
#include Inc_IrisParams //如果外部定义了，则使用外部定义
#else
#include "Macro/IrisParams.hlsl"
#endif
//===[引入方法接口规范]===
#ifdef Inc_IrisMethod
#include Inc_IrisMethod //如果外部定义了，则使用外部定义
#else
#include "Macro/IrisMethod.hlsl"
#endif

//===[可选引用]===

#ifdef Use_IrisVertex
#include "Tools/IrisVertex.hlsl"
#endif

#ifdef Use_IrisDistort
#include "Tools/IrisDistort.hlsl"
#endif

#ifdef Use_IrisHash
#include "Tools/IrisHash.hlsl"
#endif

#ifdef Use_IrisMath
#include "Tools/IrisMath.hlsl"
#endif

#ifdef Use_IrisNoise
#include "Tools/IrisNoise.hlsl"
#endif

#ifdef Use_IrisMatrix
#include "Tools/IrisMatrix.hlsl"
#endif


#endif