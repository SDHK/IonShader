/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/16
*
* 描述： Unity 引擎基础库统一入口
* 
* 功能：根据 URP/BRP 自动选择对应的基础库入口
*
*/

#ifndef Def_IrisBase
#define Def_IrisBase

//===[根据渲染管线选择基础库]===
#ifdef IrisShader_URP
#include "URP/IrisBase.hlsl"
#elif defined(IrisShader_BRP)
#include "BRP/IrisBase.hlsl"
#endif

#endif

